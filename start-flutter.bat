@echo off
REM ============================================
REM  Palengke.ph - One-window Flutter launcher
REM  Backend runs hidden in background.
REM  Flutter runs in THIS window and opens Chrome.
REM ============================================

echo Starting backend in the background (hidden)...
start /min "" cmd /c "cd /d C:\Palengke\backend && npm run dev"

REM Give the backend a few seconds to connect to Aiven before Flutter starts
timeout /t 5 /nobreak >nul

echo Launching Flutter app in Chrome...
cd /d C:\Palengke\flutter_app
flutter run -d chrome
