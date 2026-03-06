#!/usr/bin/env python3
"""POC script: iterate GitHub code-search size slices until a slice returns 0 results."""

from __future__ import annotations

import argparse
import csv
import os
import sys
import time

import requests
from dotenv import load_dotenv

GITHUB_CODE_SEARCH_URL = "https://api.github.com/search/code"
REQUEST_TIMEOUT_SECONDS = 30


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for size-slice probing."""
    parser = argparse.ArgumentParser(
        description=(
            "Run GitHub code-search size slices for a base query and stop when a slice "
            "returns total_count=0."
        )
    )
    parser.add_argument(
        "--query",
        required=True,
        help='Base code query without size filter (example: \'MPI_Init language:C\')',
    )
    parser.add_argument(
        "--start-size",
        type=int,
        default=0,
        help="Starting file size in bytes (default: 0)",
    )
    parser.add_argument(
        "--step",
        type=int,
        default=5000,
        help="Slice width in bytes (default: 5000)",
    )
    parser.add_argument(
        "--output",
        default="outputs/poc_size_slices.csv",
        help="CSV output path (default: outputs/poc_size_slices.csv)",
    )
    parser.add_argument(
        "--sleep-seconds",
        type=float,
        default=1.0,
        help="Delay between slice requests (default: 1.0)",
    )
    parser.add_argument(
        "--max-slices",
        type=int,
        default=10000,
        help="Safety cap for total slices (default: 10000)",
    )
    return parser.parse_args()


def wait_if_rate_limited(response: requests.Response, context: str) -> bool:
    """Wait until reset if rate-limited; return True if sleep was performed."""
    remaining = response.headers.get("X-RateLimit-Remaining")
    reset = response.headers.get("X-RateLimit-Reset")
    if remaining != "0" or not reset:
        return False
    try:
        reset_epoch = int(reset)
    except ValueError:
        return False
    wait_seconds = max(reset_epoch - int(time.time()) + 1, 1)
    print(
        f"[RATE_LIMIT] {context} remaining=0, sleeping {wait_seconds}s "
        f"until reset_epoch={reset_epoch}"
    )
    time.sleep(wait_seconds)
    return True


def search_slice_total_count(token: str, query: str, start_size: int, end_size: int) -> tuple[int, bool]:
    """Query one size slice and return (total_count, incomplete_results)."""
    size_filter = f"size:{start_size}..{end_size}"
    full_query = f"{query} {size_filter}".strip()
    params = {"q": full_query, "per_page": 1, "page": 1}
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "github-size-slices-poc",
    }

    while True:
        print(f"[REQUEST] q={full_query!r}")
        response = requests.get(
            GITHUB_CODE_SEARCH_URL,
            headers=headers,
            params=params,
            timeout=REQUEST_TIMEOUT_SECONDS,
        )
        print(
            "[RESPONSE] "
            f"status={response.status_code} "
            f"rate_limit={response.headers.get('X-RateLimit-Limit')} "
            f"remaining={response.headers.get('X-RateLimit-Remaining')} "
            f"reset={response.headers.get('X-RateLimit-Reset')}"
        )

        if response.status_code == 403 and wait_if_rate_limited(
            response, context=f"slice={start_size}..{end_size}"
        ):
            continue

        response.raise_for_status()
        wait_if_rate_limited(response, context=f"post-success slice={start_size}..{end_size}")
        payload = response.json()
        total_count = int(payload.get("total_count", 0))
        incomplete_results = bool(payload.get("incomplete_results", False))
        return total_count, incomplete_results


def write_rows(output_csv: str, rows: list[dict[str, object]]) -> None:
    """Write slice probe results to CSV."""
    output_dir = os.path.dirname(output_csv)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    headers = [
        "base_query",
        "slice_start",
        "slice_end",
        "slice_width",
        "total_count",
        "incomplete_results",
    ]
    with open(output_csv, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    """Run the size-slice POC workflow."""
    args = parse_args()
    if args.step <= 0:
        print("Error: --step must be > 0", file=sys.stderr)
        return 1
    if args.start_size < 0:
        print("Error: --start-size must be >= 0", file=sys.stderr)
        return 1
    if args.max_slices <= 0:
        print("Error: --max-slices must be > 0", file=sys.stderr)
        return 1

    load_dotenv()
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if not token:
        print("Error: Missing token. Set GITHUB_TOKEN in .env or environment.", file=sys.stderr)
        return 1

    print(
        f"[AUTH] token_detected=yes token_length={len(token)} "
        f"token_prefix={token[:4] if len(token) >= 4 else token!r}"
    )

    rows: list[dict[str, object]] = []
    start_size = args.start_size

    for i in range(args.max_slices):
        end_size = start_size + args.step - 1
        total_count, incomplete_results = search_slice_total_count(
            token=token,
            query=args.query,
            start_size=start_size,
            end_size=end_size,
        )

        row = {
            "base_query": args.query,
            "slice_start": start_size,
            "slice_end": end_size,
            "slice_width": args.step,
            "total_count": total_count,
            "incomplete_results": incomplete_results,
        }
        rows.append(row)
        print(
            f"[SLICE] index={i} size={start_size}..{end_size} "
            f"total_count={total_count} incomplete_results={incomplete_results}"
        )

        if total_count == 0:
            print("[STOP] Reached first zero-result slice.")
            break

        start_size = end_size + 1
        time.sleep(max(args.sleep_seconds, 0))
    else:
        print(
            f"[STOP] Reached safety cap max_slices={args.max_slices} without zero-result slice."
        )

    write_rows(args.output, rows)
    print(f"Saved {len(rows)} rows to: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
