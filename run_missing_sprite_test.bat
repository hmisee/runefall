@echo off
REM Run missing sprite logging test

echo === Running Missing Sprite Logging Test ===
echo.

REM Check for GODOT_PATH environment variable first
if defined GODOT_PATH (
    set GODOT_EXE=%GODOT_PATH%
    goto :run_test
)

REM Check common locations
if exist "C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe
    goto :run_test
)

if exist "C:\Godot\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Godot\Godot_v4.6.1-stable_win64_console.exe
    goto :run_test
)

REM Try godot in PATH
where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set GODOT_EXE=godot
    goto :run_test
)

echo ERROR: Godot executable not found!
echo Please set GODOT_PATH environment variable or add godot to your PATH
exit /b 1

:run_test
"%GODOT_EXE%" --headless --script tests/run_missing_sprite_logging.gd

echo.
echo === Test complete ===
