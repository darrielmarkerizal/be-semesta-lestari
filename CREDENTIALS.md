# Default Admin Credentials

## 🔐 Login Information

After running `npm run seed`, use these credentials to access the admin endpoints:

**Email**: `admin@semestalestari.com`  
**Password**: `admin123`

## 🚀 How to Login

### Via Swagger UI (Recommended)
1. Open http://localhost:3000/api-docs
2. Find **Authentication** section
3. Click on `POST /api/admin/auth/login`
4. Click **"Try it out"**
5. Use the credentials above
6. Copy the `accessToken` from response
7. Click **"Authorize"** button (top right)
8. Enter: `Bearer <your-token>`
9. Now you can test all admin endpoints!

### Via cURL
```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

### Via Postman
1. Import `postman_collection.json`
2. Run the "Login" request
3. Token will be automatically saved to collection variables
4. All other admin requests will use this token automatically

## ⚠️ Security Notice

**IMPORTANT**: Change these default credentials in production!

To change the password:
1. Login with default credentials
2. Use `PUT /api/admin/users/:id` endpoint
3. Or update directly in database:
   ```sql
   UPDATE users 
   SET password = '<bcrypt-hashed-password>' 
   WHERE email = 'admin@semestalestari.com';
   ```

## 📝 User Details

- **Username**: admin
- **Email**: admin@semestalestari.com
- **Password**: admin123
- **Role**: admin
- **Status**: active

## 🔄 Reset Credentials

If you need to reset to default credentials:
```bash
npm run seed
```

This will recreate the default admin user with the credentials above.
