# Contact API Quick Reference

## Public Endpoints

### Get Contact Info
```bash
GET /api/contact/info
```

**Response:**
```json
{
  "success": true,
  "data": {
    "email": "info@semestalestari.org",
    "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
  }
}
```

### Send Contact Message
```bash
POST /api/contact/send-message
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Inquiry",
  "message": "Your message here"
}
```

**Required Fields:** name, email, message

---

## Admin Endpoints (Require Authentication)

### Contact Info Management

#### Get Contact Info
```bash
GET /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
```

#### Update Contact Info
```bash
PUT /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "email": "info@semestalestari.org",
  "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM"
}
```

**Note:** All fields are optional. Only send fields you want to update.

---

### Contact Messages Management

#### Get All Messages
```bash
GET /api/admin/contact/show-messages
Authorization: Bearer YOUR_TOKEN
```

**Query Parameters:**
- `page` (optional) - Page number, default: 1
- `limit` (optional) - Items per page, default: 10

#### Create Message (Admin)
```bash
POST /api/admin/contact/show-messages
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Inquiry",
  "message": "Message content"
}
```

**Required Fields:** name, email, message

#### Get Single Message
```bash
GET /api/admin/contact/show-messages/:id
Authorization: Bearer YOUR_TOKEN
```

#### Update Message
```bash
PUT /api/admin/contact/show-messages/:id
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "subject": "Updated Subject",
  "is_replied": true
}
```

**Note:** All fields are optional. Only send fields you want to update.

#### Mark Message as Read
```bash
PUT /api/admin/contact/show-messages/:id/read
Authorization: Bearer YOUR_TOKEN
```

#### Delete Message
```bash
DELETE /api/admin/contact/show-messages/:id
Authorization: Bearer YOUR_TOKEN
```

---

## Response Formats

### Contact Info Object
```json
{
  "email": "info@semestalestari.org",
  "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
}
```

### Contact Message Object
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Inquiry about programs",
  "message": "I would like to know more about your environmental programs.",
  "is_read": false,
  "is_replied": false,
  "created_at": "2024-02-19T...",
  "updated_at": "2024-02-19T..."
}
```

---

## cURL Examples

### Get Contact Info (Public)
```bash
curl "http://localhost:3000/api/contact/info"
```

### Send Message
```bash
curl -X POST "http://localhost:3000/api/contact/send-message" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "message": "Hello, I have a question."
  }'
```

### Update Contact Info (Admin)
```bash
# Get token first
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['accessToken'])")

# Update contact info
curl -X PUT "http://localhost:3000/api/admin/contact/info" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newemail@example.com",
    "phones": ["+62 xxx", "+62 yyy"]
  }'
```

### Get Messages (Admin)
```bash
curl "http://localhost:3000/api/admin/contact/show-messages?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### Create Message (Admin)
```bash
curl -X POST "http://localhost:3000/api/admin/contact/show-messages" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Created",
    "email": "admin@example.com",
    "message": "Message from admin"
  }'
```

### Update Message (Admin)
```bash
curl -X PUT "http://localhost:3000/api/admin/contact/show-messages/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Updated Subject",
    "is_replied": true
  }'
```

---

## Key Changes from Previous Version

1. **phones** is now an array instead of single phone string
2. Added **work_hours** field
3. Admin endpoints moved from `/api/admin/messages` to `/api/admin/contact/show-messages`
4. New admin endpoints for managing contact info
5. **NEW: Full CRUD operations for contact messages**
   - Create messages (POST)
   - Update messages (PUT)
   - Partial updates supported

---

## Swagger Documentation

Access interactive API documentation:
```
http://localhost:3000/api-docs
```

Look for:
- **Contact** - Public contact endpoints
- **Admin - Contact** - Admin contact management
