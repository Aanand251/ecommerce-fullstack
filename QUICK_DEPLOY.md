# Quick Deployment Guide

## 🚀 Quick Start Deployment

Follow these steps to deploy your application:

### Step 1: Deploy Database (5 minutes)

1. Go to https://railway.app and sign in
2. Click "New Project" → "Provision PostgreSQL"
3. Copy the connection string from the "Connect" tab
4. Keep this tab open - you'll need these credentials

### Step 2: Deploy Backend (10 minutes)

1. In Railway, click "New" → "GitHub Repo"
2. Select your `ecommerce-fullstack` repository
3. Click "Add variables" and add these:
   ```
   SPRING_DATASOURCE_URL=<paste your PostgreSQL URL>
   SPRING_DATASOURCE_USERNAME=<from Railway>
   SPRING_DATASOURCE_PASSWORD=<from Railway>
   JWT_SECRET=my_super_secret_jwt_key_must_be_at_least_256_bits
   RAZORPAY_KEY_ID=rzp_test_SRtdBQxL8DjzHK
   RAZORPAY_KEY_SECRET=38ExN81jERfQ1r0CmqC7JMh7
   SERVER_PORT=8080
   ```
4. Click "Deploy"
5. Wait for deployment (3-5 minutes)
6. Copy your backend URL (e.g., `https://xxx.up.railway.app`)

### Step 3: Deploy Frontend (5 minutes)

Run this command in your project root:

```bash
# Windows
deploy-frontend.bat https://your-backend-url.up.railway.app

# Mac/Linux
chmod +x deploy-frontend.sh
./deploy-frontend.sh https://your-backend-url.up.railway.app
```

Or manually:

```bash
cd store_frontend

# Build for production
flutter build web --release --web-renderer canvaskit --dart-define=API_BASE_URL=https://your-backend-url.up.railway.app/api

# Deploy to Vercel
cd build/web
vercel --prod
```

### Step 4: Update CORS (2 minutes)

After getting your Vercel URL, update the backend:

1. Open `store/src/main/java/com/example/store/security/SecurityConfig.java`
2. Add your Vercel URL to allowed origins
3. Commit and push - Railway will auto-deploy

### Step 5: Test! 🎉

Visit your Vercel URL and test:
- User registration
- Login
- Product browsing
- Add to cart
- Checkout

---

## 📋 Environment Variables Checklist

### Backend (Railway)
- [ ] SPRING_DATASOURCE_URL
- [ ] SPRING_DATASOURCE_USERNAME
- [ ] SPRING_DATASOURCE_PASSWORD
- [ ] JWT_SECRET
- [ ] RAZORPAY_KEY_ID
- [ ] RAZORPAY_KEY_SECRET
- [ ] SERVER_PORT=8080

### Frontend (Build Command)
- [ ] API_BASE_URL (your Railway backend URL)
- [ ] RAZORPAY_KEY_ID

---

## 🆘 Troubleshooting

**Backend won't start?**
- Check Railway logs for errors
- Verify all environment variables are set
- Ensure PostgreSQL is running

**Frontend can't connect to backend?**
- Check CORS configuration
- Verify API_BASE_URL is correct
- Check browser console for errors

**Deployment failed?**
- Check build logs in Railway/Vercel
- Verify GitHub repository is accessible
- Ensure all files are committed

---

## 📚 Full Documentation

For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 🔗 Useful Links

- Railway Dashboard: https://railway.app/dashboard
- Vercel Dashboard: https://vercel.com/dashboard
- Project Repository: https://github.com/Aanand251/ecommerce-fullstack
