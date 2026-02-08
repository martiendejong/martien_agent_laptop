# Facebook / Meta API Verification Guide

**Date:** February 8, 2026
**Platform:** Facebook & Meta Developer Platform
**Portal:** https://developers.facebook.com/

---

## 📋 Overview

This guide describes the complete verification process to obtain API access for Facebook and Meta's developer platform. This process is also required for Instagram API access.

---

## 🎯 What You Need

### For Business Verification:
- ✅ Business documentation (business registration, business license)
- ✅ Business email address (preferably with own domain)
- ✅ Company website
- ✅ Business phone number

### For App Review:
- ✅ Working prototype of your application
- ✅ Test credentials for reviewers
- ✅ Video walkthroughs (screen recordings)
- ✅ Detailed use case descriptions

---

## 📝 Step 1: Business Verification

### Why Business Verification?

**IMPORTANT:** Business Verification is **MANDATORY** for Advanced Access (full API functionality).

- **Standard Access:** Very limited, only own accounts, strict rate limits → **UNUSABLE for production**
- **Advanced Access:** Full functionality → **Requires Business Verification + App Review**

### Process

1. **Go to Facebook Developer Portal**
   - URL: https://developers.facebook.com/
   - Log in with your Facebook account

2. **Select Your App**
   - Go to "My Apps"
   - Select existing app or create new app

3. **Start Business Verification**
   - Click "Business Verification" in left menu
   - Or go via App Settings → Basic → Business Verification

4. **Upload Documentation**

   **Acceptable documents:**
   - Business registration certificate
   - Business license
   - Tax registration documents
   - Articles of incorporation

   **Important tips:**
   - ✅ Documents must be recent (< 6 months old)
   - ✅ Business name must **exactly** match across all documents
   - ✅ Upload clear scans (no poor smartphone photos)
   - ✅ Use business email with own domain (@company.com, NOT @gmail.com)

5. **Wait for Approval**
   - **Timeline:** 3-7 days
   - You'll receive email upon approval/rejection
   - If rejected: improve documentation and resubmit

---

## ⚠️ Alternative: Individual Verification

If you don't have a business, you can apply for Individual Verification:

**Process:**
1. Select "Individual Verification"
2. Enter email address to receive contract
3. Upload ID (passport, driver's license, national ID)
4. Sign contract

**WARNING:**
- ❌ Certain permissions are limited or unavailable
- ❌ Not suitable for apps with many users
- ❌ Not suitable for production environments
- ✅ Only for personal/hobby projects

---

## 🎬 Step 2: App Review - Request Permissions

After Business Verification, you can request permissions (API access rights).

### Important Facebook Permissions

| Permission | Description | Use Case |
|------------|-------------|----------|
| `pages_manage_posts` | Post to Facebook Pages | Content scheduling, social media management |
| `pages_read_engagement` | Page analytics | Fetch statistics, measure engagement |
| `pages_show_list` | List of managed Pages | Select Pages for posting |
| `public_profile` | Basic user info | Login, identification |
| `email` | User email address | Account linking |

### Important Instagram Permissions (via Meta)

| Permission | Description | Use Case |
|------------|-------------|----------|
| `instagram_basic` | Profile info + media | Basic Instagram account access |
| `instagram_content_publish` | Publish content | Post photos, videos, stories |
| `instagram_manage_comments` | Manage comments | Reply to comments, moderation |
| `instagram_manage_insights` | Analytics | Statistics and insights |

---

## 🎥 Creating Video Walkthroughs (REQUIRED)

For **EVERY** permission you request, you must create a video walkthrough.

### What Should It Include?

1. **Complete User Flow**
   - User logs in with Facebook/Instagram
   - User grants permission (OAuth consent screen)
   - App uses the access (show exactly where data appears)

2. **Data Usage**
   - Show precisely which data you fetch
   - Show where data is stored
   - Demonstrate how user can delete data

3. **Security & Privacy**
   - Show HTTPS connection
   - Display privacy policy
   - Demonstrate data encryption (if applicable)

### Technical Requirements

- ✅ **Max length:** 10 minutes per permission
- ✅ **Format:** MP4, MOV, or AVI
- ✅ **Quality:** Screen recording is sufficient (no high production value needed)
- ✅ **Audio:** No voice-over or music needed
- ❌ **Test data:** Use test accounts, NO real user data

---

## 📤 App Review Submission

### Process

1. **Go to App Review**
   - In your app dashboard: "App Review" → "Permissions and Features"

2. **Request Permissions**
   - Click "+ Request Advanced Access"
   - Select desired permissions

3. **For Each Permission:**

   **a) Upload Video Walkthrough**
   - Upload your screen recording
   - Max 10 minutes per permission

   **b) Describe Use Case**
   - Why do you need this permission?
   - How is the data used?
   - How long do you store data?
   - Is data shared with third parties?

   **c) Provide Test Credentials**
   - Username + password for test account
   - Step-by-step instructions for reviewers
   - Ensure test account has full access

4. **Submit for Review**
   - Review everything
   - Click "Submit"
   - Wait for approval

### Review Timeline

**Duration:** 2-14 days

---

## ⏱️ Complete Timeline

| Phase | Duration | Status Tracking |
|-------|----------|-----------------|
| **Business Verification** | 3-7 days | Email notifications |
| **App Review** | 2-14 days | Dashboard → App Review → Status |
| **Total** | **5-21 days** | - |

---

## 🚨 Common Mistakes

### ❌ Mistake 1: Using Standard Access
**Problem:** Standard Access is too limited for production
**Solution:** Always request Advanced Access via App Review

### ❌ Mistake 2: Requesting Too Many Permissions
**Problem:** More permissions = slower review + higher rejection chance
**Solution:** Request ONLY permissions you truly need

### ❌ Mistake 3: Poor Video Walkthroughs
**Problem:** Unclear videos lead to rejection
**Solution:** Test your video before submitting (show to colleague)

### ❌ Mistake 4: No Test Credentials
**Problem:** Reviewers cannot test app
**Solution:** Create dedicated test account with full access

### ❌ Mistake 5: Outdated Business Documents
**Problem:** Documents older than 6 months are rejected
**Solution:** Download recent business registration certificate

---

## 📞 Support & Help

**Facebook Developer Support:**
- https://developers.facebook.com/support/
- Community Forum: https://developers.facebook.com/community/

**App Review Status:**
- Check in App Dashboard → App Review

---

## ✅ Checklist

### For Business Verification:
- [ ] Recent business registration (< 6 months)
- [ ] Business email with own domain
- [ ] Business website online and functional
- [ ] Business phone number

### For App Review:
- [ ] Working prototype of app
- [ ] For each permission: video walkthrough (< 10 min)
- [ ] Test account with full access
- [ ] Detailed use case descriptions
- [ ] Privacy policy publicly available
- [ ] Security measures implemented (HTTPS, encryption)

---

**Document Version:** 1.0
**Last Updated:** February 8, 2026
**Applies to:** Facebook, Instagram, WhatsApp (via Meta Platform)
