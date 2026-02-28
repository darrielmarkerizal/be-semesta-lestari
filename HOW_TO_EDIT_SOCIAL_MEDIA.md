# How to Edit Social Media Links

There are 3 ways to edit social media links in the footer:

---

## Method 1: Using Admin Footer Endpoint (EASIEST) ⭐

This is the easiest way - update all social media links at once.

### Step 1: Get your authentication token

```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

Copy the `accessToken` from the response.

### Step 2: Update social media links

```bash
curl -X PUT http://localhost:3000/api/admin/footer \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "social_media": {
      "facebook": "https://facebook.com/yournewpage",
      "instagram": "https://instagram.com/yournewpage",
      "twitter": "https://twitter.com/yournewpage",
      "youtube": "https://youtube.com/@yournewpage",
      "linkedin": "https://linkedin.com/company/yournewpage",
      "tiktok": "https://tiktok.com/@yournewpage"
    }
  }'
```

**You can update just one platform:**

```bash
curl -X PUT http://localhost:3000/api/admin/footer \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "social_media": {
      "facebook": "https://facebook.com/newpage"
    }
  }'
```

---

## Method 2: Using Individual Settings Endpoint

Update one social media link at a time.

### Step 1: Get your token (same as Method 1)

### Step 2: Update a specific platform

**Update Facebook:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_facebook \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://facebook.com/newpage"}'
```

**Update Instagram:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_instagram \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://instagram.com/newpage"}'
```

**Update Twitter:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_twitter \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://twitter.com/newpage"}'
```

**Update YouTube:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_youtube \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://youtube.com/@newpage"}'
```

**Update LinkedIn:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_linkedin \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://linkedin.com/company/newpage"}'
```

**Update TikTok:**
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_tiktok \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://tiktok.com/@newpage"}'
```

---

## Method 3: Using Swagger UI (VISUAL INTERFACE) 🎨

This is the easiest if you prefer a visual interface.

### Step 1: Open Swagger UI

Go to: http://localhost:3000/api-docs/

### Step 2: Authenticate

1. Click the **"Authorize"** button at the top right
2. Login first to get token:
   - Find **POST /api/admin/auth/login** under "Admin - Auth"
   - Click "Try it out"
   - Enter:
     ```json
     {
       "email": "admin@semestalestari.com",
       "password": "admin123"
     }
     ```
   - Click "Execute"
   - Copy the `accessToken` from the response

3. Go back and click **"Authorize"** button
4. Enter: `Bearer YOUR_TOKEN_HERE`
5. Click "Authorize"

### Step 3: Update Social Media

**Option A: Update all at once**
1. Find **PUT /api/admin/footer** under "Admin - Footer"
2. Click "Try it out"
3. Edit the JSON:
   ```json
   {
     "social_media": {
       "facebook": "https://facebook.com/yournewpage",
       "instagram": "https://instagram.com/yournewpage",
       "twitter": "https://twitter.com/yournewpage",
       "youtube": "https://youtube.com/@yournewpage",
       "linkedin": "https://linkedin.com/company/yournewpage",
       "tiktok": "https://tiktok.com/@yournewpage"
     }
   }
   ```
4. Click "Execute"

**Option B: Update one at a time**
1. Find **PUT /api/admin/config/{key}** under "Admin - Settings"
2. Click "Try it out"
3. Enter key: `social_facebook` (or any other platform)
4. Enter value:
   ```json
   {
     "value": "https://facebook.com/newpage"
   }
   ```
5. Click "Execute"

---

## Quick Reference: Social Media Keys

| Platform | Key | Example URL |
|----------|-----|-------------|
| Facebook | `social_facebook` | `https://facebook.com/semestalestari` |
| Instagram | `social_instagram` | `https://instagram.com/semestalestari` |
| Twitter | `social_twitter` | `https://twitter.com/semestalestari` |
| YouTube | `social_youtube` | `https://youtube.com/@semestalestari` |
| LinkedIn | `social_linkedin` | `https://linkedin.com/company/semestalestari` |
| TikTok | `social_tiktok` | `https://tiktok.com/@semestalestari` |

---

## Complete Example Script

Save this as `update_social_media.sh`:

```bash
#!/bin/bash

# Configuration
EMAIL="admin@semestalestari.com"
PASSWORD="admin123"
BASE_URL="http://localhost:3000/api"

# Get token
echo "Getting authentication token..."
TOKEN=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
  | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "❌ Authentication failed"
    exit 1
fi

echo "✅ Authenticated"
echo ""

# Update social media links
echo "Updating social media links..."
curl -X PUT "$BASE_URL/admin/footer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "social_media": {
      "facebook": "https://facebook.com/semestalestari",
      "instagram": "https://instagram.com/semestalestari",
      "twitter": "https://twitter.com/semestalestari",
      "youtube": "https://youtube.com/@semestalestari",
      "linkedin": "https://linkedin.com/company/semestalestari",
      "tiktok": "https://tiktok.com/@semestalestari"
    }
  }' | jq '.'

echo ""
echo "✅ Social media links updated!"
```

Make it executable and run:
```bash
chmod +x update_social_media.sh
./update_social_media.sh
```

---

## Verify Changes

Check if your changes worked:

```bash
curl http://localhost:3000/api/footer | jq '.data.social_media'
```

You should see your updated links!

---

## Common Issues

### Issue 1: "Unauthorized" error
**Solution:** Make sure you're using a valid token. Tokens expire, so get a new one if needed.

### Issue 2: Changes not showing
**Solution:** 
1. Check the response - it should say "success": true
2. Verify with: `curl http://localhost:3000/api/footer`
3. Clear browser cache if viewing on frontend

### Issue 3: Invalid URL format
**Solution:** Make sure URLs start with `https://` or `http://`

---

## Tips

1. **Test First:** Use Swagger UI to test before writing scripts
2. **Backup:** Get current values before updating:
   ```bash
   curl http://localhost:3000/api/footer > backup.json
   ```
3. **Partial Updates:** You don't need to update all platforms at once
4. **Validation:** The API doesn't validate URLs yet, so double-check your links

---

## Need Help?

- **Swagger UI:** http://localhost:3000/api-docs/
- **Check current values:** `curl http://localhost:3000/api/footer`
- **Get all settings:** `curl -H "Authorization: Bearer TOKEN" http://localhost:3000/api/admin/config`

---

## Summary

**Easiest way:** Use Swagger UI at http://localhost:3000/api-docs/
1. Login to get token
2. Authorize with token
3. Use PUT /api/admin/footer
4. Update social_media object
5. Execute

**Command line:** Use the script above or individual curl commands

**Recommended:** Method 1 (Admin Footer Endpoint) for updating multiple links at once
