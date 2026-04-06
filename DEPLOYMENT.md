# Deployment Guide

This guide will help you deploy your full-stack e-commerce application to production.

## Architecture Overview

- **Frontend**: Flutter Web (Vercel)
- **Backend**: Spring Boot (Railway/Render)
- **Database**: PostgreSQL (Railway/Neon/Supabase)

## Prerequisites

- Vercel account (https://vercel.com)
- Railway account (https://railway.app) or Render account (https://render.com)
- GitHub repository (already created)
- Flutter SDK installed locally
- Java 17+ and Maven installed locally

---

## Part 1: Deploy PostgreSQL Database

### Option A: Railway (Recommended)

1. **Sign up/Login to Railway**
   - Go to https://railway.app
   - Sign in with GitHub

2. **Create PostgreSQL Database**
   - Click "New Project"
   - Select "Provision PostgreSQL"
   - Note down the connection details

3. **Get Database Credentials**
   - Click on the PostgreSQL service
   - Go to "Connect" tab
   - Copy the connection URL (format: `postgresql://user:password@host:port/database`)

### Option B: Neon (Serverless PostgreSQL)

1. Go to https://neon.tech
2. Create a new project
3. Copy the connection string

### Option C: Supabase

1. Go to https://supabase.com
2. Create a new project
3. Go to Settings > Database
4. Copy the connection string

---

## Part 2: Deploy Spring Boot Backend

### Option A: Railway (Recommended)

1. **Create New Service**
   - In Railway dashboard, click "New"
   - Select "GitHub Repo"
   - Choose your `ecommerce-fullstack` repository

2. **Configure Build Settings**
   - Root Directory: `store`
   - Build Command: `mvn clean package -DskipTests`
   - Start Command: `java -jar target/store-0.0.1-SNAPSHOT.jar`

3. **Add Environment Variables**
   - Click on your service > Variables tab
   - Add the following:
   ```
   SPRING_DATASOURCE_URL=<your_postgresql_url>
   SPRING_DATASOURCE_USERNAME=<your_db_username>
   SPRING_DATASOURCE_PASSWORD=<your_db_password>
   JWT_SECRET=<your_jwt_secret_256_bits>
   RAZORPAY_KEY_ID=<your_razorpay_key>
   RAZORPAY_KEY_SECRET=<your_razorpay_secret>
   SERVER_PORT=8080
   ```

4. **Deploy**
   - Railway will automatically deploy
   - Note the public URL (e.g., `https://your-app.up.railway.app`)

### Option B: Render

1. **Create New Web Service**
   - Go to https://render.com
   - Click "New +" > "Web Service"
   - Connect your GitHub repository

2. **Configure**
   - Name: `ecommerce-backend`
   - Root Directory: `store`
   - Environment: `Java`
   - Build Command: `mvn clean package -DskipTests`
   - Start Command: `java -jar target/store-0.0.1-SNAPSHOT.jar`

3. **Add Environment Variables** (same as above)

4. **Deploy**
   - Click "Create Web Service"
   - Note the public URL

---

## Part 3: Deploy Flutter Frontend to Vercel

### Step 1: Build Flutter Web App

Navigate to the frontend directory:

```bash
cd store_frontend
```

Update API URL for production:

```bash
flutter build web --release --web-renderer canvaskit --dart-define=API_BASE_URL=https://your-backend-url.up.railway.app/api --dart-define=RAZORPAY_KEY_ID=your_razorpay_key
```

Replace `https://your-backend-url.up.railway.app` with your actual backend URL from Railway/Render.

### Step 2: Deploy to Vercel

#### Method 1: Using Vercel CLI (Recommended)

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   cd build/web
   vercel --prod
   ```

4. **Follow the prompts**
   - Setup and deploy? `Y`
   - Which scope? Choose your account
   - Link to existing project? `N`
   - Project name: `ecommerce-store`
   - Directory: `./` (current directory)
   - Override settings? `N`

#### Method 2: Using Vercel Dashboard

1. **Go to Vercel Dashboard**
   - Visit https://vercel.com/dashboard
   - Click "Add New..." > "Project"

2. **Import Repository**
   - Connect your GitHub account
   - Select `ecommerce-fullstack` repository
   - Click "Import"

3. **Configure Project**
   - Framework Preset: `Other`
   - Root Directory: `store_frontend/build/web`
   - Build Command: Leave empty (we built locally)
   - Output Directory: `./`

4. **Add Environment Variables**
   - Add `API_BASE_URL` with your backend URL
   - Add `RAZORPAY_KEY_ID` with your key

5. **Deploy**
   - Click "Deploy"
   - Wait for deployment to complete

---

## Part 4: Configure CORS in Backend

Update your backend to allow requests from Vercel domain:

1. **Update SecurityConfig.java** (if not already configured)

Add your Vercel URL to allowed origins:

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(Arrays.asList(
        "http://localhost:3000",
        "https://your-vercel-app.vercel.app" // Add your Vercel URL
    ));
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

2. **Commit and push** the changes to trigger a new deployment on Railway/Render

---

## Part 5: Test Your Deployment

1. **Backend Health Check**
   ```bash
   curl https://your-backend-url.up.railway.app/api/products
   ```

2. **Frontend**
   - Visit your Vercel URL
   - Test registration and login
   - Test product browsing
   - Test cart and checkout

---

## Environment Variables Summary

### Backend (Railway/Render)
```
SPRING_DATASOURCE_URL=postgresql://user:pass@host:port/db
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=your_password
JWT_SECRET=your_jwt_secret_minimum_256_bits
RAZORPAY_KEY_ID=rzp_live_xxx (use live keys for production)
RAZORPAY_KEY_SECRET=your_secret
SERVER_PORT=8080
```

### Frontend (Vercel)
```
API_BASE_URL=https://your-backend-url.up.railway.app/api
RAZORPAY_KEY_ID=rzp_live_xxx
```

---

## Troubleshooting

### Frontend can't connect to backend
- Check CORS configuration
- Verify backend URL is correct
- Check browser console for errors

### Database connection failed
- Verify database credentials
- Check if database is running
- Verify network connectivity

### Payment not working
- Ensure you're using correct Razorpay keys
- Check Razorpay webhook configuration
- Verify payment callbacks

---

## Production Checklist

- [ ] Database is deployed and accessible
- [ ] Backend is deployed with all environment variables
- [ ] Frontend is built with correct API_BASE_URL
- [ ] CORS is configured for Vercel domain
- [ ] Razorpay keys are for production (live keys)
- [ ] JWT secret is strong and secure
- [ ] Database connection string is using SSL
- [ ] Monitor logs for errors
- [ ] Test complete user flow

---

## Continuous Deployment

Both Railway and Vercel support automatic deployments:

- **Push to main branch** = Automatic deployment
- **Pull requests** = Preview deployments (Vercel)

For the frontend, you'll need to:
1. Build locally with production API URL
2. Commit the build output
3. Push to trigger Vercel deployment

Or set up GitHub Actions for automated builds.

---

## Useful Commands

### Build Flutter Web
```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-api.com/api
```

### Build Spring Boot
```bash
cd store
./mvnw clean package
```

### Test Backend Locally
```bash
java -jar target/store-0.0.1-SNAPSHOT.jar
```

### Deploy to Vercel
```bash
cd store_frontend/build/web
vercel --prod
```

---

## Support

If you encounter issues:
- Check Railway/Render logs for backend errors
- Check Vercel deployment logs for frontend issues
- Verify all environment variables are set correctly
- Ensure database is accessible from backend

---

**Note**: For production, always use HTTPS URLs and secure your environment variables properly.
