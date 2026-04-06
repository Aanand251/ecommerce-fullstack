@echo off
REM E-Commerce Frontend Deployment Script for Windows
REM This script helps deploy the Flutter frontend to Vercel

setlocal enabledelayedexpansion

echo ======================================
echo E-Commerce Frontend Deployment Script
echo ======================================
echo.

if "%~1"=="" (
    echo Error: Backend URL is required!
    echo.
    echo Usage: deploy-frontend.bat ^<BACKEND_URL^> [RAZORPAY_KEY]
    echo.
    echo Example:
    echo   deploy-frontend.bat https://your-backend.up.railway.app rzp_live_xxxx
    echo.
    exit /b 1
)

set BACKEND_URL=%~1
set RAZORPAY_KEY=%~2
if "%RAZORPAY_KEY%"=="" set RAZORPAY_KEY=rzp_test_SRtdBQxL8DjzHK

echo Configuration:
echo   Backend URL: %BACKEND_URL%
echo   Razorpay Key: %RAZORPAY_KEY%
echo.

REM Navigate to frontend directory
echo Navigating to frontend directory...
cd store_frontend

REM Install dependencies
echo Installing dependencies...
call flutter pub get

REM Build Flutter web app with production settings
echo Building Flutter web app for production...
call flutter build web --release --web-renderer canvaskit --dart-define=API_BASE_URL=%BACKEND_URL%/api --dart-define=RAZORPAY_KEY_ID=%RAZORPAY_KEY%

echo Build completed successfully!
echo.

REM Check if Vercel CLI is installed
where vercel >nul 2>nul
if %errorlevel% neq 0 (
    echo Vercel CLI is not installed!
    echo Install it with: npm install -g vercel
    exit /b 1
)

REM Deploy to Vercel
echo Deploying to Vercel...
cd build\web
call vercel --prod

echo.
echo Deployment completed!
echo.
echo Next steps:
echo   1. Update CORS in backend to allow your Vercel domain
echo   2. Test your application
echo   3. Monitor logs for any issues
echo.

endlocal
