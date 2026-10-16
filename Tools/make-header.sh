#!/bin/bash
# README 헤더를 다시 만든다 → Tools/out/header-{light,dark}.webp (무손실)
# 저장소에는 넣지 않는다. GitHub 이슈 댓글에 올려 생긴 주소를 README에 쓴다.
# 사용법: Tools/make-header.sh ["시뮬레이터 이름"]  (기본: 사용 가능한 첫 iPhone)
set -euo pipefail
command -v cwebp >/dev/null || { echo "cwebp 가 없다: brew install webp" >&2; exit 1; }
ROOT=$(cd "$(dirname "$0")/.." && pwd)
BUNDLE=local.skimui.headermaker
DERIVED=$(mktemp -d)
trap 'rm -rf "$DERIVED"' EXIT

NAME=${1:-}
UDID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
for runtime, devices in sorted(json.load(sys.stdin)["devices"].items(), reverse=True):
    if "iOS" not in runtime:
        continue
    for d in devices:
        if (name and d["name"] == name) or (not name and d["name"].startswith("iPhone")):
            print(d["udid"]); sys.exit()
' "$NAME")
[ -n "$UDID" ] || { echo "시뮬레이터를 찾지 못했다: ${NAME:-iPhone}" >&2; exit 1; }
xcrun simctl boot "$UDID" 2>/dev/null || true

cd "$ROOT/Tools/HeaderMaker.swiftpm"
xcodebuild -scheme HeaderMaker -destination "id=$UDID" -derivedDataPath "$DERIVED" build -quiet
xcrun simctl install "$UDID" "$DERIVED/Build/Products/Debug-iphonesimulator/HeaderMaker.app"

DATA=$(xcrun simctl get_app_container "$UDID" "$BUNDLE" data)
rm -f "$DATA"/Documents/*.png
xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
xcrun simctl launch "$UDID" "$BUNDLE" >/dev/null

for _ in $(seq 30); do
    [ -f "$DATA/Documents/header-dark.png" ] && break
    sleep 1
done
xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true

OUT="$ROOT/Tools/out"
mkdir -p "$OUT"
for name in header-light header-dark; do
    cwebp -quiet -lossless -z 9 "$DATA/Documents/$name.png" -o "$OUT/$name.webp"
done
ls -1 "$OUT"/{header-light,header-dark}.webp
