# User Management - Quick Reference

## Quick Start

### Default Admin Credentials
```
Email: admin@semestalestari.com
Password: admin123
```

### Base URL
```
http://localhost:3000
```

### Swagger Documentation
```
http://localhost:3000/api-docs
```

---

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/admin/users` | Get all users (paginated) | ✅ |
| POST | `/api/admin/users` | Create new user | ✅ |
| GET | `/api/admin/users/:id` | Get user by ID | ✅ |
| PUT | `/api/admin/users/:id` | Update user | ✅ |
| DELETE | `/api/admin/users/:id` | Delete user | ✅ |

---

## Quick Examples

### 1. Login
```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

**Response**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGc...",
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@semestalestari.com",
      "role": "admin"
    }
  }
}
```

### 2. Get All Users (with pagination)
```bash
TOKEN="your_access_token"

curl -X GET "http://localhost:3000/api/admin/users?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Create User
```bash
curl -X POST http://localhost:3000/api/admin/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "securepass123",
    "role": "editor"
  }'
```

### 4. Get User by ID
```bash
curl -X GET http://localhost:3000/api/admin/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Update User
```bash
# Update username only
curl -X PUT http://localhost:3000/api/admin/users/5 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newusername"
  }'

# Update multiple fields
curl -X PUT http://localhost:3000/api/admin/users/5 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john.doe@example.com",
    "role": "admin",
    "status": "active"
  }'
```

### 6. Delete User
```bash
curl -X DELETE http://localhost:3000/api/admin/users/5 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Field Reference

### User Object
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | integer | Auto | User ID |
| username | string | Yes | Unique username |
| email | string | Yes | Unique email address |
| password | string | Yes (create) | Password (hashed, not returned) |
| role | string | No | `admin` or `editor` (default: editor) |
| status | string | No | `active` or `inactive` (default: active) |
| created_at | datetime | Auto | Creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

### Pagination Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number |
| limit | integer | 10 | Items per page |

### Pagination Response
```json
{
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 50,
    "itemsPerPage": 10,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

---

## Response Codes

| Code | Description |
|------|-------------|
| 200 | Success (GET, PUT, DELETE) |
| 201 | Created (POST) |
| 400 | Bad Request (validation error, duplicate) |
| 401 | Unauthorized (missing/invalid token) |
| 404 | Not Found (user doesn't exist) |

---

## Common Response Structure

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* user object or array */ },
  "error": null
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "data": null,
  "error": "Error details"
}
```

---

## Business Rules

1. **Authentication**: All endpoints require Bearer token
2. **Unique Constraints**: Username and email must be unique
3. **Self-Deletion**: Cannot delete your own account
4. **Password Security**: Passwords are hashed with bcrypt
5. **Password Privacy**: Password field never returned in responses
6. **Default Role**: New users default to "editor" role
7. **Default Status**: New users default to "active" status
8. **Partial Updates**: PUT supports updating individual fields

---

## Testing

### Run CRUD Tests (30 tests)
```bash
chmod +x test_users_crud.sh
./test_users_crud.sh
```

### Run Swagger Tests (22 tests)
```bash
chmod +x test_swagger_users.sh
./test_swagger_users.sh
```

### Expected Results
- CRUD Tests: 30/30 passed (100%)
- Swagger Tests: 22/22 passed (100%)

---

## Troubleshooting

### 401 Unauthorized
- Check if token is valid
- Ensure "Bearer " prefix in Authorization header
- Token may have expired, login again

### 400 Duplicate Username/Email
- Username or email already exists
- Choose different values

### 400 Cannot Delete Own Account
- You're trying to delete your own user account
- Use a different admin account to delete this user

### 404 User Not Found
- User ID doesn't exist
- Check the ID and try again

---

## Related Files

- **Controller**: `src/controllers/settingsController.js`
- **Model**: `src/models/User.js`
- **Routes**: `src/routes/admin.js`
- **Tests**: `test_users_crud.sh`, `test_swagger_users.sh`
- **Documentation**: `USER_MANAGEMENT_TEST_REPORT.md`

---

## Next Steps

1. View Swagger docs: http://localhost:3000/api-docs
2. Test endpoints using the examples above
3. Run test suites to verify functionality
4. Integrate with your frontend application
