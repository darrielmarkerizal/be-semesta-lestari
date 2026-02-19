# Quick Start Guide - Semesta Lestari API

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Configure Database
Edit `.env` file with your MySQL credentials:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=semesta_lestari
```

### Step 3: Initialize Database
```bash
npm run init-db
```

This creates all 19 tables in your MySQL database.

### Step 4: Seed Sample Data
```bash
npm run seed
```

This creates:
- Default admin user (admin@senestalestari.org / admin123)
- Sample hero section
- Sample visions, missions, and impact sections
- Basic settings

### Step 5: Start Server
```bash
npm run dev
```

Server will start at: `http://localhost:5000`

### Step 6: Test the API

#### Option 1: Swagger UI (Recommended)
Open your browser: `http://localhost:5000/api-docs`

1. Click "Authorize" button
2. Login first using `/api/admin/auth/login` endpoint
3. Copy the `accessToken` from response
4. Click "Authorize" again and enter: `Bearer <your-token>`
5. Now you can test all endpoints!

#### Option 2: cURL
```bash
# Health check
curl http://localhost:5000/api/health

# Get home page data
curl http://localhost:5000/api/home

# Login
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Use the token from login response
curl http://localhost:5000/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Option 3: Postman
Import `postman_collection.json` into Postman and start testing!

## 📚 Key Endpoints

### Public (No Auth Required)
- `GET /api/health` - Health check
- `GET /api/home` - Complete home page
- `GET /api/articles` - All articles
- `GET /api/about/history` - About page
- `POST /api/contact/send-message` - Contact form

### Admin (Requires Bearer Token)
- `POST /api/admin/auth/login` - Login (no token needed)
- `GET /api/admin/dashboard` - Dashboard stats
- `GET /api/admin/articles` - Manage articles
- `POST /api/admin/articles` - Create article
- `PUT /api/admin/articles/:id` - Update article
- `DELETE /api/admin/articles/:id` - Delete article

## 🔐 Default Credentials

After seeding:
- **Email**: admin@semestalestari.com
- **Password**: admin123

⚠️ **Important**: Change these credentials in production!

## 📖 Full Documentation

- **Swagger UI**: http://localhost:5000/api-docs
- **README**: See README.md for complete documentation
- **Postman**: Import postman_collection.json

## 🐛 Troubleshooting

### Database Connection Error
- Check MySQL is running
- Verify credentials in `.env`
- Ensure database exists (run `npm run init-db`)

### Port Already in Use
Change `PORT` in `.env` file:
```env
PORT=3000
```

### Token Invalid/Expired
Login again to get a new token:
```bash
POST /api/admin/auth/login
```

## 🎯 Next Steps

1. ✅ Explore Swagger documentation
2. ✅ Test public endpoints
3. ✅ Login and test admin endpoints
4. ✅ Create your first article
5. ✅ Customize the data for your needs

## 💡 Tips

- Use Swagger UI for interactive testing
- All admin endpoints require `Authorization: Bearer <token>` header
- Tokens expire after 7 days (configurable in `.env`)
- Check `logs/` directory for error logs
- Pagination: Use `?page=1&limit=10` query parameters

## 🆘 Need Help?

- Check the logs in `logs/combined.log`
- Review the full README.md
- Check Swagger documentation for endpoint details

Happy coding! 🎉
