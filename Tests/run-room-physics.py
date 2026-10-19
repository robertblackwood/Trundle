#!/usr/bin/env python3
"""Run app and physics regressions in a booted iOS simulator.

Usage: python3 Tests/run-room-physics.py [simulator UUID]
       [--level-actions | --gameplay-rendering | --spotlight-rendering | --universal]
       [--build-directory /tmp/trundle-universal-build]
Builds in a temporary directory and substitutes the regression's main function
when linking a standalone simulator executable. The game target is unchanged.
"""
import argparse
import pathlib
import plistlib
import platform
import shlex
import shutil
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("device", nargs="?", default="booted")
parser.add_argument("--universal", action="store_true",
                    help="check phone/tablet resources, included packs, and layout")
parser.add_argument("--build-directory", type=pathlib.Path,
                    help="reuse a derived-data directory for regression runs")
parser.add_argument("--level-actions", action="store_true",
                    help="check the room-16 XML dialogue and lightning sequence")
parser.add_argument("--gameplay-rendering", action="store_true",
                    help="check room-19 turret aiming and level-2 Theo rendering")
parser.add_argument("--spotlight-rendering", action="store_true",
                    help="check spotlight positioning, fading, and OpenGL state")
args = parser.parse_args()
if sum((args.level_actions, args.gameplay_rendering, args.spotlight_rendering, args.universal)) > 1:
    parser.error("Choose one regression mode per run")
device = args.device
architecture = platform.machine()
if architecture not in ("arm64", "x86_64"):
    parser.error(f"Unsupported simulator host architecture: {architecture}")

with tempfile.TemporaryDirectory(prefix="trundle-room-physics-") as directory:
    work = pathlib.Path(directory)
    build_directory = args.build_directory or work / "build"
    build = subprocess.run(
        ["xcodebuild", "-project", "Trundle.xcodeproj", "-scheme", "Trundle ∞",
         "-configuration", "Debug", "-sdk", "iphonesimulator", "-destination",
         "generic/platform=iOS Simulator", "-derivedDataPath", str(build_directory),
         f"ARCHS={architecture}", "ONLY_ACTIVE_ARCH=YES", "CODE_SIGNING_ALLOWED=NO",
         "LD_GENERATE_MAP_FILE=YES", f"LD_MAP_FILE_PATH={work / 'game.map'}", "build"],
        cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
    )
    if build.returncode:
        print(build.stdout[-16000:], file=sys.stderr)
        sys.exit(build.returncode)

    link = next(shlex.split(line.strip()) for line in build.stdout.splitlines()
                if "/clang++ " in line and f"-target {architecture}-apple-ios" in line)
    sdk = link[link.index("-isysroot") + 1]
    headers = set()
    for base in ("External Source/cocos2d", "External Source/kazmath/include",
                 "External Source/external/Chipmunk/include", "Support",
                 "Game Source", "Base Source"):
        headers.add(root / base)
        headers.update(path.parent for path in (root / base).rglob("*.h"))
    includes = [arg for path in sorted(headers) for arg in ("-I", str(path))]
    obj = work / "RoomPhysics.o"
    subprocess.run(
        ["xcrun", "clang", "-target", f"{architecture}-apple-ios15.6-simulator",
         "-isysroot", sdk, "-O0", "-g", "-Wno-deprecated-declarations",
         "-Wno-property-attribute-mismatch", "-c",
         str(root / "Tests" / ("UniversalApp.m" if args.universal else
                              "SpotlightRendering.m" if args.spotlight_rendering else
                              "GameplayRendering.m" if args.gameplay_rendering else
                              "LevelActions.m" if args.level_actions else "RoomPhysics.m")),
         "-o", str(obj), *includes, *([] if args.universal else ["-Dmain=TrundleRegressionMain"])],
        check=True, cwd=root,
    )

    index = link.index("-filelist") + 1
    original = pathlib.Path(link[index]).read_text().splitlines()
    objects = [path for path in original if not path.endswith("/main.o")]
    assert len(objects) == len(original) - 1, "Expected exactly one game entry point"
    objects.append(str(obj))
    if not args.universal:
        runner = work / "SimulatorRunner.o"
        subprocess.run(
            ["xcrun", "clang", "-target", f"{architecture}-apple-ios15.6-simulator",
             "-isysroot", sdk, "-c", str(root / "Tests/SimulatorRunner.m"), "-o", str(runner)],
            check=True, cwd=root,
        )
        objects.append(str(runner))
    filelist = work / "RoomPhysics.LinkFileList"
    filelist.write_text("\n".join(objects) + "\n")
    link[index] = str(filelist)
    app = work / "Regression.app"
    shutil.copytree(build_directory / "Build/Products/Debug-iphonesimulator/Trundle ∞.app", app)
    binary = app / "Trundle ∞"
    link[link.index("-o") + 1] = str(binary)
    subprocess.run(link, check=True, cwd=root)
    info_path = app / "Info.plist"
    info = plistlib.loads(info_path.read_bytes())
    identifier = "org.example.trundle.regression"
    info["CFBundleIdentifier"] = identifier
    info_path.write_bytes(plistlib.dumps(info))
    subprocess.run(["xcrun", "simctl", "install", device, str(app)], check=True, timeout=120)
    try:
        result = subprocess.run(
            ["xcrun", "simctl", "launch", "--console", "--terminate-running-process", device, identifier],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=120,
        )
    finally:
        subprocess.run(["xcrun", "simctl", "uninstall", device, identifier],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=60)
    print(result.stdout)
    if result.returncode or "PASS:" not in result.stdout:
        sys.exit(result.returncode or 1)
