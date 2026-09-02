#!/usr/bin/env python3
"""Reject the public template's default metadata before submission."""

from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED = {
    "TemplateStatus": "final",
    "HomeworkTitle": "Homework XX",
    "HomeworkSubtitle": "Template assignment",
    "StudentName": "Student Name",
    "StudentId": "Student ID",
    "StudentEmail": "Student Email",
    "CourseCode": "COURSE 101",
    "CourseName": "Course Name",
    "InstructorName": "Instructor Name",
    "SubmissionDate": "Month DD, YYYY",
}

OPTIONAL = {"HomeworkSubtitle"}


def strip_comments(source: str) -> str:
    return re.sub(r"(?<!\\)%.*", "", source)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: check-metadata.py FILE.tex [FILE.tex ...]", file=sys.stderr)
        return 2
    paths = [Path(value) for value in sys.argv[1:]]
    source = "\n".join(
        strip_comments(path.read_text(encoding="utf-8")) for path in paths
    )
    values = dict(
        re.findall(
            r"\\(?:newcommand|providecommand|renewcommand)\{\\(\w+)\}\{([^{}]*)\}",
            source,
        )
    )
    errors = []
    for name, placeholder in REQUIRED.items():
        if name not in values:
            errors.append(f"missing \\{name}")
        elif not values[name].strip() and name not in OPTIONAL:
            errors.append(f"empty \\{name}")
        elif name == "TemplateStatus" and values[name].strip() != "final":
            errors.append("set \\TemplateStatus to final")
        elif placeholder is not None and values[name].strip() == placeholder:
            errors.append(f"replace \\{name} ({placeholder})")

    if errors:
        print(f"{paths[-1]}: not ready for submission:")
        for error in errors:
            print(f"  {error}")
        return 1
    print(f"{paths[-1]}: submission metadata finalized")
    return 0


if __name__ == "__main__":
    sys.exit(main())
