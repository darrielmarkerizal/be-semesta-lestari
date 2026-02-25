# Footer System - Getting Started Guide

Quick guide to start using the footer system immediately.

## Quick Start (5 minutes)

### 1. Ensure Database is Set Up
```bash
# Initialize database tables
node src/scripts/initDatabase.js

# Add category_id to programs
node src/scripts/addProgramCategoryId.js

# Seed all data
node src/scripts/seedDatabase.js
```

### 2. Start the Server
```bash
node src/server.js
```

### 3. Test the Footer Endpoint
```bash
curl http://localhost:3000/api/footer | jq '.'
```

You should see contact info, social media links, and program categories!

## Using the Footer Endpoint

### Get Footer Data (No Auth Required)
```bash
curl http://localhost:3000/api/footer
```

**Response includes:**
- Contact: email, phones, address, work_hours
- Social Media: 6 platform links
- Program Categories: 4 default categories

## Managing Program Categories

### 1. Login to Get Token
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')
```

### 2. List All Categories
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/program-categories | jq '.'
```

### 3. Create New Category
```bash
curl -X POST http://localhost:3000/api/admin/program-categories \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wildlife Protection",
    "slug": "wildlife-protection",
    "description": "Protecting endangered species",
    "icon": "🦁",
    "order_position": 5,
    "is_active": true
  }' | jq '.'
```

### 4. Update Category
```bash
curl -X PUT http://localhost:3000/api/admin/program-categories/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"description": "Updated description"}' | jq '.'
```

### 5. Delete Category
```bash
curl -X DELETE http://localhost:3000/api/admin/program-categories/5 \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

## Managing Settings

### Update Contact Email
```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_email \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"newemail@semestalestari.org"}' | jq '.'
```

### Update Social Media Link
```bash
curl -X PUT http://localhost:3000/api/admin/config/social_facebook \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://facebook.com/newpage"}' | jq '.'
```

### Update Phone Numbers
```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_phones \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"[\"(+62) 21-9999-8888\", \"(+62) 812-9999-8888\"]"}' | jq '.'
```

## Using Swagger UI

### 1. Open Swagger UI
```
http://localhost:3000/api-docs/
```

### 2. Authenticate
1. Click "Authorize" button at top
2. Enter: `Bearer YOUR_TOKEN`
3. Click "Authorize"

### 3. Test Endpoints
1. Navigate to "Footer" or "Admin - Program Categories"
2. Click on any endpoint
3. Click "Try it out"
4. Fill in parameters (if needed)
5. Click "Execute"
6. View response

## Running Tests

### Test Everything
```bash
./test_footer_complete.sh
```

### Test Individual Components
```bash
# Footer endpoint only
./test_footer_api.sh

# Program categories only
./test_program_categories.sh

# Swagger documentation
./test_swagger_footer.sh
```

## Default Data

### Admin Credentials
- **Email:** admin@semestalestari.com
- **Password:** admin123

### Program Categories
1. Conservation (🌳)
2. Education (📚)
3. Community (👥)
4. Research (🔬)

### Contact Info
- **Email:** info@semestalestari.org
- **Phones:** 2 numbers
- **Address:** Jakarta address
- **Hours:** Mon-Sat schedule

### Social Media
All 6 platforms configured with example URLs

## Common Tasks

### Add a New Program Category
```bash
# 1. Get token
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# 2. Create category
curl -X POST http://localhost:3000/api/admin/program-categories \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Your Category",
    "slug": "your-category",
    "description": "Description here",
    "icon": "🌟",
    "order_position": 10,
    "is_active": true
  }'
```

### Link a Program to a Category
```bash
# Update program with category_id
curl -X PUT http://localhost:3000/api/admin/programs/PROGRAM_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"category_id": 1}'
```

### Update Contact Information
```bash
# Update email
curl -X PUT http://localhost:3000/api/admin/config/contact_email \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"your@email.com"}'

# Update address
curl -X PUT http://localhost:3000/api/admin/config/contact_address \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"Your new address"}'
```

## Troubleshooting

### "Route not found"
- Make sure server is running: `node src/server.js`
- Check the URL is correct

### "Unauthorized"
- Get a fresh token using the login endpoint
- Make sure to include "Bearer " before the token

### "Database error"
- Run database initialization: `node src/scripts/initDatabase.js`
- Run seed script: `node src/scripts/seedDatabase.js`

### Tests failing
- Ensure server is running on port 3000
- Check database is initialized and seeded
- Verify admin credentials are correct

## Next Steps

1. **Explore Swagger UI** - Interactive API documentation
2. **Read Full Documentation** - See FOOTER_API_SUMMARY.md
3. **Check Test Reports** - See FOOTER_TEST_REPORT.md
4. **Review Quick Reference** - See FOOTER_QUICK_REFERENCE.md

## Support

- **Swagger UI:** http://localhost:3000/api-docs/
- **Health Check:** http://localhost:3000/api/health
- **Footer Endpoint:** http://localhost:3000/api/footer

## Summary

You now have:
- ✅ Footer endpoint returning all data
- ✅ Program categories management
- ✅ Contact info management
- ✅ Social media links management
- ✅ Complete Swagger documentation
- ✅ Test scripts for verification

**Ready to use!** 🎉
