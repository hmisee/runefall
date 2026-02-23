@echo off
echo Generating placeholder backgrounds...
echo.

REM Check for GODOT_PATH environment variable first
if defined GODOT_PATH (
    set GODOT_EXE=%GODOT_PATH%
    goto :run_script
)

REM Check common locations
if exist "C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe
    goto :run_script
)

if exist "C:\Godot\Godot_v4.6.1-stable_win64_console.exe" (
    set GODOT_EXE=C:\Godot\Godot_v4.6.1-stable_win64_console.exe
    goto :run_script
)

REM Try godot in PATH
where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set GODOT_EXE=godot
    goto :run_script
)

echo ERROR: Godot executable not found!
echo Please set GODOT_PATH environment variable or add godot to your PATH
exit /b 1

:run_script
"%GODOT_EXE%" --headless -s tools/generate_placeholder_backgrounds.gd

echo.
pause
