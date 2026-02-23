@echo off
REM Ultra-quiet test runner - only shows summary and failures

if defined GODOT_PATH (
    set GODOT_EXE=%GODOT_PATH%
    goto :run
)

if exist "C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe
    goto :run
)

if exist "C:\Godot\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Godot\Godot_v4.6.1-stable_win64_console.exe
    goto :run
)

where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set GODOT_EXE=godot
    goto :run
)

echo ERROR: Godot not found. Set GODOT_PATH environment variable.
exit /b 1

:run
"%GODOT_EXE%" --headless --script tests/run_tests_quiet.gd 2>nul
exit /b %ERRORLEVEL%
