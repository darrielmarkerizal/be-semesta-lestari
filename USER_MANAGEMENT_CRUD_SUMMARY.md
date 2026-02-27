# User Management - Complete CRUD Implementation

## Overview
The `/api/admin/users` endpoint has complete CRUD operations including PUT and DELETE methods.

## API Endpoints

### Base URL
```
/api/admin/users
```

All endpoints require authentication with Bearer token.

## CRUD Operations

### 1. CREATE - POST /api/admin/users
Create a new user account.

**Request:**
```bash
POST /api/admin/users
Authorization: Bearer {token}
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword123",
  "role": "admin",
  "status": "active"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 3,
    "username": "johndoe",
    "email": "john@example.com",
    "role": "admin",
    "status": "active",
    "created_at": "2026-02-27T...",
    "updated_at": "2026-02-27T..."
  }
}
```

### 2. READ - GET /api/admin/users
Get all users with pagination.

**Request:**
```bash
GET /api/admin/users?page=1&limit=10
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Users retrieved",
  "data": [
    {
      "id": 1,
      "username": "admin",
      "email": "admin@semestalestari.com",
      "role": "admin",
      "status": "active"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1
  }
}
```

### 3. READ - GET /api/admin/users/:id
Get a single user by ID.

**Request:**
```bash
GET /api/admin/users/1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "User retrieved",
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@semestalestari.com",
    "role": "admin",
    "status": "active",
    "created_at": "2026-02-27T...",
    "updated_at": "2026-02-27T..."
  }
}
```

### 4. UPDATE - PUT /api/admin/users/:id ✅
Update an existing user.

**Request:**
```bash
PUT /api/admin/users/3
Authorization: Bearer {token}
Content-Type: application/json

{
  "username": "johndoe_updated",
  "email": "john.updated@example.com",
  "role": "editor",
  "status": "active"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "id": 3,
    "username": "johndoe_updated",
    "email": "john.updated@example.com",
    "role": "editor",
    "status": "active",
    "created_at": "2026-02-27T...",
    "updated_at": "2026-02-27T..."
  }
}
```

**Notes:**
- All fields are optional (partial updates supported)
- Password can be updated by including it in the request
- Cannot update your own role or status

### 5. DELETE - DELETE /api/admin/users/:id ✅
Delete a user account.

**Request:**
```bash
DELETE /api/admin/users/3
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "data": null
}
```

**Security:**
- Cannot delete your own account (returns 400 error)
- Only authenticated admins can delete users

## Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | integer | Auto | User ID (primary key) |
| username | string | Yes | Unique username |
| email | string | Yes | Unique email address |
| password | string | Yes (create) | User password (hashed) |
| role | string | No | User role: admin, editor (default: admin) |
| status | string | No | Account status: active, inactive (default: active) |
| created_at | timestamp | Auto | Account creation time |
| updated_at | timestamp | Auto | Last update time |

## Validation Rules

### Create User
- `username`: Required, unique
- `email`: Required, unique, valid email format
- `password`: Required, minimum 6 characters
- `role`: Optional, must be 'admin' or 'editor'

### Update User
- All fields optional (partial updates)
- `email`: Must be unique if provided
- `username`: Must be unique if provided
- `password`: Minimum 6 characters if provided

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Cannot delete your own account",
  "error": null
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "User not found",
  "error": null
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": null
}
```

## Testing Examples

### Complete CRUD Test
```bash
# Get token
TOKEN=$(curl -s -X POST 'http://localhost:3000/api/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

# 1. CREATE
curl -X POST "http://localhost:3000/api/admin/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpass123",
    "role": "admin"
  }'

# 2. READ (List)
curl "http://localhost:3000/api/admin/users" \
  -H "Authorization: Bearer $TOKEN"

# 3. READ (Single)
curl "http://localhost:3000/api/admin/users/3" \
  -H "Authorization: Bearer $TOKEN"

# 4. UPDATE
curl -X PUT "http://localhost:3000/api/admin/users/3" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "updateduser",
    "email": "updated@example.com"
  }'

# 5. DELETE
curl -X DELETE "http://localhost:3000/api/admin/users/3" \
  -H "Authorization: Bearer $TOKEN"
```

## Test Results

```
=== Testing User Management CRUD ===

1. GET - List all users:
✅ Success: true, user_count: 1

2. POST - Create new user:
✅ Success: true, username: testuser, email: testuser@example.com

3. GET - Get single user:
✅ Success: true, username: testuser, email: testuser@example.com

4. PUT - Update user:
✅ Success: true, username: updateduser, email: updated@example.com

5. DELETE - Delete user:
✅ Success: true, message: User deleted successfully
```

## Swagger Documentation

Complete Swagger documentation is available at `/api-docs` including:
- Request/response schemas
- Field descriptions
- Example values
- Error responses
- Authentication requirements

### Swagger Endpoints
```yaml
/api/admin/users:
  get:
    summary: Get all users
    tags: [Admin - Users]
  post:
    summary: Create new user
    tags: [Admin - Users]

/api/admin/users/{id}:
  get:
    summary: Get user by ID
    tags: [Admin - Users]
  put:
    summary: Update user
    tags: [Admin - Users]
  delete:
    summary: Delete user
    tags: [Admin - Users]
```

## Security Features

1. **Authentication Required**: All endpoints require valid Bearer token
2. **Self-Protection**: Cannot delete your own account
3. **Password Hashing**: Passwords are automatically hashed with bcrypt
4. **Validation**: Input validation on all fields
5. **Authorization**: Only admin users can manage other users

## Files Involved

1. **Routes**: `src/routes/admin.js`
   - Defines all user management endpoints
   - Includes validation middleware

2. **Controller**: `src/controllers/settingsController.js`
   - Implements CRUD operations
   - Handles business logic
   - Includes Swagger documentation

3. **Model**: `src/models/User.js`
   - Database operations
   - Password hashing
   - Data validation

4. **Validation**: `src/utils/validation.js`
   - User schema validation
   - Field requirements

## Conclusion

The user management system has complete CRUD functionality:
- ✅ CREATE - POST /api/admin/users
- ✅ READ - GET /api/admin/users (list)
- ✅ READ - GET /api/admin/users/:id (single)
- ✅ UPDATE - PUT /api/admin/users/:id
- ✅ DELETE - DELETE /api/admin/users/:id

All operations are:
- Fully implemented
- Tested and working
- Documented in Swagger
- Secured with authentication
- Validated for data integrity
