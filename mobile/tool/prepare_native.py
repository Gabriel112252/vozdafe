#!/usr/bin/env python3
"""Apply platform privacy permissions after 'flutter create .'.
Idempotent: it can be run multiple times.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch_android() -> None:
    manifest = ROOT / "android/app/src/main/AndroidManifest.xml"
    if not manifest.exists():
        raise SystemExit("Execute flutter create . --platforms android,ios,web primeiro.")
    text = manifest.read_text(encoding="utf-8")
    additions = []
    for permission in ("android.permission.RECORD_AUDIO", "android.permission.INTERNET"):
        if f'android:name="{permission}"' not in text:
            additions.append(f'    <uses-permission android:name="{permission}" />')
    if "android.speech.RecognitionService" not in text:
        additions.append(
            '    <queries><intent><action android:name="android.speech.RecognitionService" /></intent></queries>'
        )
    if additions:
        root = text.find("<manifest")
        pos = text.find(">", root)
        if root < 0 or pos < 0:
            raise SystemExit("Manifesto Android inválido.")
        text = text[: pos + 1] + "\n" + "\n".join(additions) + text[pos + 1 :]
        manifest.write_text(text, encoding="utf-8")
    print("Android: RECORD_AUDIO, INTERNET, speech recognition queries OK")


def patch_ios() -> None:
    info = ROOT / "ios/Runner/Info.plist"
    if not info.exists():
        raise SystemExit("Execute flutter create . --platforms android,ios,web primeiro.")
    text = info.read_text(encoding="utf-8")
    permissions = {
        "NSMicrophoneUsageDescription": "O microfone permite contar como você está se sentindo usando sua voz.",
        "NSSpeechRecognitionUsageDescription": "O reconhecimento de fala transforma sua voz em uma mensagem para a reflexão.",
    }
    for key, description in permissions.items():
        if f"<key>{key}</key>" not in text:
            text = text.replace(
                "</dict>",
                f"    <key>{key}</key>\n    <string>{description}</string>\n</dict>",
                1,
            )
    info.write_text(text, encoding="utf-8")
    print("iOS: descrições de privacidade do microfone e reconhecimento OK")


if __name__ == "__main__":
    patch_android()
    patch_ios()
