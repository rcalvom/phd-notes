"""CLI to search GitHub code with multiple queries and export unique repositories."""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time
import requests
from dotenv import load_dotenv

GITHUB_CODE_SEARCH_URL = "https://api.github.com/search/code"
PER_PAGE = 100
MAX_RESULTS_PER_QUERY = 1000
MAX_PAGES_PER_QUERY = MAX_RESULTS_PER_QUERY // PER_PAGE
SLEEP_SECONDS = 1
REQUEST_TIMEOUT_SECONDS = 30
CHECKPOINT_SUFFIX = ".checkpoint.json"
SIZE_SLICE_START = 0
SIZE_SLICE_STEP = 5000
MAX_SIZE_SLICES = 10000


def maybe_wait_for_rate_limit(
    rate_limit_remaining: str | None,
    rate_limit_reset: str | None,
    context: str,
) -> bool:
    """Sleep until reset time when rate limit is exhausted; return True if slept."""
    if rate_limit_remaining != "0":
        return False
    if not rate_limit_reset:
        return False
    try:
        reset_epoch = int(rate_limit_reset)
    except ValueError:
        return False

    now_epoch = int(time.time())
    wait_seconds = max(reset_epoch - now_epoch + 1, 1)
    print(
        f"[RATE_LIMIT] {context} remaining=0, sleeping {wait_seconds}s "
        f"until reset_epoch={reset_epoch}"
    )
    time.sleep(wait_seconds)
    return True


def parse_args() -> argparse.Namespace:
    """Build and parse CLI arguments."""
    parser = argparse.ArgumentParser(
        description=(
            "Read multiple code-search queries from a CSV file, search GitHub code, "
            "and export unique repositories to another CSV file."
        )
    )
    parser.add_argument(
        "-i",
        "--input",
        default="inputs/input_queries.csv",
        help="Input CSV file containing queries (default: inputs/input_queries.csv)",
    )
    parser.add_argument(
        "-o",
        "--output",
        default="outputs/github_repositories.csv",
        help="Output CSV file for unique repository results (default: outputs/github_repositories.csv)",
    )
    return parser.parse_args()


def read_queries(input_csv: str) -> list[str]:
    """Read queries from a CSV file without header using the first column only."""
    queries: list[str] = []

    with open(input_csv, "r", newline="", encoding="utf-8") as file:
        reader = csv.reader(file)
        for row in reader:
            if not row:
                continue
            value = row[0].strip()
            if value:
                queries.append(value)

    return list(dict.fromkeys(queries))


def checkpoint_path_for_output(output_csv: str) -> str:
    """Return checkpoint file path derived from output CSV path."""
    return f"{output_csv}{CHECKPOINT_SUFFIX}"


def save_checkpoint(
    checkpoint_path: str,
    input_csv: str,
    output_csv: str,
    completed_queries: set[str],
    repos_by_full_name: dict[str, dict[str, object]],
) -> None:
    """Persist resumable progress to disk."""
    checkpoint_dir = os.path.dirname(checkpoint_path)
    if checkpoint_dir:
        os.makedirs(checkpoint_dir, exist_ok=True)

    serialized_repos: dict[str, dict[str, object]] = {}
    for full_name, row in repos_by_full_name.items():
        serialized_row = dict(row)
        serialized_row["_matched_queries_set"] = sorted(
            serialized_row.get("_matched_queries_set", set())
        )
        serialized_repos[full_name] = serialized_row

    payload = {
        "version": 1,
        "input_csv": input_csv,
        "output_csv": output_csv,
        "completed_queries": sorted(completed_queries),
        "repos_by_full_name": serialized_repos,
        "saved_at_epoch": int(time.time()),
    }
    with open(checkpoint_path, "w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=True, separators=(",", ":"))
    print(
        f"[CHECKPOINT] saved file={checkpoint_path} "
        f"completed_queries={len(completed_queries)} repos={len(repos_by_full_name)}"
    )


def load_checkpoint(
    checkpoint_path: str,
    input_csv: str,
    output_csv: str,
) -> tuple[set[str], dict[str, dict[str, object]]]:
    """Load checkpoint if available and compatible with current run."""
    if not os.path.exists(checkpoint_path):
        return set(), {}

    with open(checkpoint_path, "r", encoding="utf-8") as file:
        payload = json.load(file)

    if payload.get("input_csv") != input_csv or payload.get("output_csv") != output_csv:
        print(
            "[CHECKPOINT] existing checkpoint ignored due to input/output mismatch: "
            f"{checkpoint_path}"
        )
        return set(), {}

    completed_queries = set(payload.get("completed_queries", []))
    raw_repos = payload.get("repos_by_full_name", {})
    repos_by_full_name: dict[str, dict[str, object]] = {}
    for full_name, row_obj in raw_repos.items():
        row = dict(row_obj)
        row["_matched_queries_set"] = set(row.get("_matched_queries_set", []))
        row["_query_match_counts"] = dict(row.get("_query_match_counts", {}))
        repos_by_full_name[full_name] = row

    print(
        f"[CHECKPOINT] loaded file={checkpoint_path} "
        f"completed_queries={len(completed_queries)} repos={len(repos_by_full_name)}"
    )
    return completed_queries, repos_by_full_name


def materialize_output_rows(
    repos_by_full_name: dict[str, dict[str, object]],
) -> list[dict[str, object]]:
    """Convert internal aggregate state into final CSV rows."""
    output_rows: list[dict[str, object]] = []
    for row in repos_by_full_name.values():
        matched_queries_sorted = sorted(row["_matched_queries_set"])
        query_breakdown_sorted = {
            key: row["_query_match_counts"][key]
            for key in sorted(row["_query_match_counts"].keys())
        }

        row["matched_queries_count"] = len(matched_queries_sorted)
        row["matched_queries"] = " | ".join(matched_queries_sorted)
        row["query_match_breakdown"] = json.dumps(
            query_breakdown_sorted,
            ensure_ascii=True,
            separators=(",", ":"),
        )

        row.pop("_matched_queries_set", None)
        row.pop("_query_match_counts", None)
        output_rows.append(row)

    output_rows.sort(
        key=lambda r: (
            r.get("matched_queries_count", 0),
            r.get("matched_code_results_count", 0),
            r.get("stargazers_count") or 0,
        ),
        reverse=True,
    )
    return output_rows


def github_api_request(
    url: str, token: str, params: dict[str, str | int], query: str, page: int
) -> dict[str, object]:
    """Perform a GitHub API GET request and return JSON payload."""
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "github-repo-search-cli",
    }
    print(
        f"[REQUEST] endpoint=/search/code query={query!r} page={page} "
        f"params={params}"
    )
    while True:
        try:
            response = requests.get(
                url=url,
                headers=headers,
                params=params,
                timeout=REQUEST_TIMEOUT_SECONDS,
            )
        except requests.exceptions.RequestException as exc:
            raise RuntimeError(f"Network error calling GitHub API: {exc}") from exc

        rate_limit = response.headers.get("X-RateLimit-Limit")
        remaining = response.headers.get("X-RateLimit-Remaining")
        used = response.headers.get("X-RateLimit-Used")
        reset = response.headers.get("X-RateLimit-Reset")
        print(
            "[RESPONSE] "
            f"status={response.status_code} "
            f"rate_limit={rate_limit} "
            f"remaining={remaining} "
            f"used={used} "
            f"reset={reset}"
        )

        if response.status_code == 403 and maybe_wait_for_rate_limit(
            rate_limit_remaining=remaining,
            rate_limit_reset=reset,
            context=f"query={query!r} page={page}",
        ):
            continue

        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as exc:
            raise RuntimeError(
                f"GitHub API error {response.status_code}: {response.text}"
            ) from exc

        maybe_wait_for_rate_limit(
            rate_limit_remaining=remaining,
            rate_limit_reset=reset,
            context=f"post-success query={query!r} page={page}",
        )
        return response.json()


def build_size_slice_query(base_query: str, start_size: int, end_size: int) -> str:
    """Build one size-sliced query for GitHub code search."""
    return f"{base_query} size:{start_size}..{end_size}".strip()


def process_search_query(
    search_query: str,
    token: str,
    query_hits: dict[str, dict[str, object]],
) -> tuple[int, set[str], int]:
    """Fetch one search query with pagination and aggregate hits by repository."""
    page = 1
    emitted = 0
    query_result_count = 0
    query_unique_repos = set()
    first_page_total_count = 0

    while page <= MAX_PAGES_PER_QUERY and emitted < MAX_RESULTS_PER_QUERY:
        params = {
            "q": search_query,
            "per_page": PER_PAGE,
            "page": page,
        }
        payload = github_api_request(
            GITHUB_CODE_SEARCH_URL, token, params, query=search_query, page=page
        )

        if page == 1:
            first_page_total_count = int(payload.get("total_count", 0))

        items = payload.get("items", [])
        if not items:
            break

        for item in items:
            if emitted >= MAX_RESULTS_PER_QUERY:
                break
            emitted += 1
            repository = item.get("repository") or {}
            full_name = repository.get("full_name")
            if not full_name:
                continue

            query_result_count += 1
            query_unique_repos.add(full_name)

            hit = query_hits.get(full_name)
            if hit is None:
                query_hits[full_name] = {"repository": repository, "count": 1}
            else:
                hit["count"] = hit.get("count", 0) + 1

        if len(items) < PER_PAGE:
            break

        page += 1
        time.sleep(max(SLEEP_SECONDS, 0))

    if emitted >= MAX_RESULTS_PER_QUERY:
        print(
            f"[QUERY_LIMIT] query={search_query!r} reached limit={MAX_RESULTS_PER_QUERY} "
            "results, stopping pagination for this search query."
        )

    return query_result_count, query_unique_repos, first_page_total_count


def init_repo_row(repo: dict[str, object]) -> dict[str, object]:
    """Create the base output row for a repository from GitHub payload fields."""
    owner = repo.get("owner") or {}
    license_obj = repo.get("license") or {}
    return {
        "repo_id": repo.get("id"),
        "full_name": repo.get("full_name"),
        "name": repo.get("name"),
        "repo_html_url": repo.get("html_url"),
        "description": repo.get("description"),
        "language": repo.get("language"),
        "stargazers_count": repo.get("stargazers_count"),
        "forks_count": repo.get("forks_count"),
        "open_issues_count": repo.get("open_issues_count"),
        "watchers_count": repo.get("watchers_count"),
        "default_branch": repo.get("default_branch"),
        "owner_login": owner.get("login"),
        "owner_type": owner.get("type"),
        "license": license_obj.get("spdx_id") or license_obj.get("name"),
        "created_at": repo.get("created_at"),
        "updated_at": repo.get("updated_at"),
        "pushed_at": repo.get("pushed_at"),
        "is_private": repo.get("private"),
        "is_fork": repo.get("fork"),
        "archived": repo.get("archived"),
        "matched_queries_count": 0,
        "matched_code_results_count": 0,
        "matched_queries": "",
        "query_match_breakdown": "",
        "_matched_queries_set": set(),
        "_query_match_counts": {},
    }


def aggregate_unique_repositories(
    queries: list[str],
    token: str,
    input_csv: str,
    output_csv: str,
) -> tuple[list[dict[str, object]], bool]:
    """Aggregate code-search matches into unique repositories across all queries."""
    checkpoint_path = checkpoint_path_for_output(output_csv)
    completed_queries, repos_by_full_name = load_checkpoint(
        checkpoint_path=checkpoint_path,
        input_csv=input_csv,
        output_csv=output_csv,
    )
    interrupted = False

    for query in queries:
        if query in completed_queries:
            print(f"[RESUME] skipping already completed query: {query}")
            continue

        print(f"Searching code query: {query}")
        query_result_count = 0
        query_unique_repos = set()
        query_hits: dict[str, dict[str, object]] = {}

        try:
            slice_start = SIZE_SLICE_START
            for slice_idx in range(MAX_SIZE_SLICES):
                slice_end = slice_start + SIZE_SLICE_STEP - 1
                sliced_query = build_size_slice_query(query, slice_start, slice_end)
                (
                    slice_result_count,
                    slice_unique_repos,
                    first_page_total_count,
                ) = process_search_query(
                    search_query=sliced_query,
                    token=token,
                    query_hits=query_hits,
                )
                query_result_count += slice_result_count
                query_unique_repos.update(slice_unique_repos)
                print(
                    f"[SLICE] base_query={query!r} index={slice_idx} "
                    f"size={slice_start}..{slice_end} total_count={first_page_total_count} "
                    f"fetched_items={slice_result_count} unique_repos={len(slice_unique_repos)}"
                )
                if first_page_total_count == 0:
                    print(
                        f"[SLICE_STOP] base_query={query!r} reached zero-result slice "
                        f"at size={slice_start}..{slice_end}"
                    )
                    break
                slice_start = slice_end + 1
            else:
                print(
                    f"[SLICE_STOP] base_query={query!r} reached max slices "
                    f"limit={MAX_SIZE_SLICES}."
                )
        except KeyboardInterrupt:
            interrupted = True
            print(
                f"[INTERRUPT] detected during query={query!r}; "
                "current query progress not committed. Saving checkpoint."
            )
            save_checkpoint(
                checkpoint_path=checkpoint_path,
                input_csv=input_csv,
                output_csv=output_csv,
                completed_queries=completed_queries,
                repos_by_full_name=repos_by_full_name,
            )
            break

        for full_name, hit in query_hits.items():
            repository = hit["repository"]
            count = hit.get("count", 0)
            row = repos_by_full_name.get(full_name)
            if row is None:
                row = init_repo_row(repository)
                repos_by_full_name[full_name] = row

            row["matched_code_results_count"] += count
            row["_matched_queries_set"].add(query)
            match_counts = row["_query_match_counts"]
            match_counts[query] = match_counts.get(query, 0) + count

        print(
            "  -> code matches: "
            f"{query_result_count}, unique repos in this query: {len(query_unique_repos)}"
        )
        completed_queries.add(query)
        save_checkpoint(
            checkpoint_path=checkpoint_path,
            input_csv=input_csv,
            output_csv=output_csv,
            completed_queries=completed_queries,
            repos_by_full_name=repos_by_full_name,
        )

    output_rows = materialize_output_rows(repos_by_full_name)
    if not interrupted and os.path.exists(checkpoint_path):
        os.remove(checkpoint_path)
        print(f"[CHECKPOINT] removed after successful completion: {checkpoint_path}")
    return output_rows, interrupted


def write_results(output_csv: str, rows: list[dict[str, object]]) -> None:
    """Write aggregated repository rows to the output CSV file."""
    headers = [
        "repo_id",
        "full_name",
        "name",
        "repo_html_url",
        "description",
        "language",
        "stargazers_count",
        "forks_count",
        "open_issues_count",
        "watchers_count",
        "default_branch",
        "owner_login",
        "owner_type",
        "license",
        "created_at",
        "updated_at",
        "pushed_at",
        "is_private",
        "is_fork",
        "archived",
        "matched_queries_count",
        "matched_code_results_count",
        "matched_queries",
        "query_match_breakdown",
    ]

    output_dir = os.path.dirname(output_csv)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    with open(output_csv, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    """Run the CLI workflow end-to-end and return a process exit code."""
    args = parse_args()
    load_dotenv()

    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if not token:
        print(
            "Error: Missing token. Set GITHUB_TOKEN in .env or environment.",
            file=sys.stderr,
        )
        return 1
    print(
        f"[AUTH] token_detected=yes token_length={len(token)} "
        f"token_prefix={token[:4] if len(token) >= 4 else token!r}"
    )

    try:
        queries = read_queries(args.input)
    except FileNotFoundError:
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        return 1
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    if not queries:
        print("Error: No queries found in input file.", file=sys.stderr)
        return 1

    all_rows, interrupted = aggregate_unique_repositories(
        queries=queries,
        token=token,
        input_csv=args.input,
        output_csv=args.output,
    )

    write_results(args.output, all_rows)
    if interrupted:
        print(
            f"[PARTIAL_OUTPUT] saved {len(all_rows)} unique repositories to: {args.output}"
        )
        print(
            "Run was interrupted. Resume by executing the same command again."
        )
        return 130

    print(f"Saved {len(all_rows)} unique repositories to: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
