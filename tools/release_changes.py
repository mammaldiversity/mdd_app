#!/usr/bin/env python3
"""Summarise MDD release diffs into assets/data/release_changes.json.

The home screen shows the species-level taxonomy changes of each release.
Only the counts are bundled, not the full diff file.

Usage:
    python3 tools/release_changes.py path/to/diffs.json.gz
"""

import argparse
import gzip
import json
from collections import Counter
from pathlib import Path

OUTPUT = Path(__file__).resolve().parent.parent / "assets/data/release_changes.json"

# Diff categories that add or remove a species. Higher-rank changes such as
# "genus split" or "family split" leave the species count unchanged.
ADDED = {"deextinction", "dextinction", "extinct addition"}
REMOVED = {"removed"}

# Releases whose diff carries no date, as listed on mammaldiversity.org.
FALLBACK_RELEASE_DATES = {
    "2.1": "2025-04-06",
    "2.2": "2025-06-13",
    "2.3": "2025-09-01",
    "2.4": "2026-01-02",
}


def summarise(release: dict) -> dict:
    version = release["version"].removeprefix("v")
    counts = Counter(change["category"] for change in release["taxonomyChanges"])
    return {
        "version": version,
        "prevVersion": release["prevVersion"].removeprefix("v"),
        "releaseDate": release.get("releaseDate")
        or FALLBACK_RELEASE_DATES.get(version),
        "deNovo": counts["de novo"],
        "split": counts["split"],
        "lump": counts["lump"],
        "added": sum(counts[c] for c in ADDED),
        "removed": sum(counts[c] for c in REMOVED),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("diffs", type=Path, help="diffs.json or diffs.json.gz")
    args = parser.parse_args()

    opener = gzip.open if args.diffs.suffix == ".gz" else open
    with opener(args.diffs, "rt", encoding="utf-8") as f:
        releases = json.load(f)

    summary = [summarise(release) for release in releases]
    OUTPUT.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(summary)} releases to {OUTPUT}")


if __name__ == "__main__":
    main()
