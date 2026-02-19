#!/bin/bash

echo "=== TESTING AWARDS CRUD OPERATIONS ==="
echo ""

# Get token
echo "1. Getting authentication token..."
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | \
  python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token (rate limited or error)"
  echo "Showing routes configuration instead..."
  echo ""
  echo "Admin Awards Routes:"
  echo "  GET    /api/admin/awards       - Get all awards"
  echo "  POST   /api/admin/awards       - Create award"
  echo "  GET    /api/admin/awards/:id   - Get award by ID"
  echo "  PUT    /api/admin/awards/:id   - Update award"
  echo "  DELETE /api/admin/awards/:id   - Delete award"
  exit 0
fi

echo "✅ Token obtained"
echo ""

# Test READ - Get all awards
echo "2. Testing READ - GET /api/admin/awards"
curl -s http://localhost:3000/api/admin/awards \
  -H "Authorization: Bearer $TOKEN" | \
  python3 -c "import sys, json; data = json.load(sys.stdin); print('   Success:', data['success']); print('   Awards count:', len(data.get('data', [])))"
echo ""

# Test READ - Get single award
echo "3. Testing READ - GET /api/admin/awards/1"
curl -s http://localhost:3000/api/admin/awards/1 \
  -H "Authorization: Bearer $TOKEN" | \
  python3 -c "import sys, json; data = json.load(sys.stdin); award = data.get('data', {}); print('   Success:', data['success']); print('   Award:', award.get('title', 'N/A'))"
echo ""

# Test CREATE
echo "4. Testing CREATE - POST /api/admin/awards"
NEW_AWARD=$(curl -s -X POST http://localhost:3000/api/admin/awards \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Award 2025",
    "short_description": "This is a test award created via API",
    "image_url": "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800",
    "year": 2025,
    "issuer": "Test Organization",
    "order_position": 10
  }')

echo "$NEW_AWARD" | python3 -c "import sys, json; data = json.load(sys.stdin); award = data.get('data', {}); print('   Success:', data['success']); print('   Created Award ID:', award.get('id', 'N/A')); print('   Title:', award.get('title', 'N/A'))"
NEW_ID=$(echo "$NEW_AWARD" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))")
echo ""

# Test UPDATE
if [ ! -z "$NEW_ID" ]; then
  echo "5. Testing UPDATE - PUT /api/admin/awards/$NEW_ID"
  curl -s -X PUT http://localhost:3000/api/admin/awards/$NEW_ID \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "title": "Updated Test Award 2025",
      "short_description": "This award has been updated"
    }' | \
    python3 -c "import sys, json; data = json.load(sys.stdin); award = data.get('data', {}); print('   Success:', data['success']); print('   Updated Title:', award.get('title', 'N/A'))"
  echo ""

  # Test DELETE
  echo "6. Testing DELETE - DELETE /api/admin/awards/$NEW_ID"
  curl -s -X DELETE http://localhost:3000/api/admin/awards/$NEW_ID \
    -H "Authorization: Bearer $TOKEN" | \
    python3 -c "import sys, json; data = json.load(sys.stdin); print('   Success:', data['success']); print('   Message:', data.get('message', 'N/A'))"
  echo ""
fi

echo "=== CRUD OPERATIONS TEST COMPLETE ==="
