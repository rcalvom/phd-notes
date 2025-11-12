"""Summary generator"""

# System
import json

SARIF_FILE = "results/Module_2/cups/codeqlresults.sarif"


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


def print_errors(sarif_file:  str) -> None:
    """Print the error an their locations"""
    with open(sarif_file, "r", encoding="utf-8") as file:
        data = json.loads(file.read())
    for run in data["runs"]:
        for result in run["results"]:
            rule_id = result["ruleId"]
            if len(result["locations"]) != 1:
                print("ERROR in locations size")
            file_path = result["locations"][0]["physicalLocation"]["artifactLocation"]["uri"]
            line = result["locations"][0]["physicalLocation"]["region"]["startLine"]
            column = result["locations"][0]["physicalLocation"]["region"]["startColumn"]
            print(f"Error '{rule_id}'. {file_path}:{line}.{column}")


def main():
    """Entry point"""
    # report = generate_summary(SARIF_FILE)
    # for key, value in report.items():
    #     print(f"{key},{value},,,")
    print_errors(SARIF_FILE)


if __name__ == "__main__":
    main()
