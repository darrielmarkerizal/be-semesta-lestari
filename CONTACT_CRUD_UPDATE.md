# Contact API CRUD Update

## Summary
Added full CRUD (Create, Read, Update, Delete) operations for contact messages at `/api/admin/contact/show-messages`.

## Date
February 19, 2026

---

## New CRUD Operations

### Complete Admin Contact Message Endpoints

```
GET    /api/admin/contact/show-messages          - List all messages (paginated)
POST   /api/admin/contact/show-messages          - Create new message
GET    /api/admin/contact/show-messages/:id      - Get single message
PUT    /api/admin/contact/show-messages/:id      - Update message
PUT    /api/admin/contact/show-messages/:id/read - Mark as read
DELETE /api/admin/contact/show-messages/:id      - Delete message
```

---

## API Endpoints Details

### 1. Create Message (NEW)

**Endpoint:** `POST /api/admin/contact/show-messages`  
**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Inquiry",
  "message": "Message content here"
}
```

**Required Fields:** name, email, message  
**Optional Fields:** phone, subject

**Response:**
```json
{
  "success": true,
  "message": "Message created successfully",
  "data": {
    "id": 8,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+62 812 3456 7890",
    "subject": "Inquiry",
    "message": "Message content here",
    "is_read": 0,
    "is_replied": 0,
    "created_at": "2024-02-19T...",
    "updated_at": "2024-02-19T..."
  }
}
```

**Use Case:** Admin can manually create contact messages (e.g., from phone calls, emails, or other channels)

---

### 2. Read Messages

#### Get All Messages
**Endpoint:** `GET /api/admin/contact/show-messages`  
**Authentication:** Required

**Query Parameters:**
- `page` (optional) - Page number, default: 1
- `limit` (optional) - Items per page, default: 10

**Response:**
```json
{
  "success": true,
  "message": "Messages retrieved",
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+62 812 3456 7890",
      "subject": "Inquiry",
      "message": "Message content",
      "is_read": 0,
      "is_replied": 0,
      "created_at": "2024-02-19T...",
      "updated_at": "2024-02-19T..."
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 5,
    "itemsPerPage": 10,
    "hasNextPage": false,
    "hasPrevPage": false
  }
}
```

#### Get Single Message
**Endpoint:** `GET /api/admin/contact/show-messages/:id`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Message retrieved",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+62 812 3456 7890",
    "subject": "Inquiry",
    "message": "Message content",
    "is_read": 0,
    "is_replied": 0,
    "created_at": "2024-02-19T...",
    "updated_at": "2024-02-19T..."
  }
}
```

---

### 3. Update Message (NEW)

**Endpoint:** `PUT /api/admin/contact/show-messages/:id`  
**Authentication:** Required

**Request Body (all fields optional):**
```json
{
  "name": "Updated Name",
  "email": "updated@example.com",
  "phone": "+62 999 8888 7777",
  "subject": "Updated Subject",
  "message": "Updated message content",
  "is_read": true,
  "is_replied": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Message updated successfully",
  "data": {
    "id": 1,
    "name": "Updated Name",
    "email": "updated@example.com",
    "phone": "+62 999 8888 7777",
    "subject": "Updated Subject",
    "message": "Updated message content",
    "is_read": 1,
    "is_replied": 1,
    "created_at": "2024-02-19T...",
    "updated_at": "2024-02-19T..."
  }
}
```

**Use Cases:**
- Correct typos or errors in messages
- Update contact information
- Mark messages as replied
- Add notes or additional information

---

### 4. Mark as Read

**Endpoint:** `PUT /api/admin/contact/show-messages/:id/read`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Message marked as read",
  "data": {
    "id": 1,
    "is_read": 1,
    ...
  }
}
```

**Note:** This is a convenience endpoint. You can also use the update endpoint with `{"is_read": true}`.

---

### 5. Delete Message

**Endpoint:** `DELETE /api/admin/contact/show-messages/:id`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Message deleted successfully",
  "data": null
}
```

---

## Database Changes

### ContactMessage Model Updates

Added `update()` method to support partial updates:

```javascript
static async update(id, messageData) {
  // Supports partial updates
  // Only updates fields that are provided
  // Returns updated message or null if not found
}
```

**Updatable Fields:**
- name
- email
- phone
- subject
- message
- is_read
- is_replied

---

## Testing Examples

### Create Message
```bash
TOKEN="your_token_here"

curl -X POST "http://localhost:3000/api/admin/contact/show-messages" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "Test message"
  }'
```

### Update Message
```bash
curl -X PUT "http://localhost:3000/api/admin/contact/show-messages/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Updated Subject",
    "is_replied": true
  }'
```

### Get All Messages
```bash
curl "http://localhost:3000/api/admin/contact/show-messages?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### Get Single Message
```bash
curl "http://localhost:3000/api/admin/contact/show-messages/1" \
  -H "Authorization: Bearer $TOKEN"
```

### Mark as Read
```bash
curl -X PUT "http://localhost:3000/api/admin/contact/show-messages/1/read" \
  -H "Authorization: Bearer $TOKEN"
```

### Delete Message
```bash
curl -X DELETE "http://localhost:3000/api/admin/contact/show-messages/1" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Complete Contact API Structure

### Public Endpoints
```
GET  /api/contact/info           - Get contact information
POST /api/contact/send-message   - Send contact message
```

### Admin Endpoints
```
# Contact Info Management
GET  /api/admin/contact/info     - Get contact info (admin)
PUT  /api/admin/contact/info     - Update contact info

# Contact Messages Management (CRUD)
GET    /api/admin/contact/show-messages          - List all messages
POST   /api/admin/contact/show-messages          - Create message
GET    /api/admin/contact/show-messages/:id      - Get message
PUT    /api/admin/contact/show-messages/:id      - Update message
PUT    /api/admin/contact/show-messages/:id/read - Mark as read
DELETE /api/admin/contact/show-messages/:id      - Delete message
```

---

## Use Cases

### 1. Manual Message Entry
Admin receives a phone call and wants to log it as a contact message:
```bash
POST /api/admin/contact/show-messages
{
  "name": "Caller Name",
  "email": "caller@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Phone Inquiry",
  "message": "Called to ask about environmental programs"
}
```

### 2. Update Message Status
After replying to a message, mark it as replied:
```bash
PUT /api/admin/contact/show-messages/5
{
  "is_replied": true
}
```

### 3. Correct Information
Fix a typo in the email address:
```bash
PUT /api/admin/contact/show-messages/3
{
  "email": "corrected@example.com"
}
```

### 4. Add Notes
Add additional information to a message:
```bash
PUT /api/admin/contact/show-messages/7
{
  "message": "Original message...\n\nAdmin Note: Followed up on 2024-02-20"
}
```

---

## Files Modified

1. **src/controllers/contactController.js**
   - Added `createMessage()` function
   - Added `updateMessage()` function
   - Updated Swagger documentation

2. **src/models/ContactMessage.js**
   - Added `update()` method with partial update support

3. **src/routes/admin.js**
   - Added POST route for creating messages
   - Added PUT route for updating messages

---

## Swagger Documentation

All endpoints are fully documented in Swagger/OpenAPI 3.0 format.

Access at: `http://localhost:3000/api-docs`

Look for **Admin - Contact** tag to see all contact management endpoints.

---

## Benefits

1. **Complete Control:** Admins have full CRUD operations on contact messages
2. **Flexibility:** Can manually add messages from other channels (phone, email, etc.)
3. **Data Management:** Can correct errors and update information
4. **Status Tracking:** Can mark messages as read/replied
5. **Partial Updates:** Only send fields you want to update
6. **RESTful Design:** Follows REST conventions

---

## Validation

### Create/Update Validation
- **name:** Required for create, optional for update
- **email:** Required for create, must be valid email format
- **message:** Required for create, optional for update
- **phone:** Optional
- **subject:** Optional
- **is_read:** Boolean (true/false or 1/0)
- **is_replied:** Boolean (true/false or 1/0)

---

## Error Handling

### 404 Not Found
```json
{
  "success": false,
  "message": "Message not found",
  "data": null
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "data": null
}
```

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "data": null,
  "error": {
    "details": "Email is required"
  }
}
```

---

## Status

✅ **Complete and Tested**

All CRUD operations are working correctly:
- Create: ✅ Tested
- Read: ✅ Tested (single and list)
- Update: ✅ Tested (partial updates)
- Delete: ✅ Tested

---

## Authentication

All admin endpoints require JWT Bearer token:

```bash
# Login
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Use token
curl http://localhost:3000/api/admin/contact/show-messages \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Default Admin Credentials:**
- Email: admin@semestalestari.com
- Password: admin123
