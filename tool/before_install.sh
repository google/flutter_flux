#!/bin/bash

# Fast fail the script on failures.
set -e

echo "Downloading Flutter"

# Run doctor to download the Dart SDK that is vendored with Flutter
# disable analytics on the bots and download Flutter dependencies

(cd ..; git clone https://github.com/flutter/flutter.git -b master ; cd flutter ; ./bin/flutter config --no-analytics ; ./bin/flutter doctor)

