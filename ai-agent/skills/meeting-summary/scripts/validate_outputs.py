#!/usr/bin/env python3
"""Validate meeting-summary skill outputs: <slug>-timeline.md and <slug>.mind.md."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ALLOWED_TYPES = {"sync", "discuss", "review", "decision", "action", "qa", "misc"}

TS_PART = r"(?:\d{2}:\d{2}:\d{2}|N/A)"
INDEX_RE = re.compile(
    rf"^- \[ ({TS_PART}) -- ({TS_PART}) \] ([a-z]+) (\S+)$"
)
DETAIL_HEADING_RE = re.compile(
    rf"^### \[ ({TS_PART}) -- ({TS_PART}) \] ([a-z]+) (\S+)$"
)
BULLET_RE = re.compile(r"^( *)- (\S.*)$")


def parse_ts(ts: str) -> int | None:
    if ts == "N/A":
        return None
    h, m, s = (int(part) for part in ts.split(":"))
    if m >= 60 or s >= 60:
        raise ValueError(f"Invalid timestamp '{ts}': minutes/seconds must be < 60")
    return h * 3600 + m * 60 + s


def validate_timeline(path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []

    if not path.is_file():
        return [f"Timeline file not found: {path}"], warnings

    lines = path.read_text(encoding="utf-8").splitlines()

    timeline_start = None
    details_start = None
    for idx, line in enumerate(lines):
        if line.strip() == "## Timeline":
            timeline_start = idx
        elif line.strip() == "## Details":
            details_start = idx

    if timeline_start is None:
        errors.append(f"{path.name}: Missing '## Timeline' section heading.")
    if details_start is None:
        errors.append(f"{path.name}: Missing '## Details' section heading.")
    if timeline_start is None or details_start is None:
        return errors, warnings

    if timeline_start >= details_start:
        errors.append(f"{path.name}: '## Timeline' must appear before '## Details'.")
        return errors, warnings

    # Parse timeline index entries
    index_entries: list[tuple[str, str, str, str]] = []
    seen_slugs: set[str] = set()
    prev_start: int | None = None
    prev_end: int | None = None

    for lineno in range(timeline_start + 1, details_start):
        raw = lines[lineno]
        stripped = raw.strip()
        if not stripped:
            continue
        if stripped.startswith("## "):
            break

        m = INDEX_RE.match(raw)
        if not m:
            errors.append(
                f"{path.name}:{lineno + 1}: Invalid timeline index line: {raw!r}. "
                "Expected '- [ HH:MM:SS -- HH:MM:SS ] <type> <segment-slug>'."
            )
            continue

        start_s, end_s, seg_type, seg_slug = m.groups()
        if seg_type not in ALLOWED_TYPES:
            errors.append(
                f"{path.name}:{lineno + 1}: Invalid <type> '{seg_type}'. "
                f"Allowed: {', '.join(sorted(ALLOWED_TYPES))}."
            )
        if seg_slug in seen_slugs:
            errors.append(
                f"{path.name}:{lineno + 1}: Duplicate segment slug '{seg_slug}'."
            )
        seen_slugs.add(seg_slug)

        try:
            start_sec = parse_ts(start_s)
            end_sec = parse_ts(end_s)
        except ValueError as exc:
            errors.append(f"{path.name}:{lineno + 1}: {exc}")
            start_sec = end_sec = None

        if (start_sec is None) != (end_sec is None):
            errors.append(
                f"{path.name}:{lineno + 1}: Start and end timestamps must both be HH:MM:SS or both be N/A."
            )
        elif start_sec is not None and end_sec is not None:
            if start_sec > end_sec:
                errors.append(
                    f"{path.name}:{lineno + 1}: Start timestamp {start_s} > end timestamp {end_s}."
                )
            if prev_start is not None and start_sec < prev_start:
                warnings.append(
                    f"{path.name}:{lineno + 1}: Non-monotonic start timestamp {start_s} (earlier than previous segment)."
                )
            if prev_end is not None and start_sec - prev_end > 60:
                warnings.append(
                    f"{path.name}:{lineno + 1}: Gap of {start_sec - prev_end}s before {start_s}; verify no content was skipped."
                )
            prev_start = start_sec
            prev_end = end_sec

        index_entries.append((start_s, end_s, seg_type, seg_slug))

    if not index_entries:
        errors.append(f"{path.name}: '## Timeline' contains no valid segment entries.")

    # Parse detail headings & check content
    detail_entries: list[tuple[str, str, str, str]] = []
    detail_line_indices: list[int] = []
    for lineno in range(details_start + 1, len(lines)):
        raw = lines[lineno]
        if raw.startswith("### "):
            m = DETAIL_HEADING_RE.match(raw)
            if not m:
                errors.append(
                    f"{path.name}:{lineno + 1}: Invalid detail heading: {raw!r}. "
                    "Expected '### [ HH:MM:SS -- HH:MM:SS ] <type> <segment-slug>'."
                )
                continue
            detail_entries.append(m.groups())
            detail_line_indices.append(lineno)

    if index_entries != detail_entries:
        index_set = set(index_entries)
        detail_set = set(detail_entries)
        missing = [e for e in index_entries if e not in detail_set]
        extra = [e for e in detail_entries if e not in index_set]
        if missing:
            errors.append(
                f"{path.name}: Missing detail section(s) for timeline entries: "
                + ", ".join(e[3] for e in missing)
            )
        if extra:
            errors.append(
                f"{path.name}: Extra detail section(s) not listed in Timeline: "
                + ", ".join(e[3] for e in extra)
            )
        if not missing and not extra:
            errors.append(
                f"{path.name}: Order of '## Details' sections does not match '## Timeline'."
            )

    # Check each detail section has non-empty bullet content
    for idx, heading_lineno in enumerate(detail_line_indices):
        end_lineno = (
            detail_line_indices[idx + 1]
            if idx + 1 < len(detail_line_indices)
            else len(lines)
        )
        body_lines = [
            lines[i].strip()
            for i in range(heading_lineno + 1, end_lineno)
            if lines[i].strip()
        ]
        has_bullet = any(line.startswith("- ") for line in body_lines)
        if not has_bullet:
            seg_slug = detail_entries[idx][3]
            errors.append(
                f"{path.name}:{heading_lineno + 1}: Detail section '{seg_slug}' has no bullet content."
            )

    return errors, warnings


def validate_mindmap(path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []

    if not path.is_file():
        return [f"Mind map file not found: {path}"], warnings

    lines = path.read_text(encoding="utf-8").splitlines()
    non_empty = [(i + 1, line) for i, line in enumerate(lines) if line.strip()]
    if not non_empty:
        return [f"{path.name}: File is empty."], warnings

    prev_level = -1
    max_level = 0
    root_count = 0

    for lineno, line in non_empty:
        if "\t" in line:
            errors.append(f"{path.name}:{lineno}: Tab indentation is not allowed; use 2 spaces.")
            continue
        m = BULLET_RE.match(line)
        if not m:
            errors.append(
                f"{path.name}:{lineno}: Expected pure nested bullet ('- ...'), got: {line!r}."
            )
            continue

        spaces = len(m.group(1))
        if spaces % 2 != 0:
            errors.append(
                f"{path.name}:{lineno}: Indentation must be a multiple of 2 spaces (got {spaces})."
            )
            continue

        level = spaces // 2
        if prev_level == -1 and level != 0:
            errors.append(f"{path.name}:{lineno}: First node must be at indent level 0.")
        elif prev_level != -1 and level > prev_level + 1:
            errors.append(
                f"{path.name}:{lineno}: Skipped indentation level (from {prev_level} to {level})."
            )

        if level == 0:
            root_count += 1
        max_level = max(max_level, level)
        prev_level = level

    if max_level < 1:
        errors.append(f"{path.name}: Mind map must have at least 2 levels (topic and sub-topic).")
    if root_count > 1:
        warnings.append(
            f"{path.name}: Found {root_count} top-level root nodes; a single root node is recommended for mind-map renderers."
        )

    return errors, warnings


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(
            "Usage: python3 validate_outputs.py <slug>-timeline.md <slug>.mind.md",
            file=sys.stderr,
        )
        return 2

    timeline_path = Path(argv[1])
    mindmap_path = Path(argv[2])

    errors: list[str] = []
    warnings: list[str] = []

    if not timeline_path.name.endswith("-timeline.md"):
        warnings.append(
            f"Timeline filename '{timeline_path.name}' does not end with '-timeline.md'."
        )
    if not mindmap_path.name.endswith(".mind.md"):
        warnings.append(
            f"Mind map filename '{mindmap_path.name}' does not end with '.mind.md'."
        )
    if timeline_path.name.endswith("-timeline.md") and mindmap_path.name.endswith(".mind.md"):
        t_slug = timeline_path.name[: -len("-timeline.md")]
        m_slug = mindmap_path.name[: -len(".mind.md")]
        if t_slug != m_slug:
            warnings.append(
                f"Slug mismatch: timeline slug '{t_slug}' != mind map slug '{m_slug}'."
            )

    t_err, t_warn = validate_timeline(timeline_path)
    m_err, m_warn = validate_mindmap(mindmap_path)
    errors.extend(t_err)
    errors.extend(m_err)
    warnings.extend(t_warn)
    warnings.extend(m_warn)

    for w in warnings:
        print(f"[WARN] {w}")
    for e in errors:
        print(f"[ERROR] {e}")

    if errors:
        print(f"Validation FAILED ({len(errors)} error(s), {len(warnings)} warning(s)).")
        return 1

    print(f"Validation PASSED ({len(warnings)} warning(s)).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
