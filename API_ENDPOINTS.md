# API Endpoints Reference

Complete list of all 100+ endpoints in the Semesta Lestari API.

## 🌐 Base URL
```
http://localhost:5000/api
```

## 🔓 Public Endpoints (No Authentication Required)

### Health & System
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check endpoint |

### Home Page
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/home` | Get complete home page data |
| GET | `/hero-section` | Get hero section |
| GET | `/visions` | Get all visions |
| GET | `/missions` | Get all missions |
| GET | `/impact` | Get impact sections |
| GET | `/donation-cta` | Get donation call-to-action |
| GET | `/closing-cta` | Get closing call-to-action |

### About Page
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/about/history` | Get history/about content |
| GET | `/about/visions` | Get about visions |
| GET | `/about/missions` | Get about missions |
| GET | `/about/leadership` | Get leadership/organization |

### Articles
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/articles` | Get all articles (paginated, limit 10) |
| GET | `/articles/:slug` | Get single article by slug |
| POST | `/articles/:id/increment-views` | Increment article view count |

### Awards
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/awards` | Get all awards (paginated) |
| GET | `/awards/:id` | Get single award |

### Merchandise
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/merchandise` | Get all merchandise (paginated) |
| GET | `/merchandise/:id` | Get single merchandise |

### Gallery
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/gallery` | Get all gallery items (paginated) |
| GET | `/gallery/:id` | Get single gallery item |
| GET | `/gallery/category/:category` | Get gallery by category |

### Programs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/programs` | Get all programs |
| GET | `/programs/:id` | Get single program |

### Partners
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/partners` | Get all partners |
| GET | `/partners/:id` | Get single partner |

### FAQs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/faqs` | Get all FAQs |
| GET | `/faqs/:id` | Get single FAQ |

### Contact
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/contact/info` | Get contact page info |
| POST | `/contact/send-message` | Submit contact form message |

### Pages & Settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pages/:slug/info` | Get page hero info by slug |
| GET | `/config/:key` | Get specific setting |
| GET | `/config` | Get all public settings |

---

## 🔐 Admin Endpoints (Require Bearer Token)

**Authentication Header Required:**
```
Authorization: Bearer <your-jwt-token>
```

### Authentication
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/admin/auth/login` | Login (returns JWT) | ❌ No |
| POST | `/admin/auth/logout` | Logout | ✅ Yes |
| POST | `/admin/auth/refresh-token` | Refresh access token | ✅ Yes |
| GET | `/admin/auth/me` | Get current user info | ✅ Yes |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/dashboard` | Get dashboard statistics |
| GET | `/admin/dashboard/stats` | Get detailed statistics |

### Homepage Management

#### Hero Section
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/homepage/hero` | Get hero section |
| PUT | `/admin/homepage/hero` | Update hero section |

#### Visions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/homepage/visions` | Get all visions |
| POST | `/admin/homepage/visions` | Create vision |
| PUT | `/admin/homepage/visions/:id` | Update vision |
| DELETE | `/admin/homepage/visions/:id` | Delete vision |

#### Missions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/homepage/missions` | Get all missions |
| POST | `/admin/homepage/missions` | Create mission |
| PUT | `/admin/homepage/missions/:id` | Update mission |
| DELETE | `/admin/homepage/missions/:id` | Delete mission |

#### Impact Sections
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/homepage/impact` | Get all impact sections |
| POST | `/admin/homepage/impact` | Create impact section |
| PUT | `/admin/homepage/impact/:id` | Update impact section |
| DELETE | `/admin/homepage/impact/:id` | Delete impact section |

#### CTAs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/homepage/donation-cta` | Get donation CTA |
| PUT | `/admin/homepage/donation-cta/:id` | Update donation CTA |
| GET | `/admin/homepage/closing-cta` | Get closing CTA |
| PUT | `/admin/homepage/closing-cta/:id` | Update closing CTA |

### About Page Management

#### History
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/about/history` | Get all history records |
| POST | `/admin/about/history` | Create history record |
| PUT | `/admin/about/history/:id` | Update history record |
| DELETE | `/admin/about/history/:id` | Delete history record |

#### Visions (About)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/about/visions` | Get about visions |
| POST | `/admin/about/visions` | Create about vision |
| PUT | `/admin/about/visions/:id` | Update about vision |
| DELETE | `/admin/about/visions/:id` | Delete about vision |

#### Missions (About)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/about/missions` | Get about missions |
| POST | `/admin/about/missions` | Create about mission |
| PUT | `/admin/about/missions/:id` | Update about mission |
| DELETE | `/admin/about/missions/:id` | Delete about mission |

#### Leadership
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/about/leadership` | Get all leadership |
| POST | `/admin/about/leadership` | Create leadership |
| PUT | `/admin/about/leadership/:id` | Update leadership |
| DELETE | `/admin/about/leadership/:id` | Delete leadership |

### Page Settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/pages/articles` | Get articles page settings |
| PUT | `/admin/pages/articles` | Update articles page settings |
| GET | `/admin/pages/awards` | Get awards page settings |
| PUT | `/admin/pages/awards` | Update awards page settings |
| GET | `/admin/pages/merchandise` | Get merchandise page settings |
| PUT | `/admin/pages/merchandise` | Update merchandise page settings |
| GET | `/admin/pages/gallery` | Get gallery page settings |
| PUT | `/admin/pages/gallery` | Update gallery page settings |
| GET | `/admin/pages/leadership` | Get leadership page settings |
| PUT | `/admin/pages/leadership` | Update leadership page settings |
| GET | `/admin/pages/contact` | Get contact page settings |
| PUT | `/admin/pages/contact` | Update contact page settings |

### Article Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/articles` | Get all articles (paginated, limit 10) |
| POST | `/admin/articles` | Create new article |
| GET | `/admin/articles/:id` | Get single article |
| PUT | `/admin/articles/:id` | Update article |
| DELETE | `/admin/articles/:id` | Delete article |

### Gallery Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/gallery` | Get all gallery items (paginated) |
| POST | `/admin/gallery` | Create gallery item |
| GET | `/admin/gallery/:id` | Get single gallery item |
| PUT | `/admin/gallery/:id` | Update gallery item |
| DELETE | `/admin/gallery/:id` | Delete gallery item |

### Merchandise Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/merchandise` | Get all merchandise (paginated) |
| POST | `/admin/merchandise` | Create merchandise |
| GET | `/admin/merchandise/:id` | Get single merchandise |
| PUT | `/admin/merchandise/:id` | Update merchandise |
| DELETE | `/admin/merchandise/:id` | Delete merchandise |

### Award Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/awards` | Get all awards (paginated) |
| POST | `/admin/awards` | Create award |
| GET | `/admin/awards/:id` | Get single award |
| PUT | `/admin/awards/:id` | Update award |
| DELETE | `/admin/awards/:id` | Delete award |

### Program Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/programs` | Get all programs (paginated) |
| POST | `/admin/programs` | Create program |
| GET | `/admin/programs/:id` | Get single program |
| PUT | `/admin/programs/:id` | Update program |
| DELETE | `/admin/programs/:id` | Delete program |

### Partner Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/partners` | Get all partners (paginated) |
| POST | `/admin/partners` | Create partner |
| GET | `/admin/partners/:id` | Get single partner |
| PUT | `/admin/partners/:id` | Update partner |
| DELETE | `/admin/partners/:id` | Delete partner |

### FAQ Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/faqs` | Get all FAQs (paginated) |
| POST | `/admin/faqs` | Create FAQ |
| GET | `/admin/faqs/:id` | Get single FAQ |
| PUT | `/admin/faqs/:id` | Update FAQ |
| DELETE | `/admin/faqs/:id` | Delete FAQ |

### Contact Messages Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/messages` | Get all contact messages (paginated) |
| GET | `/admin/messages/:id` | Get single contact message |
| PUT | `/admin/messages/:id/read` | Mark message as read |
| DELETE | `/admin/messages/:id` | Delete contact message |

### Settings Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/config` | Get all settings |
| GET | `/admin/config/:key` | Get specific setting |
| PUT | `/admin/config/:key` | Update specific setting |
| GET | `/admin/seo` | Get SEO settings |
| PUT | `/admin/seo` | Update SEO settings |

### User Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/users` | Get all users (paginated) |
| POST | `/admin/users` | Create new user |
| GET | `/admin/users/:id` | Get single user |
| PUT | `/admin/users/:id` | Update user |
| DELETE | `/admin/users/:id` | Delete user |

---

## 📝 Query Parameters

### Pagination
Most list endpoints support pagination:
```
?page=1&limit=10
```

### Example
```
GET /api/articles?page=2&limit=20
GET /api/admin/gallery?page=1&limit=15
```

---

## 📊 Response Format

### Success Response
```json
{
  "success": true,
  "message": "Success message",
  "data": { },
  "error": null
}
```

### Paginated Response
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

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "error": { }
}
```

---

## 🔑 Authentication Flow

1. **Login** to get token:
   ```bash
   POST /api/admin/auth/login
   Body: { "email": "admin@senestalestari.org", "password": "admin123" }
   ```

2. **Use token** in subsequent requests:
   ```bash
   Authorization: Bearer <token-from-login>
   ```

3. **Refresh token** when needed:
   ```bash
   POST /api/admin/auth/refresh-token
   Authorization: Bearer <current-token>
   ```

---

## 📚 Interactive Documentation

For interactive testing and detailed schemas, visit:
```
http://localhost:5000/api-docs
```

---

## 💡 Tips

- All timestamps are in ISO 8601 format
- Slugs are auto-generated from titles for articles
- Use `is_active` field for soft deletes
- `order_position` controls display order
- File uploads should be handled separately (URLs only in API)

---

**Total Endpoints: 100+**
- Public: ~30 endpoints
- Admin: ~70 endpoints
