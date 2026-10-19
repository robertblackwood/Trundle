#!/bin/sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
chipmunk_dir="$project_dir/External Source/external/Chipmunk"
binary=$(mktemp /tmp/trundle-static-floor.XXXXXX)
trap 'rm -f "$binary"' EXIT HUP INT TERM
xcrun clang -O3 -DNDEBUG -DCP_USE_CGPOINTS=0 \
    -I"$chipmunk_dir/include/chipmunk" \
    "$project_dir/Tests/StaticFloorPhysics.c" \
    "$chipmunk_dir"/src/*.c "$chipmunk_dir"/src/constraints/*.c \
    -o "$binary"
"$binary"
