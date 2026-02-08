# Instagram API Verification Guide

**Date:** February 8, 2026
**Platform:** Instagram Graph API (via Meta)
**Portal:** https://developers.facebook.com/

---

## 📋 Overview

Instagram API is part of Meta's developer platform. You do **NOT need a separate Instagram developer account** - everything is managed via Facebook's developer portal.

---

## ⚠️ IMPORTANT: Instagram = Meta Platform

**What this means:**
- Instagram API is managed via developers.facebook.com
- You need Meta Business Verification (see Facebook guide)
- Instagram permissions are requested via Meta App Review
- Same process as Facebook, but with Instagram-specific permissions

**Prerequisites:**
- ✅ Meta developer account
- ✅ Facebook Business Verification (MANDATORY)
- ✅ Instagram Business Account (MANDATORY)
- ✅ Instagram account linked to Facebook Page

---

## 🎯 What You Need

### Required:

1. **Meta Developer Account**
   - Account on developers.facebook.com
   - See: Facebook Verification Guide for complete setup

2. **Business Verification (Meta)**
   - Business documentation
   - Business email address
   - See: Facebook Verification Guide § Business Verification

3. **Instagram Business Account**
   - ⚠️ NOT personal account - must be Business/Creator
   - Free to convert in Instagram app

4. **Facebook Page**
   - Instagram Business account must be linked to Facebook Page
   - Managed via Facebook Business Manager

---

## 📱 Step 1: Instagram Business Account Setup

### Convert Instagram Account to Business

1. **Open Instagram App**
   - Log in with your Instagram account

2. **Go to Settings**
   - Profile → Menu (☰) → Settings

3. **Switch to Professional Account**
   - Account → "Switch to Professional Account"
   - Choose "Business" (not Creator)

4. **Link to Facebook Page**
   - Settings → Account → Linked accounts → Facebook
   - Log in with Facebook
   - Select or create Facebook Page
   - ⚠️ You must be Admin of the Facebook Page

5. **Verify Linking**
   - Go to Facebook Page settings
   - Check that Instagram account is linked
   - Both sides must be connected

---

## 🔧 Step 2: Configure Meta App for Instagram

### Process

1. **Go to Meta Developer Portal**
   - URL: https://developers.facebook.com/
   - Log in with your account

2. **Select or Create App**
   - "My Apps" → Select existing app
   - Or create new app: "Create App" → "Business" type

3. **Add Instagram Product**
   - Dashboard → "+ Add Products"
   - Select "Instagram"
   - Click "Set Up"

4. **OAuth Redirect URIs**
   - Settings → Basic → "Add Platform"
   - Choose "Website"
   - Add redirect URIs:
     - Development: `https://localhost:5173/auth/instagram/callback`
     - Production: `https://your-app.com/auth/instagram/callback`

5. **Add Test Users**
   - Instagram → "Instagram Testers"
   - Add Instagram accounts for testing
   - Testers must accept via Instagram app

---

## 📊 Step 3: Understand Instagram APIs

### Instagram Graph API (Recommended) ✅

**For:** Business accounts only

**What you can do:**
- Publish content (posts, stories, reels)
- Media management
- Manage comments
- Insights & analytics
- Fetch mentions
- Hashtag research

**Scopes:**
- `instagram_basic` - Profile + media access
- `instagram_content_publish` - Post content
- `instagram_manage_comments` - Manage comments
- `instagram_manage_insights` - Fetch analytics

---

## 🔑 Step 4: Request Permissions

Instagram permissions are requested via Meta's App Review (same process as Facebook).

### Important Instagram Permissions

#### `instagram_basic`
**Grants:**
- Basic profile info (username, account ID)
- Media feed (photos, videos)
- Media metadata

#### `instagram_content_publish`
**Grants:**
- Publish photos
- Publish videos
- Post stories
- Publish reels

#### `instagram_manage_comments`
**Grants:**
- Read comments
- Reply to comments
- Hide/delete comments

#### `instagram_manage_insights`
**Grants:**
- Post analytics (likes, comments, reach)
- Account analytics (followers, impressions)
- Story insights
- Reel performance

---

## 🎬 Step 5: App Review Submission

### Process

1. **Go to App Review**
   - Dashboard → "App Review" → "Permissions and Features"

2. **Request Instagram Permissions**
   - Click "+ Request Advanced Access"
   - Select Instagram permissions

3. **For Each Permission: Video Walkthrough**

   **Must include:**
   - Instagram login flow
   - Permission usage
   - Data management
   - Security

   **Technical requirements:**
   - Max 10 minutes per permission
   - Screen recording
   - Use test accounts
   - No music/voice-over needed

4. **Describe Use Case**

5. **Provide Test Credentials**

6. **Submit**
   - **Wait time: 2-14 days**

---

## 📏 Step 6: Understand Rate Limits

### Instagram Graph API Rate Limits

**Per Instagram Account:**
- 200 API calls per hour
- Scales linearly: 10 accounts = 2000 calls/hour

**Per Endpoint:**
- Posting: 25 posts per day per account
- Comments: 60 replies per hour
- Insights: 200 requests per hour

---

## 🚨 Common Mistakes

### ❌ Mistake 1: Personal Account Used
**Problem:** Instagram Graph API works ONLY with Business accounts
**Solution:** Convert to Business account (see Step 1)

### ❌ Mistake 2: Not Linked to Facebook Page
**Problem:** API calls fail with "No linked Facebook Page"
**Solution:** Link Instagram Business account to Facebook Page

### ❌ Mistake 3: Skipped Business Verification
**Problem:** Permissions rejection - "Business verification required"
**Solution:** Complete Meta Business Verification first (see Facebook guide)

---

## ⏱️ Complete Timeline

| Phase | Duration |
|-------|----------|
| **Instagram Business Account** | 10 min |
| **Facebook Page Linking** | 5 min |
| **Meta Business Verification** | 3-7 days |
| **Instagram Product Setup** | 10 min |
| **Permission Request (App Review)** | 2-14 days |
| **Total** | **3-8 weeks** |

---

## 📊 Content Posting Specifications

### Photo Posts
- **Formats:** JPG, PNG
- **Size:** Max 8MB
- **Aspect Ratio:** 4:5, 1:1, 1.91:1
- **Caption:** Max 2200 characters
- **Hashtags:** Max 30

### Video Posts
- **Formats:** MP4, MOV
- **Size:** Max 100MB
- **Length:** 3 sec - 60 min
- **Caption:** Max 2200 characters

### Stories
- **Photo:** JPG, PNG (max 8MB)
- **Video:** MP4, MOV (max 100MB, 15 sec max)
- **Aspect Ratio:** 9:16
- **Duration:** 24 hours

### Reels
- **Format:** MP4, MOV
- **Size:** Max 1GB
- **Length:** 15-90 seconds
- **Aspect Ratio:** 9:16

---

## ✅ Complete Checklist

### Prerequisites:
- [ ] Meta developer account
- [ ] Meta Business Verification complete
- [ ] Instagram Business Account created
- [ ] Instagram linked to Facebook Page
- [ ] Facebook Page Admin rights

### App Setup:
- [ ] App created in Meta developer portal
- [ ] Instagram product added
- [ ] OAuth redirect URIs configured
- [ ] Test Instagram accounts added

### Permissions:
- [ ] Required permissions identified
- [ ] For each permission: video walkthrough created
- [ ] Use case descriptions written
- [ ] Test credentials prepared
- [ ] Privacy policy complete

---

**Document Version:** 1.0
**Last Updated:** February 8, 2026
**Requires:** Meta Business Verification (see Facebook guide)
