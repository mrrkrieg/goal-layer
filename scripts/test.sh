#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache"
swift run --configuration release --scratch-path .build --disable-sandbox GoalLayerChecks
