# Semesta Lestari API

Complete REST API backend for Semesta Lestari dynamic website with full Swagger/OpenAPI 3.0 documentation, JWT authentication, and MySQL database.

## 🚀 Features

- **Complete REST API** with 100+ endpoints
- **JWT Authentication** with Bearer tokens
- **Swagger/OpenAPI 3.0** documentation
- **MySQL Database** with 19 tables
- **Role-based Access Control**
- **Rate Limiting** for security
- **Input Validation** with Joi
- **Error Handling** with Winston logging
- **CORS Support**
- **Security Headers** with Helmet
- **Pagination Support**
- **Auto-generated Slugs** for articles

## 📋 Prerequisites

- Node.js (v14 or higher)
- MySQL (v5.7 or higher)
- npm or yarn

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd be-semesta-lestari
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file with your configuration:
   ```env
   PORT=5000
   NODE_ENV=development
   
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=semesta_lestari
   DB_PORT=3306
   
   JWT_SECRET=your-super-secret-jwt-key
   JWT_EXPIRE=7d
   JWT_REFRESH_EXPIRE=30d
   
   SWAGGER_ENABLED=true
   ```

4. **Initialize database**
   ```bash
   npm run init-db
   ```

5. **Seed database with sample data**
   ```bash
   npm run seed
   ```

6. **Start the server**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

## 📚 API Documentation

Once the server is running, access the interactive Swagger documentation at:

```
http://localhost:5000/api-docs
```

### Quick Links

- **API Base URL**: `http://localhost:5000/api`
- **Swagger UI**: `http://localhost:5000/api-docs`
- **Swagger JSON**: `http://localhost:5000/api-docs.json`
- **Health Check**: `http://localhost:5000/api/health`

## 🔐 Authentication

### Default Admin Credentials

After seeding the database:
- **Email**: `admin@semestalestari.com`
- **Password**: `admin123`

### Using JWT Tokens

1. **Login** to get access token:
   ```bash
   POST /api/admin/auth/login
   {
     "email": "admin@semestalestari.com",
     "password": "admin123"
   }
   ```

2. **Use the token** in subsequent requests:
   ```
   Authorization: Bearer <your-token-here>
   ```

3. **Swagger Authentication**:
   - Click the "Authorize" button in Swagger UI
   - Enter: `Bearer <your-token>`
   - Click "Authorize"

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Database connection pool
│   │   └── environment.js       # Environment configuration
│   ├── middleware/
│   │   ├── auth.js              # JWT authentication
│   │   ├── errorHandler.js     # Global error handler
│   │   ├── validation.js       # Request validation
│   │   └── rateLimiter.js      # Rate limiting
│   ├── routes/
│   │   ├── public.js            # Public endpoints
│   │   ├── admin.js             # Admin endpoints
│   │   └── index.js             # Route aggregator
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── homeController.js
│   │   ├── aboutController.js
│   │   ├── articleController.js
│   │   ├── awardController.js
│   │   ├── merchandiseController.js
│   │   ├── galleryController.js
│   │   ├── contactController.js
│   │   ├── dashboardController.js
│   │   ├── pageController.js
│   │   ├── programController.js
│   │   ├── partnerController.js
│   │   ├── faqController.js
│   │   ├── settingsController.js
│   │   ├── adminHomeController.js
│   │   └── genericController.js
│   ├── models/
│   │   ├── BaseModel.js
│   │   ├── User.js
│   │   ├── Article.js
│   │   ├── HeroSection.js
│   │   ├── Vision.js
│   │   ├── Mission.js
│   │   ├── History.js
│   │   ├── Leadership.js
│   │   ├── Award.js
│   │   ├── Merchandise.js
│   │   ├── GalleryItem.js
│   │   ├── ContactMessage.js
│   │   ├── ImpactSection.js
│   │   ├── DonationCTA.js
│   │   ├── ClosingCTA.js
│   │   ├── PageSettings.js
│   │   ├── Program.js
│   │   ├── Partner.js
│   │   ├── FAQ.js
│   │   └── Settings.js
│   ├── utils/
│   │   ├── jwt.js               # JWT utilities
│   │   ├── validation.js        # Validation schemas
│   │   ├── response.js          # Response helpers
│   │   ├── logger.js            # Winston logger
│   │   └── swagger.js           # Swagger configuration
│   ├── scripts/
│   │   ├── initDatabase.js      # Database initialization
│   │   └── seedDatabase.js      # Database seeding
│   ├── app.js                   # Express app setup
│   └── server.js                # Server entry point
├── logs/                        # Log files
├── .env                         # Environment variables
├── .env.example                 # Environment template
├── package.json
└── README.md
```

## 🗄️ Database Schema

The API uses 19 MySQL tables:

1. **users** - Admin users
2. **hero_sections** - Hero section content
3. **visions** - Vision statements
4. **missions** - Mission statements
5. **history** - History/About content
6. **leadership** - Leadership/Organization
7. **articles** - Articles/Blog posts
8. **awards** - Awards and achievements
9. **merchandise** - Merchandise items
10. **gallery_items** - Gallery images
11. **contact_messages** - Contact form submissions
12. **impact_sections** - Impact statistics
13. **donation_ctas** - Donation CTAs
14. **closing_ctas** - Closing CTAs
15. **page_settings** - Page metadata
16. **programs** - Programs/Initiatives
17. **partners** - Partner organizations
18. **faqs** - FAQs
19. **settings** - Application settings

## 🔌 API Endpoints

### Public Endpoints (No Authentication)

#### Home & Content
- `GET /api/health` - Health check
- `GET /api/home` - Complete home page data
- `GET /api/hero-section` - Hero section
- `GET /api/visions` - All visions
- `GET /api/missions` - All missions
- `GET /api/impact` - Impact sections
- `GET /api/donation-cta` - Donation CTA
- `GET /api/closing-cta` - Closing CTA

#### About
- `GET /api/about/history` - History content
- `GET /api/about/visions` - About visions
- `GET /api/about/missions` - About missions
- `GET /api/about/leadership` - Leadership

#### Articles
- `GET /api/articles` - All articles (paginated)
- `GET /api/articles/:slug` - Single article by slug
- `POST /api/articles/:id/increment-views` - Increment views

#### Other Resources
- `GET /api/awards` - All awards
- `GET /api/merchandise` - All merchandise
- `GET /api/gallery` - Gallery items
- `GET /api/programs` - Programs
- `GET /api/partners` - Partners
- `GET /api/faqs` - FAQs
- `GET /api/contact/info` - Contact info
- `POST /api/contact/send-message` - Send message
- `GET /api/pages/:slug/info` - Page info
- `GET /api/config` - Public settings

### Admin Endpoints (Require Bearer Token)

#### Authentication
- `POST /api/admin/auth/login` - Login (no token required)
- `POST /api/admin/auth/logout` - Logout
- `POST /api/admin/auth/refresh-token` - Refresh token
- `GET /api/admin/auth/me` - Current user info

#### Dashboard
- `GET /api/admin/dashboard` - Dashboard stats
- `GET /api/admin/dashboard/stats` - Detailed stats

#### Homepage Management
- `GET /api/admin/homepage/hero` - Get hero
- `PUT /api/admin/homepage/hero` - Update hero
- `GET /api/admin/homepage/visions` - Get visions
- `POST /api/admin/homepage/visions` - Create vision
- `PUT /api/admin/homepage/visions/:id` - Update vision
- `DELETE /api/admin/homepage/visions/:id` - Delete vision
- (Similar CRUD for missions, impact, CTAs)

#### Content Management
- Full CRUD for: articles, awards, merchandise, gallery, programs, partners, FAQs
- Pattern: `GET/POST /api/admin/{resource}`
- Pattern: `GET/PUT/DELETE /api/admin/{resource}/:id`

#### Settings & Users
- `GET /api/admin/config` - All settings
- `PUT /api/admin/config/:key` - Update setting
- `GET /api/admin/users` - All users
- `POST /api/admin/users` - Create user
- `PUT /api/admin/users/:id` - Update user
- `DELETE /api/admin/users/:id` - Delete user

## 📝 Example Requests

### Login
```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

### Get Articles (Public)
```bash
curl http://localhost:5000/api/articles?page=1&limit=10
```

### Create Article (Admin)
```bash
curl -X POST http://localhost:5000/api/admin/articles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "New Article",
    "content": "Article content here...",
    "excerpt": "Short description",
    "category": "Environment"
  }'
```

## 🧪 Testing

Use the Swagger UI for interactive testing:
1. Navigate to `http://localhost:5000/api-docs`
2. Click "Authorize" and enter your Bearer token
3. Try out any endpoint with the "Try it out" button

## 🔒 Security Features

- **JWT Authentication** with Bearer tokens
- **Password Hashing** with bcryptjs
- **Rate Limiting** to prevent abuse
- **Helmet** for security headers
- **CORS** configuration
- **Input Validation** with Joi
- **SQL Injection Prevention** with parameterized queries
- **XSS Protection**

## 📊 Response Format

All API responses follow this consistent format:

```json
{
  "success": true,
  "message": "Success message",
  "data": { },
  "error": null
}
```

Paginated responses include:
```json
{
  "success": true,
  "message": "Data retrieved",
  "data": [],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 50,
    "itemsPerPage": 10,
    "hasNextPage": true,
    "hasPrevPage": false
  },
  "error": null
}
```

## 🐛 Error Handling

Errors return appropriate HTTP status codes:
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate entry)
- `500` - Internal Server Error

## 📜 Logging

Logs are stored in the `logs/` directory:
- `error.log` - Error logs only
- `combined.log` - All logs

## 🚀 Deployment

### Production Checklist

1. Set `NODE_ENV=production` in `.env`
2. Use strong `JWT_SECRET`
3. Configure proper database credentials
4. Set `SWAGGER_ENABLED=false` (optional)
5. Use process manager (PM2, systemd)
6. Set up reverse proxy (Nginx)
7. Enable HTTPS
8. Configure firewall
9. Set up database backups

### PM2 Example
```bash
npm install -g pm2
pm2 start src/server.js --name semesta-api
pm2 save
pm2 startup
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

ISC License

## 👥 Support

For support, email support@senestalestari.org

## 🎉 Acknowledgments

Built with Express.js, MySQL, JWT, and Swagger for Semesta Lestari organization.
