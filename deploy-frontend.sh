#!/bin/bash

# E-Commerce Deployment Script
# This script helps deploy the Flutter frontend to Vercel

set -e

echo "======================================"
echo "E-Commerce Frontend Deployment Script"
echo "======================================"
echo ""

# Check if backend URL is provided
if [ -z "$1" ]; then
    echo "❌ Error: Backend URL is required!"
    echo ""
    echo "Usage: ./deploy-frontend.sh <BACKEND_URL> [RAZORPAY_KEY]"
    echo ""
    echo "Example:"
    echo "  ./deploy-frontend.sh https://your-backend.up.railway.app rzp_live_xxxx"
    echo ""
    exit 1
fi

BACKEND_URL="$1"
RAZORPAY_KEY="${2:-rzp_test_SRtdBQxL8DjzHK}"

echo "Configuration:"
echo "  Backend URL: $BACKEND_URL"
echo "  Razorpay Key: $RAZORPAY_KEY"
echo ""

# Navigate to frontend directory
echo "📁 Navigating to frontend directory..."
cd store_frontend

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build Flutter web app with production settings
echo "🔨 Building Flutter web app for production..."
flutter build web --release \
    --web-renderer canvaskit \
    --dart-define=API_BASE_URL="${BACKEND_URL}/api" \
    --dart-define=RAZORPAY_KEY_ID="$RAZORPAY_KEY"

echo "✅ Build completed successfully!"
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI is not installed!"
    echo "Install it with: npm install -g vercel"
    exit 1
fi

# Deploy to Vercel
echo "🚀 Deploying to Vercel..."
cd build/web
vercel --prod

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Update CORS in backend to allow your Vercel domain"
echo "  2. Test your application"
echo "  3. Monitor logs for any issues"
echo ""
