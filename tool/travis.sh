#!/bin/bash

# Fast fail the script on failures.
set -e

# Use the version of Dart SDK from the Flutter repository instead of whatever
# version is in the PATH.
export PATH="../flutter/bin/cache/dart-sdk/bin:$PATH"

echo "Path to dart is:"
which dart

echo "Using Dart version:"
dart --version

../flutter/bin/flutter packages get

echo "Analyzing the extracted Dart libraries."

../flutter/bin/flutter analyze lib test

../flutter/bin/flutter test
