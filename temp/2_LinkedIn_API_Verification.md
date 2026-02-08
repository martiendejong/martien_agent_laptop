# LinkedIn API Verification Guide

**Date:** February 8, 2026
**Platform:** LinkedIn Developer Platform
**Portal:** https://developer.linkedin.com/

---

## 📋 Overview

This guide describes the complete process to obtain API access for LinkedIn's developer platform, including company page verification and API products request.

---

## 🎯 What You Need

### Prerequisites:
- ✅ LinkedIn Company Page (must already exist and be active)
- ✅ Super Admin rights on the Company Page
- ✅ Business email matching company domain
- ✅ Clear use case for API usage

---

## 📝 Step 1: Create App

### Process

1. **Go to LinkedIn Developer Portal**
   - URL: https://developer.linkedin.com/
   - Log in with your LinkedIn account (with Admin rights)

2. **Create New App**
   - Click "Create app" or "My Apps" → "Create app"

3. **Fill App Details**

   **Required fields:**
   - **App name:** Name of your application
   - **LinkedIn Page:** Select your Company Page (must be Admin)
   - **App logo:** Upload logo (300x300px minimum)
   - **Privacy policy URL:** Link to public privacy policy
   - **App description:** Describe what your app does
   - **App website:** URL of your application/website

4. **Accept LinkedIn API Terms**
   - Read and accept the API Terms of Service

5. **Create App**
   - Click "Create app"
   - You'll receive Client ID and Client Secret (store securely!)

---

## 🏢 Step 2: Company Page Verification

**IMPORTANT:** Company Page verification is **MANDATORY** before you can request API products.

### Process

1. **Go to App Settings**
   - Select your app in "My Apps"
   - Click "Settings" tab

2. **Start Verification**
   - Under "App settings" find "Company Page verification"
   - Click "Verify"

3. **Generate Verification Link**
   - LinkedIn generates unique verification link
   - Link is automatically sent to Company Page Admin

4. **Company Page Admin Confirms**
   - Company Page Admin receives email or LinkedIn notification
   - Admin must log in and confirm verification
   - Verification happens via LinkedIn interface

5. **Wait for Confirmation**
   - **Timeline:** 1-3 days
   - Status visible in App Settings
   - ✅ "Verified" badge appears next to Company Page

---

## 📦 Step 3: Select API Products

After Company Page verification, you can request API products.

### Available Products

#### 1️⃣ **Advertising API** (Mandatory for other APIs)

**What you can do:**
- Manage ad campaigns
- Fetch analytics
- Configure targeting
- Manage budgets and bidding

**Access Tiers:**
- **Development:** Limited calls, test accounts only
- **Standard:** Full functionality, production use

#### 2️⃣ **Community Management API**

**What you can do:**
- Post on behalf of Company Page
- Manage and reply to comments
- Fetch engagement statistics
- Content scheduling

**Access Tiers:**
- **Development:** Test with own account
- **Standard:** Production use

#### 3️⃣ **Lead Sync API**

**What you can do:**
- Integrate lead gen forms
- Automatically fetch leads
- CRM integrations

#### 4️⃣ **Conversions API**

**What you can do:**
- Track conversions
- Measure attribution
- Analyze ROI

---

## ✅ Step 4: Request Product

### Process

1. **Go to Products Tab**
   - In your app dashboard: "Products" tab
   - Click "+ Add product"

2. **Select Product**
   - Choose desired product (start with Advertising API)
   - Click "Request access"

3. **Fill Use Case**

   Describe EXACTLY what you'll do:
   - What functionality are you building?
   - What data do you need?
   - Why this specific API?
   - How does this help your users?

4. **Submit Application**
   - Review your answers
   - Click "Submit for review"

5. **Wait for Approval**
   - **Timeline:** 7-14 days

---

## 🔑 Step 5: Configure OAuth Scopes

Important scopes:
- `r_emailaddress` - User email
- `r_liteprofile` - Basic profile info
- `w_member_social` - Post on behalf of user
- `w_organization_social` - Post on behalf of organization
- `r_organization_social` - Read organization content

---

## ⏱️ Timeline

| Phase | Duration |
|-------|----------|
| **App Creation** | 5-10 min |
| **Company Verification** | 1-3 days |
| **Product Request (Development)** | 7-14 days |
| **Testing in Development** | 1-4 weeks |
| **Standard Tier Request** | 7-14 days |
| **Total** | **3-8 weeks** |

---

## 📊 Rate Limits (Standard Tier)

| Product | Limit per App | Limit per User |
|---------|---------------|----------------|
| **Community Management** | 500 calls/day | 100 calls/day |
| **Advertising API** | 1000 calls/day | 200 calls/day |

---

## ✅ Checklist

### Before Starting:
- [ ] LinkedIn Company Page exists
- [ ] You are Super Admin of Company Page
- [ ] Business email with company domain
- [ ] Clear use case defined

### App Setup:
- [ ] App created in developer portal
- [ ] App logo uploaded (300x300px)
- [ ] Privacy policy URL filled in
- [ ] OAuth redirect URIs configured

### Company Verification:
- [ ] Verification requested
- [ ] Admin confirmed
- [ ] "Verified" badge visible

### API Products:
- [ ] Right products selected
- [ ] Use case description complete
- [ ] Development tier approved

---

**Document Version:** 1.0
**Last Updated:** February 8, 2026
