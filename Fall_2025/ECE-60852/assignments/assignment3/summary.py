"""Summary generator"""

# System
import json

SARIF_FILE = "results/Module_2/sqlite3/codeqlresults.sarif"


def generate_summary(sarif_file: str) -> dict:
    """Generates a summary from a sarif file"""
    with open(sarif_file, "r", encoding="utf-8") as file:
        data = json.loads(file.read())
    summary = {}
    for run in data["runs"]:
        for result in run["results"]:
            if result["ruleId"] not in summary:
                summary[result["ruleId"]] = 1
            else:
                summary[result["ruleId"]] += 1
    return summary


def main():
    """Entry point"""
    report = generate_summary(SARIF_FILE)
    for key, value in report.items():
        print(f"{key},{value},,,")


if __name__ == "__main__":
    main()
