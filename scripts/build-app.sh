#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
cd "$project_dir"

mkdir -p "$project_dir/work/clang-cache" "$project_dir/work/swift-cache"
export CLANG_MODULE_CACHE_PATH="$project_dir/work/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$project_dir/work/clang-cache"
export XDG_CACHE_HOME="$project_dir/work/swift-cache"

swift build -c release --disable-sandbox

app_dir="$project_dir/dist/Receipt Archive.app"
executable="$project_dir/.build/release/ReceiptArchive"

mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"
cp "$executable" "$app_dir/Contents/MacOS/ReceiptArchive"
cp "$project_dir/resources/Info.plist" "$app_dir/Contents/Info.plist"
codesign --force --deep --sign - "$app_dir"

print "Built: $app_dir"
