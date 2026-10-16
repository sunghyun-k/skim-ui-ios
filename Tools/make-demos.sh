#!/bin/bash
# README 데모 애니메이션을 만든다 → Tools/out/demo-<이름>.webp (다크 모드, 2배 해상도, 손실 q85 — 데모별 예외는 QUALITY)
# `Tools/Demos`의 UI 테스트가 데모 화면을 손가락으로 만지는 동안 시뮬레이터를 녹화하고,
# 테스트가 찍은 표시(DEMO … sync/begin/end)로 데모마다 시간과 무대 영역을 잘라 낸다.
# 영상의 시각은 테스트 시계와 어긋나므로, 데모마다 왼쪽 위 `SyncMark`가 번쩍인 프레임으로 맞춘다.
# 저장소에는 넣지 않는다. GitHub 이슈 댓글에 올려 생긴 주소를 README에 쓴다.
# 사용법: Tools/make-demos.sh [데모 이름 …]  (기본: 전부. 예: toast slider)
#         SIMULATOR="iPhone 18 Pro Max" Tools/make-demos.sh
# 필요: ffmpeg, img2webp (`brew install ffmpeg webp`)
set -euo pipefail
for tool in ffmpeg img2webp; do
    command -v "$tool" >/dev/null || { echo "$tool 이 없다: brew install ffmpeg webp" >&2; exit 1; }
done
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap '[ -n "${KEEP:-}" ] || rm -rf "$WORK"' EXIT
[ -n "${KEEP:-}" ] && echo "작업 폴더: $WORK" >&2

UDID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
for runtime, devices in sorted(json.load(sys.stdin)["devices"].items(), reverse=True):
    if "iOS" not in runtime:
        continue
    for d in devices:
        if (name and d["name"] == name) or (not name and d["name"].startswith("iPhone")):
            print(d["udid"]); sys.exit()
' "${SIMULATOR:-}")
[ -n "$UDID" ] || { echo "시뮬레이터를 찾지 못했다: ${SIMULATOR:-iPhone}" >&2; exit 1; }
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" >/dev/null
xcrun simctl ui "$UDID" appearance dark

ONLY=()
for demo in "$@"; do
    ONLY+=("-only-testing:DemosUITests/DemoTests/test$(tr '[:lower:]' '[:upper:]' <<<"${demo:0:1}")${demo:1}")
done

cd "$ROOT/Tools/Demos"
XCB=(-project Demos.xcodeproj -scheme Demos -destination "id=$UDID" -derivedDataPath "$WORK/build")
xcodebuild build-for-testing "${XCB[@]}" -quiet

xcrun simctl io "$UDID" recordVideo --codec h264 --force "$WORK/all.mov" 2>"$WORK/record.log" &
rec=$!
until grep -q "Recording started" "$WORK/record.log"; do sleep 0.05; done

xcodebuild test-without-building "${XCB[@]}" ${ONLY[@]+"${ONLY[@]}"} >"$WORK/test.log" 2>&1 || {
    grep -E "error:|failed" "$WORK/test.log" >&2 || true
}
kill -INT "$rec"
wait "$rec" || true

mkdir -p "$ROOT/Tools/out"
python3 - "$WORK/all.mov" "$ROOT/Tools/out" "$WORK/test.log" "$WORK" <<'EOF'
import json, os, re, subprocess, sys

video, out_dir, log, work = sys.argv[1:5]
probe = subprocess.run(
    ["ffprobe", "-v", "error", "-select_streams", "v", "-show_entries", "stream=width",
     "-of", "json", video], capture_output=True, text=True, check=True)
video_width = json.loads(probe.stdout)["streams"][0]["width"]

demos = {}
for line in open(log):
    parts = line.split()
    if len(parts) >= 4 and parts[0] == "DEMO":
        demos.setdefault(parts[1], {})[parts[2]] = [float(p) for p in parts[3:]]
demos = {n: m for n, m in demos.items() if {"sync", "begin", "end"} <= m.keys()}
if not demos:
    sys.exit("표시가 없다 (테스트 실패?)")

# SyncMark(왼쪽 위 24pt 네모, x16 y70)가 자홍색으로 바뀌는 프레임들.
screen = next(iter(demos.values()))["begin"][5]
scale = video_width / screen
box = f"crop={int(12 * scale)}:{int(12 * scale)}:{int(22 * scale)}:{int(76 * scale)}"
stats = subprocess.run(
    ["ffmpeg", "-v", "error", "-i", video, "-vf",
     f"{box},signalstats,metadata=print:file=-", "-f", "null", "-"],
    capture_output=True, text=True, check=True).stdout
flashes, time, lit = [], None, False
for line in stats.splitlines():
    if m := re.search(r"pts_time:([\d.]+)", line):
        time = float(m.group(1))
    elif m := re.search(r"UAVG=([\d.]+)", line):
        u = float(m.group(1))
    elif m := re.search(r"VAVG=([\d.]+)", line):
        on = u > 190 and float(m.group(1)) > 210  # 자홍 (Y 105, U 212, V 235)
        if on and not lit:
            flashes.append(time)
        lit = on

order = sorted(demos, key=lambda n: demos[n]["sync"][0])
if len(flashes) != len(order):
    sys.exit(f"번쩍임 {len(flashes)}번, 데모 {len(order)}개 — 맞출 수 없다")

even = lambda v: int(round(v / 2)) * 2
# 기본은 손실 q85 (q70은 움직인 자리에 잔상이 남았다). 어두운 면 위 옅은 그라데이션(shimmer)은 손실에서 띠·블록이 져서 거의 무손실로.
QUALITY = {"skeleton": ["-near_lossless", "60"]}
for name, flash in zip(order, flashes):
    marks = demos[name]
    offset = flash - marks["sync"][0]  # 테스트 시각 + offset = 영상 시각
    print(f"{name}: 영상 {flash:.2f}초 = 테스트 시각 + {offset:.2f}", file=sys.stderr)
    begin, x, y, w, h, _ = marks["begin"]
    end = marks["end"][0]
    crop = f"crop={even(w * scale)}:{even(h * scale)}:{even(x * scale)}:{even(y * scale)}"
    frames = f"{work}/frames-{name}"
    # 녹화는 화면이 바뀔 때만 프레임을 쓴다. 가만히 있는 구간에도 프레임이 있도록 번쩍임 조금 앞부터 읽어
    # 고정 프레임으로 채운 다음 자른다 (바로 자르면 첫 프레임이 다음 변화 순간으로 당겨진다).
    seek = max(flash - 0.3, 0)
    trim = f"trim=start={begin + offset - seek:.3f}:end={end + offset - seek:.3f},setpts=PTS-STARTPTS"
    # README에는 pt의 2배 해상도로 (화면 녹화는 3배)
    size = f"scale={even(w * 2)}:{even(h * 2)}:flags=lanczos"
    subprocess.run(["mkdir", "-p", frames], check=True)
    subprocess.run(
        ["ffmpeg", "-v", "error", "-y", "-ss", f"{seek:.3f}", "-i", video,
         "-vf", f"fps=30,{trim},{crop},{size}", f"{frames}/%04d.png"], check=True)
    path = f"{out_dir}/demo-{name}.webp"
    pngs = sorted(f"{frames}/{f}" for f in os.listdir(frames))
    subprocess.run(["img2webp", "-loop", "0", *QUALITY.get(name, ["-lossy", "-q", "85"]), "-m", "6",
                    "-d", "33", *pngs, "-o", path], check=True, capture_output=True)
    print(path)
EOF
