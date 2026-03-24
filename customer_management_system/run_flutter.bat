@echo off
REM Set TEMP directory to F: drive to avoid C: drive space issues
set TMP=F:\Temp
set TEMP=F:\Temp

REM Create temp directory if it doesn't exist
if not exist "F:\Temp" mkdir "F:\Temp"

REM Ensure MongoDB data directory exists on F:
if not exist "F:\MongoDB\data" mkdir "F:\MongoDB\data"

REM Start MongoDB if port 27017 is not listening
powershell -NoProfile -Command "if (-not (Get-NetTCPConnection -LocalPort 27017 -State Listen -ErrorAction SilentlyContinue)) { Start-Process powershell -ArgumentList '-NoExit','-Command','& ''C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe'' --dbpath ''F:\MongoDB\data'' --port 27017' }"

REM Start backend if port 3000 is not listening
powershell -NoProfile -Command "if (-not (Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue)) { Start-Process powershell -ArgumentList '-NoExit','-Command','cd /d F:\backend_cms; node server.js' }"

REM Give background services a moment to start
timeout /t 3 >nul


REM Run Flutter
cd /d "f:\FlutterProjects\customer_management_system"
flutter run -d web-server --web-port 8080

pause
