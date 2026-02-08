# TikTok API Verification Guide

**Date:** February 8, 2026
**Platform:** TikTok for Developers
**Portal:** https://developers.tiktok.com/

---

## 📋 Overview

This guide describes the complete process to obtain API access for TikTok's developer platform, including app registration, permissions request, and audit process.

---

## 🎯 What You Need

### For Developer Account:
- ✅ TikTok account (personal or business)
- ✅ Valid email address for verification
- ✅ Business details (name, website, description)

### For App Registration:
- ✅ **Mobile app:** Link to App Store and/or Google Play Store
- ✅ **Web app:** Valid redirect URI (HTTPS)
- ✅ Working prototype of your application
- ✅ Clear use case description per permission

---

## 📝 Step 1: Create Developer Account

### Process

1. **Go to TikTok for Developers**
   - URL: https://developers.tiktok.com/
   - Click "Register" or "Get Started"

2. **Select Account Type**
   - **Individual:** For personal projects/hobby apps
   - **Organization:** For companies and commercial apps

3. **Fill Developer Profile**
   - Email
   - Name
   - Website
   - Description

4. **Confirm Email**
   - Check inbox (and spam folder)
   - Click verification link
   - Account is now active

---

## 🚀 Step 2: Register App

### Process

1. **Go to "Manage Apps"**
   - Log in to developer portal
   - Click "Create an app"

2. **Fill App Details**

   **Basic Information:**
   - **App name:** Name of your application
   - **App description:** What does your app do?

   **App Type:**

   - **Web App:**
     - Fill in redirect URI
     - Must be HTTPS
     - Example: `https://your-app.com/auth/tiktok/callback`

   - **Mobile App (iOS):**
     - App Store URL (app must be published)
     - Bundle ID
     - iOS Universal Link

   - **Mobile App (Android):**
     - Google Play Store URL (app must be published)
     - Package name
     - SHA-256 fingerprint

3. **Submit App Info**
   - Review all details
   - Click "Create app"
   - You'll receive Client Key and Client Secret (store securely!)

---

## ⚠️ IMPORTANT: Mobile App Requirements

### For iOS Apps:
- ✅ App **MUST** be in Apple App Store
- ✅ Not in beta/TestFlight - fully published
- ✅ Publicly available (no private/enterprise apps)

### For Android Apps:
- ✅ App **MUST** be in Google Play Store
- ✅ Not in internal/closed testing - fully published
- ✅ Publicly available

### For Web Apps:
- ✅ Valid redirect URI with HTTPS
- ✅ Website must be accessible
- ✅ Privacy policy publicly available

---

## 🔑 Step 3: Request API Permissions

TikTok follows **minimum permissions principle**: request ONLY what you truly need.

### Available API Products

#### 1️⃣ **Login Kit**
- Basic user info
- Profile picture and username

**Scopes:**
- `user.info.basic`

#### 2️⃣ **Content Posting API**
- Post videos on behalf of user
- Schedule videos
- Add captions and hashtags

**Scopes:**
- `video.publish`
- `video.list`

#### 3️⃣ **Data API (Analytics)**
- Video statistics
- Account analytics
- Engagement metrics

**Scopes:**
- `video.insights`
- `user.insights`

---

## 📤 Step 4: Permission Request Submission

### Process

1. **Go to App Dashboard**
   - Select your app
   - Click "Add products"

2. **Select API Products**
   - Choose desired products
   - For each product: select specific scopes

3. **For Each Permission: Detailed Use Case**

   Describe EXACTLY:
   - What does your app do?
   - Why do you need this permission?
   - How does this improve user experience?
   - Which feature uses this permission?

4. **Submit for Review**
   - **Wait time: 5-14 days**

---

## 🔍 Step 5: Audit Process (For Production)

To post public content, you must go through TikTok's audit process.

### When to Request Audit?

✅ **Ready for audit when:**
- Development testing is complete
- All features work flawlessly
- Security audit is done
- Privacy policy is complete
- Ready for production launch

### Audit Process

1. **Prepare Documentation**
   - Complete feature documentation
   - Screenshots of all features
   - Video demo (required, max 15 minutes)
   - Security documentation

2. **Submit Audit Request**
   - **Timeline:** 7-14 days

3. **After Approval**
   - ✅ Production mode active
   - ✅ Content is publicly visible
   - ✅ Full API access
   - ✅ Ready for launch

---

## ⏱️ Complete Timeline

| Phase | Duration |
|-------|----------|
| **Developer Account** | 5-10 min |
| **App Registration** | 10-20 min |
| **Permission Request** | 5-14 days |
| **Development Testing** | 2-4 weeks |
| **Audit Submission** | 7-14 days |
| **Total** | **4-8 weeks** |

---

## 📊 Rate Limits

### API Rate Limits (Production)

| Endpoint Type | Limit |
|---------------|-------|
| **Video Upload** | 10 per day per user |
| **Video List** | 100 calls per day |
| **User Info** | 1000 calls per day |
| **Analytics** | 500 calls per day |

---

## 🚨 Common Mistakes

### ❌ Mistake 1: App Not in App Store
**Problem:** App submission without public app store listing
**Solution:** Publish first in App Store/Play Store, then request TikTok API

### ❌ Mistake 2: Too Broad Permissions
**Problem:** "We want everything for future features"
**Solution:** Request ONLY permissions you need NOW, expand later

### ❌ Mistake 3: Vague Use Case
**Problem:** "We're making a social media app"
**Solution:** Be specific: which feature, why this permission, how it helps users?

---

## ✅ Complete Checklist

### Before Starting:
- [ ] TikTok developer account created
- [ ] Email verified
- [ ] Business details complete

### App Registration:
- [ ] App name chosen (unique, no "TikTok")
- [ ] App description written (>50 chars)
- [ ] **Mobile:** App published in App Store/Play Store
- [ ] **Web:** Redirect URI configured (HTTPS)
- [ ] Client Key and Secret securely stored

### Permissions:
- [ ] Minimum permissions selected
- [ ] Use case per permission written
- [ ] Privacy policy publicly available

### Development:
- [ ] OAuth flow tested
- [ ] API calls tested
- [ ] Error handling robust
- [ ] Rate limiting implemented

### Audit (Production):
- [ ] Minimum 2 weeks development testing
- [ ] All bugs fixed
- [ ] Complete documentation prepared
- [ ] Video demo created (max 15min)
- [ ] Audit requested

---

**Document Version:** 1.0
**Last Updated:** February 8, 2026
