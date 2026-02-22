@echo off
REM Run all Runefall unit tests

echo === Running Runefall Unit Tests ===
echo.

REM Check for GODOT_PATH environment variable first
if defined GODOT_PATH (
    set GODOT_EXE=%GODOT_PATH%
    goto :run_tests
)

REM Check common locations
if exist "C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe
    goto :run_tests
)

if exist "C:\Godot\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Godot\Godot_v4.6.1-stable_win64_console.exe
    goto :run_tests
)

REM Try godot in PATH
where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set GODOT_EXE=godot
    goto :run_tests
)

echo ERROR: Godot executable not found!
echo Please set GODOT_PATH environment variable or add godot to your PATH
echo Example: set GODOT_PATH=C:\path\to\Godot_v4.6.1-stable_win64_console.exe
exit /b 1

:run_tests
"%GODOT_EXE%" --headless --script tests/run_tests.gd

echo.
echo === Test run complete ===
