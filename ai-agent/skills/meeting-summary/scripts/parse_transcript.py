#!/usr/bin/env python3
"""
Inspect, normalize, and chunk meeting transcript/subtitle files.

Supports:
- .srt (SubRip subtitles)
- .vtt (WebVTT subtitles)
- .txt / .md (plain text, Feishu Minutes / Tongyi Tingwu / Zoom / Otter exports)
- .json (common ASR exports with segments/utterances/paragraphs/transcript arrays)

Zero external dependencies (Python 3 standard library only).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, List, Optional, Tuple


@dataclass
class Utterance:
    start: Optional[str]
    speaker: Optional[str]
    text: str


TS_CORE = r"(?:\d{1,2}:)?\d{1,2}:\d{2}(?:[.,]\d{1,3})?"
SRT_RANGE_RE = re.compile(
    rf"^\s*({TS_CORE})\s*-->\s*({TS_CORE})(?:\s+.*)?$"
)
# Pattern: "发言人 1 00:01:23" or "张三 01:23" or "Speaker 1  00:01:23"
SPEAKER_THEN_TS_RE = re.compile(
    rf"^\s*([^\n:：\[\]()（）]{{1,32}}?)\s+[\[\(]?({TS_CORE})[\]\)]?\s*$"
)
# Pattern: "[00:01:23] 张三: 内容" or "00:01:23 张三：内容"
TS_THEN_SPEAKER_RE = re.compile(
    rf"^\s*[\[\(]?({TS_CORE})[\]\)]?\s+([^\n:：]{{1,32}}?)\s*[:：]\s*(.*)$"
)
# Pattern: "张三 [00:01:23]: 内容" or "张三(00:01:23)：内容"
SPEAKER_TS_INLINE_RE = re.compile(
    rf"^\s*([^\n:：\[\]()（）]{{1,32}}?)\s*[\[\(]?({TS_CORE})[\]\)]?\s*[:：]\s*(.*)$"
)
# Pattern: "[00:01:23] 内容"
TS_ONLY_INLINE_RE = re.compile(
    rf"^\s*[\[\(]({TS_CORE})[\]\)]\s+(.*)$"
)
# Pattern: "张三: 内容" or "发言人 1：内容" (avoid URLs like http://)
SPEAKER_ONLY_INLINE_RE = re.compile(
    r"^\s*([^\n:：\[\]()（）/]{1,28}?)\s*[:：]\s+(.*)$"
)
# Standalone timestamp line: "00:01:23" or "[00:01:23]"
TS_STANDALONE_RE = re.compile(rf"^\s*[\[\(]?({TS_CORE})[\]\)]?\s*$")


def normalize_timestamp(ts: Optional[str]) -> Optional[str]:
    if not ts:
        return None
    clean = ts.strip().replace(",", ".")
    clean = clean.split(".")[0]
    parts = [int(p) for p in clean.split(":")]
    if len(parts) == 2:
        mm, ss = parts
        return f"{mm:02d}:{ss:02d}"
    if len(parts) == 3:
        hh, mm, ss = parts
        return f"{hh:02d}:{mm:02d}:{ss:02d}"
    return clean


def timestamp_to_seconds(ts: Optional[str]) -> Optional[int]:
    if not ts:
        return None
    parts = [int(p) for p in ts.split(":")]
    if len(parts) == 2:
        return parts[0] * 60 + parts[1]
    if len(parts) == 3:
        return parts[0] * 3600 + parts[1] * 60 + parts[2]
    return None


def seconds_to_timestamp(sec: float) -> str:
    total = max(0, int(round(sec)))
    hh = total // 3600
    mm = (total % 3600) // 60
    ss = total % 60
    if hh > 0:
        return f"{hh:02d}:{mm:02d}:{ss:02d}"
    return f"{mm:02d}:{ss:02d}"


def strip_vtt_tags(text: str) -> str:
    # Handle <v Speaker Name>Text</v>
    text = re.sub(r"</?c(?:\.[^>]*)?>", "", text)
    text = re.sub(r"</?v[^>]*>", "", text)
    text = re.sub(r"<[^>]+>", "", text)
    return text.strip()


def extract_vtt_speaker(text: str) -> Tuple[Optional[str], str]:
    m = re.match(r"^\s*<v\s+([^>]+)>(.*)$", text, flags=re.DOTALL)
    if m:
        return m.group(1).strip(), strip_vtt_tags(m.group(2))
    return None, strip_vtt_tags(text)


def read_text_with_fallback(path: Path) -> str:
    for enc in ("utf-8-sig", "utf-8", "gb18030", "gbk", "utf-16"):
        try:
            return path.read_text(encoding=enc)
        except UnicodeDecodeError:
            continue
    return path.read_text(encoding="utf-8", errors="replace")


def parse_srt_or_vtt(content: str, is_vtt: bool) -> List[Utterance]:
    lines = content.splitlines()
    utterances: List[Utterance] = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i].strip()
        if not line or (is_vtt and (line.startswith("WEBVTT") or line.startswith("NOTE") or line.startswith("STYLE"))):
            i += 1
            continue

        # Skip pure numeric cue index in SRT
        if line.isdigit() and i + 1 < n and SRT_RANGE_RE.match(lines[i + 1]):
            i += 1
            line = lines[i].strip()

        m = SRT_RANGE_RE.match(line)
        if m:
            start_ts = normalize_timestamp(m.group(1))
            i += 1
            cue_lines: List[str] = []
            while i < n and lines[i].strip() != "":
                cue_lines.append(lines[i].strip())
                i += 1
            raw_text = " ".join(cue_lines).strip()
            if raw_text:
                speaker: Optional[str] = None
                if is_vtt:
                    speaker, text = extract_vtt_speaker(raw_text)
                else:
                    text = strip_vtt_tags(raw_text)
                if speaker is None:
                    sm = SPEAKER_ONLY_INLINE_RE.match(text)
                    if sm and not sm.group(1).lower().startswith(("http", "https")):
                        speaker = sm.group(1).strip()
                        text = sm.group(2).strip()
                if text:
                    utterances.append(Utterance(start=start_ts, speaker=speaker, text=text))
        else:
            i += 1

    return utterances


def parse_json_transcript(content: str) -> List[Utterance]:
    data = json.loads(content)
    items: Any = None
    if isinstance(data, list):
        items = data
    elif isinstance(data, dict):
        for key in ("utterances", "segments", "paragraphs", "sentences", "results", "transcript", "data"):
            if isinstance(data.get(key), list):
                items = data[key]
                break
            if isinstance(data.get(key), dict):
                nested = data[key]
                for subkey in ("utterances", "segments", "paragraphs", "sentences"):
                    if isinstance(nested.get(subkey), list):
                        items = nested[subkey]
                        break
                if items is not None:
                    break

    utterances: List[Utterance] = []
    if not isinstance(items, list):
        if isinstance(data, dict) and isinstance(data.get("text"), str):
            return parse_plain_text(data["text"])
        return utterances

    for item in items:
        if not isinstance(item, dict):
            continue
        text = (
            item.get("text")
            or item.get("transcript")
            or item.get("content")
            or item.get("sentence")
            or ""
        )
        if isinstance(text, list):
            text = " ".join(str(x) for x in text)
        text = str(text).strip()
        if not text:
            continue

        speaker_val = (
            item.get("speaker")
            or item.get("speaker_name")
            or item.get("speakerName")
            or item.get("speaker_id")
            or item.get("user")
        )
        speaker = str(speaker_val).strip() if speaker_val not in (None, "") else None

        start_val = (
            item.get("start")
            if item.get("start") is not None
            else item.get("start_time")
            if item.get("start_time") is not None
            else item.get("begin_time")
            if item.get("begin_time") is not None
            else item.get("timestamp")
        )
        start_ts: Optional[str] = None
        if isinstance(start_val, (int, float)):
            # Heuristic: values > 86400 are likely milliseconds
            sec = start_val / 1000.0 if start_val > 86400 or (isinstance(start_val, int) and item.get("begin_time") is not None) else float(start_val)
            start_ts = seconds_to_timestamp(sec)
        elif isinstance(start_val, str):
            start_ts = normalize_timestamp(start_val)

        utterances.append(Utterance(start=start_ts, speaker=speaker, text=text))

    return utterances


def parse_plain_text(content: str) -> List[Utterance]:
    lines = content.splitlines()
    utterances: List[Utterance] = []
    pending_speaker: Optional[str] = None
    pending_ts: Optional[str] = None

    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            continue

        # 1. Header line like "发言人 1 00:01:23"
        m = SPEAKER_THEN_TS_RE.match(line)
        if m:
            pending_speaker = m.group(1).strip()
            pending_ts = normalize_timestamp(m.group(2))
            continue

        # 2. Standalone timestamp line
        m = TS_STANDALONE_RE.match(line)
        if m:
            pending_ts = normalize_timestamp(m.group(1))
            continue

        # 3. "[00:01:23] 张三: 内容"
        m = TS_THEN_SPEAKER_RE.match(line)
        if m:
            ts = normalize_timestamp(m.group(1))
            spk = m.group(2).strip()
            txt = m.group(3).strip()
            if txt:
                utterances.append(Utterance(start=ts, speaker=spk, text=txt))
                pending_speaker, pending_ts = None, None
            else:
                pending_speaker, pending_ts = spk, ts
            continue

        # 4. "张三 [00:01:23]: 内容"
        m = SPEAKER_TS_INLINE_RE.match(line)
        if m:
            spk = m.group(1).strip()
            ts = normalize_timestamp(m.group(2))
            txt = m.group(3).strip()
            if txt:
                utterances.append(Utterance(start=ts, speaker=spk, text=txt))
                pending_speaker, pending_ts = None, None
            else:
                pending_speaker, pending_ts = spk, ts
            continue

        # 5. "[00:01:23] 内容"
        m = TS_ONLY_INLINE_RE.match(line)
        if m:
            ts = normalize_timestamp(m.group(1))
            txt = m.group(2).strip()
            utterances.append(Utterance(start=ts, speaker=pending_speaker, text=txt))
            pending_ts = None
            continue

        # 6. "张三: 内容"
        m = SPEAKER_ONLY_INLINE_RE.match(line)
        if m and not m.group(1).lower().startswith(("http", "https")):
            spk = m.group(1).strip()
            txt = m.group(2).strip()
            utterances.append(Utterance(start=pending_ts, speaker=spk, text=txt))
            pending_speaker, pending_ts = None, None
            continue

        # 7. Plain text body line
        utterances.append(Utterance(start=pending_ts, speaker=pending_speaker, text=line))
        pending_speaker, pending_ts = None, None

    return utterances


def merge_utterances(utterances: List[Utterance], max_merged_chars: int = 400, max_gap_sec: int = 30) -> List[Utterance]:
    """Merge consecutive short utterances from the same speaker to save tokens while preserving timestamps."""
    if not utterances:
        return []

    merged: List[Utterance] = []
    last_ts_sec: Optional[int] = None

    for u in utterances:
        cur_sec = timestamp_to_seconds(u.start)
        if merged:
            prev = merged[-1]
            same_speaker = (
                prev.speaker == u.speaker
                and (prev.speaker is not None or u.start is None)
            )
            within_gap = (
                last_ts_sec is None
                or cur_sec is None
                or (0 <= cur_sec - last_ts_sec <= max_gap_sec)
            )
            within_len = len(prev.text) + len(u.text) + 1 <= max_merged_chars

            if same_speaker and within_gap and within_len:
                sep = " " if (prev.text and prev.text[-1].isascii() and u.text and u.text[0].isascii()) else ""
                prev.text = f"{prev.text}{sep}{u.text}"
                if cur_sec is not None:
                    last_ts_sec = cur_sec
                continue

        merged.append(Utterance(start=u.start, speaker=u.speaker, text=u.text))
        if cur_sec is not None:
            last_ts_sec = cur_sec

    return merged


def format_utterance(u: Utterance) -> str:
    prefix_parts: List[str] = []
    if u.start:
        prefix_parts.append(f"[{u.start}]")
    if u.speaker:
        prefix_parts.append(f"{u.speaker}:")
    if prefix_parts:
        return f"{' '.join(prefix_parts)} {u.text}"
    return u.text


def detect_and_parse(path: Path) -> Tuple[str, List[Utterance], str]:
    raw = read_text_with_fallback(path)
    ext = path.suffix.lower()

    if ext == ".vtt" or raw.lstrip().startswith("WEBVTT"):
        return "vtt", parse_srt_or_vtt(raw, is_vtt=True), raw
    if ext == ".srt":
        return "srt", parse_srt_or_vtt(raw, is_vtt=False), raw
    if ext == ".json":
        return "json", parse_json_transcript(raw), raw
    # Auto-detect SRT syntax inside .txt files
    if SRT_RANGE_RE.search("\n".join(raw.splitlines()[:20])):
        return "srt-in-txt", parse_srt_or_vtt(raw, is_vtt=False), raw
    return ext.lstrip(".") or "txt", parse_plain_text(raw), raw


def chunk_lines(lines: List[str], max_chars: int, overlap_lines: int = 3) -> List[List[str]]:
    if not lines:
        return []
    chunks: List[List[str]] = []
    cur: List[str] = []
    cur_len = 0

    for line in lines:
        line_len = len(line) + 1
        if cur and cur_len + line_len > max_chars:
            chunks.append(cur)
            tail = cur[-overlap_lines:] if overlap_lines > 0 else []
            cur = list(tail)
            cur_len = sum(len(x) + 1 for x in cur)
        cur.append(line)
        cur_len += line_len

    if cur:
        chunks.append(cur)
    return chunks


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inspect, normalize, and chunk meeting transcript/subtitle files."
    )
    parser.add_argument("input_path", help="Path to transcript/subtitle file")
    parser.add_argument("--stats", action="store_true", help="Print JSON statistics")
    parser.add_argument("--normalize", action="store_true", help="Output normalized transcript")
    parser.add_argument("--out", help="Output file path for --normalize (default: stdout)")
    parser.add_argument("--chunk-dir", help="Split normalized transcript into chunk files in this directory")
    parser.add_argument("--max-chars", type=int, default=12000, help="Max characters per chunk (default: 12000)")
    parser.add_argument("--no-merge", action="store_true", help="Disable merging consecutive utterances by same speaker")
    args = parser.parse_args()

    path = Path(args.input_path).expanduser().resolve()
    if not path.is_file():
        print(f"Error: file not found: {path}", file=sys.stderr)
        return 1

    fmt, utterances, raw = detect_and_parse(path)
    processed = utterances if args.no_merge else merge_utterances(utterances)
    formatted_lines = [format_utterance(u) for u in processed]
    normalized_text = "\n\n".join(formatted_lines) + ("\n" if formatted_lines else "")

    # Collect stats
    speakers: List[str] = []
    seen_speakers = set()
    timestamps: List[str] = []
    for u in processed:
        if u.speaker and u.speaker not in seen_speakers:
            seen_speakers.add(u.speaker)
            speakers.append(u.speaker)
        if u.start:
            timestamps.append(u.start)

    first_ts = timestamps[0] if timestamps else None
    last_ts = timestamps[-1] if timestamps else None
    est_chunks = max(1, (len(normalized_text) + args.max_chars - 1) // args.max_chars)

    if args.stats or (not args.normalize and not args.chunk_dir):
        stats = {
            "file": str(path),
            "directory": str(path.parent),
            "prefix": path.stem,
            "detected_format": fmt,
            "raw_lines": len(raw.splitlines()),
            "raw_chars": len(raw),
            "utterances_before_merge": len(utterances),
            "utterances_after_merge": len(processed),
            "normalized_chars": len(normalized_text),
            "has_timestamps": bool(timestamps),
            "first_timestamp": first_ts,
            "last_timestamp": last_ts,
            "speaker_count": len(speakers),
            "speakers": speakers[:50],
            "recommended_chunking": len(normalized_text) > 15000,
            "estimated_chunks": est_chunks,
        }
        print(json.dumps(stats, ensure_ascii=False, indent=2))

    if args.normalize:
        if args.out:
            out_path = Path(args.out).expanduser()
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_text(normalized_text, encoding="utf-8")
            print(f"Wrote normalized transcript ({len(normalized_text)} chars) to {out_path}")
        else:
            sys.stdout.write(normalized_text)

    if args.chunk_dir:
        chunk_dir = Path(args.chunk_dir).expanduser()
        chunk_dir.mkdir(parents=True, exist_ok=True)
        chunks = chunk_lines(formatted_lines, max_chars=args.max_chars)
        manifest = []
        for idx, ch in enumerate(chunks, start=1):
            chunk_file = chunk_dir / f"chunk_{idx:02d}.txt"
            content = "\n\n".join(ch) + "\n"
            chunk_file.write_text(content, encoding="utf-8")
            manifest.append({"chunk": idx, "path": str(chunk_file), "chars": len(content), "utterances": len(ch)})
        manifest_path = chunk_dir / "manifest.json"
        manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
        print(json.dumps({"chunk_dir": str(chunk_dir), "chunk_count": len(chunks), "chunks": manifest}, ensure_ascii=False, indent=2))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
