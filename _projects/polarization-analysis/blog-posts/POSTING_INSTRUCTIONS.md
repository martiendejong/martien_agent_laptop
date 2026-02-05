# How to Post The Narcissism Pandemic Series to WordPress

**Status:** Ready to post (12 articles ready)
**Target:** martiendejong.nl (WordPress site)

---

## Step 1: Generate WordPress Application Password

Before running the posting script, you need to create an Application Password for API authentication.

### Generate Application Password:

1. **Log into WordPress Admin:**
   - Go to: https://martiendejong.nl/wp-admin/
   - Log in with your regular WordPress credentials

2. **Navigate to Your Profile:**
   - Click on "Users" → "Profile" in the left sidebar
   - OR go directly to: https://martiendejong.nl/wp-admin/profile.php

3. **Scroll to "Application Passwords" Section:**
   - Find the section near the bottom of your profile page
   - Enter a name like "Blog Posting Script" or "API Access"
   - Click "Add New Application Password"

4. **IMPORTANT: Copy the Password Immediately!**
   - WordPress will show you a password like: `xxxx xxxx xxxx xxxx xxxx xxxx`
   - **Copy this password NOW** - you can't view it again!
   - Store it securely

---

## Step 2: Run the Posting Script

### Option A: Set Environment Variables (Recommended)

```bash
# Set credentials (Windows PowerShell)
$env:WP_USERNAME = "your_wordpress_username"
$env:WP_APP_PASSWORD = "xxxx xxxx xxxx xxxx xxxx xxxx"

# Run script
cd C:\scripts\_projects\polarization-analysis\blog-posts
python post-to-wordpress.py
```

### Option B: Enter Credentials Interactively

```bash
# Just run the script - it will prompt you
cd C:\scripts\_projects\polarization-analysis\blog-posts
python post-to-wordpress.py
```

The script will ask for:
- WordPress username
- Application password (paste the one from Step 1)

---

## Step 3: Choose Draft or Publish

When you run the script, it will ask:

```
Post as DRAFT or PUBLISH? (draft/publish) [draft]:
```

- **draft** (recommended first time): Posts as drafts so you can review before publishing
- **publish**: Posts directly as public articles

**Recommendation:** Use `draft` first, review the posts in WordPress admin, then publish manually.

---

## Step 4: Review in WordPress Admin

After posting as drafts:

1. Go to: https://martiendejong.nl/wp-admin/edit.php
2. You'll see all 12 posts listed as "Draft"
3. Click each one to review:
   - Check formatting looks correct
   - Verify content is complete
   - Add featured images if desired
   - Add tags or additional categories
4. Click "Publish" when ready

---

## What the Script Does

The script will:

1. ✅ Authenticate with WordPress REST API
2. ✅ Create category "The Narcissism Pandemic" (if doesn't exist)
3. ✅ Post all 12 articles with proper titles:
   - "Part 01: You're Not Crazy, The System Is"
   - "Part 02: The Narcissism You Can't See"
   - ... etc.
4. ✅ Set excerpt: "Part XX of 12: The Narcissism Pandemic Series"
5. ✅ Assign to category
6. ✅ Create as drafts or publish (your choice)
7. ✅ Display success/failure for each post

---

## Expected Output

```
============================================================
WordPress Article Poster
The Narcissism Pandemic Series (12 posts)
============================================================

Testing authentication...
✅ Authentication successful!
Logged in as: Martien de Jong (@martien)

Setting up category...
✅ Category ID: 15

============================================================
Post as DRAFT or PUBLISH? (draft/publish) [draft]: draft
Will post as: DRAFT
============================================================

[1/12] Processing: You're Not Crazy, The System Is...
  ✅ SUCCESS: https://martiendejong.nl/?p=123

[2/12] Processing: The Narcissism You Can't See...
  ✅ SUCCESS: https://martiendejong.nl/?p=124

... (continues for all 12 posts)

============================================================
POSTING COMPLETE
============================================================

✅ Successful: 12/12
❌ Failed: 0/12
```

---

## Troubleshooting

### "Authentication failed"
- Check your WordPress username is correct
- Verify application password has no typos
- Ensure application password was copied correctly (no extra spaces)

### "Category creation failed"
- Your WordPress user needs "Editor" or "Administrator" role
- Check WordPress REST API is enabled (it should be by default)

### "Content extraction failed"
- Ensure HTML files exist in `html/` directory
- Check HTML files have `<article>` tags

### "Connection refused" or timeout
- Check internet connection
- Verify https://martiendejong.nl is accessible
- Check WordPress site isn't in maintenance mode

---

## Advanced: Customize Before Posting

If you want to customize posts before uploading, edit the script:

```python
# In post-to-wordpress.py, modify:

# Add featured image:
payload['featured_media'] = image_id

# Add custom tags:
payload['tags'] = [tag_id_1, tag_id_2]

# Set custom author:
payload['author'] = author_id

# Schedule for future:
payload['status'] = 'future'
payload['date'] = '2026-02-10T10:00:00'
```

---

## After Posting

### Publishing Schedule

If you posted as drafts, consider a publishing schedule:

- **Option 1: Drip Feed** - Publish 2 posts/week for 6 weeks
- **Option 2: Batch Publish** - Publish all 12 at once
- **Option 3: Feature Series** - Publish 1/day for 12 days

### Promotion Checklist

- [ ] Share on social media (Twitter/X, LinkedIn)
- [ ] Create thread summarizing series
- [ ] Cross-post to Medium/Substack
- [ ] Email newsletter to subscribers
- [ ] Post to relevant Reddit communities
- [ ] Create video versions for YouTube
- [ ] Update homepage to feature series

---

## Security Notes

⚠️ **Important:**

- Application passwords grant FULL API access to your WordPress site
- Keep them secret and secure
- Don't commit them to git repositories
- Revoke application passwords when no longer needed
- Use environment variables, never hardcode in scripts

To revoke an application password:
- Go to: https://martiendejong.nl/wp-admin/profile.php
- Find "Application Passwords" section
- Click "Revoke" next to the password you want to remove

---

## File Locations

```
C:\scripts\_projects\polarization-analysis\blog-posts\
├── post-to-wordpress.py           # ← Posting script
├── POSTING_INSTRUCTIONS.md        # ← This file
├── html\
│   ├── 01-youre-not-crazy.html   # ← 12 blog posts
│   ├── 02-narcissism-you-cant-see.html
│   └── ... (10 more)
└── markdown\                      # ← Original markdown versions
```

---

**Ready to go! Follow Step 1 to generate your application password, then run the script.**
