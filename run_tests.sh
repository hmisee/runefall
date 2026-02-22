#!/bin/bash
# Run all Runefall unit tests

echo "=== Running Runefall Unit Tests ==="
echo ""

# Check for GODOT_PATH environment variable first
if [ -n "$GODOT_PATH" ]; then
    GODOT_EXE="$GODOT_PATH"
# Check common locations
elif [ -f "/c/Users/User/bin/Godot_v4.6.1-stable_win64_console.exe" ]; then
    GODOT_EXE="/c/Users/User/bin/Godot_v4.6.1-stable_win64_console.exe"
elif [ -f "/c/Godot/Godot_v4.6.1-stable_win64_console.exe" ]; then
    GODOT_EXE="/c/Godot/Godot_v4.6.1-stable_win64_console.exe"
# Try godot in PATH
elif command -v godot &> /dev/null; then
    GODOT_EXE="godot"
else
    echo "ERROR: Godot executable not found!"
    echo "Please set GODOT_PATH environment variable or add godot to your PATH"
    echo "Example: export GODOT_PATH=/c/path/to/Godot_v4.6.1-stable_win64_console.exe"
    exit 1
fi

# Run the tests
"$GODOT_EXE" --headless --script tests/run_tests.gd

echo ""
echo "=== Test run complete ==="
