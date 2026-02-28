#!/usr/bin/env python3
"""Generate lesson audio via ElevenLabs and upload to Supabase Storage."""

import os
import sys
import json
import httpx
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

# Load .env from scripts/ directory, fallback to project root
_script_dir = Path(__file__).resolve().parent
load_dotenv(_script_dir / ".env")
load_dotenv(_script_dir.parent / ".env")

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY")
ELEVENLABS_KEY = os.environ.get("ELEVENLABS_API_KEY")
VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "pNInz6obpgDQGcFmaJgB")
MODEL_ID = os.environ.get("ELEVENLABS_MODEL_ID", "eleven_multilingual_v2")
BUCKET = "lesson-audio"


def _validate_env() -> None:
    """Ensure required environment variables are set."""
    missing = []
    if not SUPABASE_URL:
        missing.append("SUPABASE_URL")
    if not SUPABASE_KEY:
        missing.append("SUPABASE_SERVICE_KEY")
    if not ELEVENLABS_KEY:
        missing.append("ELEVENLABS_API_KEY")
    if missing:
        print("Error: Missing required environment variables:", ", ".join(missing))
        print("Copy scripts/.env.example to scripts/.env and fill in the values.")
        sys.exit(1)


def extract_narration_text(content_blocks: list[dict]) -> str:
    """Build narration text from lesson content blocks, skipping code."""
    parts: list[str] = []
    for block in content_blocks:
        btype = block.get("type", "")
        if btype in ("heading", "heading2", "paragraph"):
            val = block.get("value", "")
            if isinstance(val, str) and val.strip():
                parts.append(val.strip())
        elif btype == "list":
            items = block.get("value", [])
            if isinstance(items, list):
                parts.append(". ".join(str(i) for i in items))
        elif btype == "callout":
            title = block.get("title")
            text = block.get("text") or block.get("value", "")
            if title:
                parts.append(f"{title}. {text}")
            elif text:
                parts.append(str(text))
        # Skip 'code' blocks — not suitable for narration
    return "\n\n".join(parts)


def generate_audio(text: str) -> bytes:
    """Call ElevenLabs TTS API and return MP3 bytes."""
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}"
    headers = {
        "xi-api-key": ELEVENLABS_KEY,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    }
    payload = {
        "text": text,
        "model_id": MODEL_ID,
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.4,
            "use_speaker_boost": True,
        },
    }
    resp = httpx.post(url, headers=headers, json=payload, timeout=120)
    resp.raise_for_status()
    return resp.content


def main() -> None:
    _validate_env()
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

    result = (
        supabase.table("lessons")
        .select("id, title, content")
        .not_.is_("content", "null")
        .is_("audio_url", "null")
        .execute()
    )
    lessons = result.data
    if not lessons:
        print("No lessons need audio generation.")
        return

    print(f"Found {len(lessons)} lesson(s) to process.\n")
    failed = 0

    for lesson in lessons:
        lesson_id = lesson["id"]
        title = lesson.get("title", "(no title)")
        content = lesson.get("content") or []
        if isinstance(content, str):
            try:
                content = json.loads(content)
            except json.JSONDecodeError as e:
                print(f"  [{lesson_id}] '{title}' — invalid JSON content: {e}")
                failed += 1
                continue

        text = extract_narration_text(content)
        if not text.strip():
            print(f"  [{lesson_id}] '{title}' — empty text, skipping")
            continue

        try:
            char_count = len(text)
            print(f"  [{lesson_id}] '{title}' — {char_count} chars")

            print("    Generating audio via ElevenLabs...")
            audio_bytes = generate_audio(text)
            print(f"    Audio generated: {len(audio_bytes) / 1024:.0f} KB")

            file_path = f"{lesson_id}.mp3"
            print(f"    Uploading to storage: {BUCKET}/{file_path}")
            supabase.storage.from_(BUCKET).upload(
                file_path,
                audio_bytes,
                {"content-type": "audio/mpeg", "upsert": True},
            )

            public_url = supabase.storage.from_(BUCKET).get_public_url(file_path)
            supabase.table("lessons").update({"audio_url": public_url}).eq("id", lesson_id).execute()
            print(f"    Done — URL saved\n")
        except httpx.HTTPStatusError as e:
            print(f"    ERROR: ElevenLabs API failed: {e.response.status_code} — {e.response.text[:200]}")
            failed += 1
        except Exception as e:
            print(f"    ERROR: {type(e).__name__}: {e}")
            failed += 1

    if failed:
        print(f"\nCompleted with {failed} failure(s).")
        sys.exit(1)
    print("All lessons processed.")


if __name__ == "__main__":
    main()
