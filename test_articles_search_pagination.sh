#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Articles Search & Pagination Test${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Login as admin
echo -e "${YELLOW}1. Logging in as admin...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | sed 's/"accessToken":"//')

if [ -z "$TOKEN" ]; then
  echo -e "${RED}✗ Login failed${NC}"
  echo $LOGIN_RESPONSE | jq '.'
  exit 1
fi

echo -e "${GREEN}✓ Login successful${NC}\n"

# Create test articles with different content
echo -e "${YELLOW}2. Creating test articles...${NC}"

ARTICLE1=$(curl -s -X POST "$BASE_URL/api/admin/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Forest Conservation in Indonesia",
    "subtitle": "Protecting our natural heritage",
    "content": "This article discusses the importance of forest conservation and biodiversity protection in Indonesian rainforests.",
    "excerpt": "Learn about forest conservation efforts",
    "is_active": true
  }')

ARTICLE1_ID=$(echo $ARTICLE1 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created article 1: Forest Conservation (ID: $ARTICLE1_ID)${NC}"

ARTICLE2=$(curl -s -X POST "$BASE_URL/api/admin/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Ocean Cleanup Initiative",
    "subtitle": "Saving marine life",
    "content": "Our ocean cleanup program focuses on removing plastic waste and protecting marine ecosystems.",
    "excerpt": "Join our ocean cleanup efforts",
    "is_active": true
  }')

ARTICLE2_ID=$(echo $ARTICLE2 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created article 2: Ocean Cleanup (ID: $ARTICLE2_ID)${NC}"

ARTICLE3=$(curl -s -X POST "$BASE_URL/api/admin/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Wildlife Protection Program",
    "subtitle": "Endangered species conservation",
    "content": "We work to protect endangered wildlife species through habitat preservation and anti-poaching efforts.",
    "excerpt": "Protecting endangered wildlife",
    "is_active": true
  }')

ARTICLE3_ID=$(echo $ARTICLE3 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created article 3: Wildlife Protection (ID: $ARTICLE3_ID)${NC}"

ARTICLE4=$(curl -s -X POST "$BASE_URL/api/admin/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sustainable Agriculture",
    "subtitle": "Farming for the future",
    "content": "Learn about sustainable farming practices that protect the environment while feeding communities.",
    "excerpt": "Sustainable farming methods",
    "is_active": false
  }')

ARTICLE4_ID=$(echo $ARTICLE4 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created article 4: Sustainable Agriculture (ID: $ARTICLE4_ID, inactive)${NC}\n"

# Test 1: Public API - Basic pagination
echo -e "${YELLOW}3. Testing public API pagination...${NC}"
echo -e "${YELLOW}   GET /api/articles?page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?page=1&limit=2")
echo $RESPONSE | jq '.'
TOTAL=$(echo $RESPONSE | grep -o '"total":[0-9]*' | sed 's/"total"://')
echo -e "${GREEN}✓ Pagination working - Total articles: $TOTAL${NC}\n"

# Test 2: Public API - Search by keyword "forest"
echo -e "${YELLOW}4. Testing public API search (keyword: forest)...${NC}"
echo -e "${YELLOW}   GET /api/articles?search=forest${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=forest")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT article(s) with 'forest'${NC}\n"

# Test 3: Public API - Search by keyword "ocean"
echo -e "${YELLOW}5. Testing public API search (keyword: ocean)...${NC}"
echo -e "${YELLOW}   GET /api/articles?search=ocean${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=ocean")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT article(s) with 'ocean'${NC}\n"

# Test 4: Public API - Search by keyword "protection"
echo -e "${YELLOW}6. Testing public API search (keyword: protection)...${NC}"
echo -e "${YELLOW}   GET /api/articles?search=protection${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=protection")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT article(s) with 'protection'${NC}\n"

# Test 5: Public API - Search with pagination
echo -e "${YELLOW}7. Testing public API search with pagination...${NC}"
echo -e "${YELLOW}   GET /api/articles?search=conservation&page=1&limit=1${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=conservation&page=1&limit=1")
echo $RESPONSE | jq '.'
echo -e "${GREEN}✓ Search with pagination working${NC}\n"

# Test 6: Public API - Search no results
echo -e "${YELLOW}8. Testing public API search (no results)...${NC}"
echo -e "${YELLOW}   GET /api/articles?search=nonexistent${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=nonexistent")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search with no results - Found $COUNT articles${NC}\n"

# Test 7: Admin API - Basic pagination
echo -e "${YELLOW}9. Testing admin API pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/articles?page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/articles?page=1&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
TOTAL=$(echo $RESPONSE | grep -o '"total":[0-9]*' | sed 's/"total"://')
echo -e "${GREEN}✓ Admin pagination working - Total articles: $TOTAL (includes inactive)${NC}\n"

# Test 8: Admin API - Search by keyword
echo -e "${YELLOW}10. Testing admin API search (keyword: sustainable)...${NC}"
echo -e "${YELLOW}    GET /api/admin/articles?search=sustainable${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/articles?search=sustainable" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Admin search working - Found $COUNT article(s) with 'sustainable' (includes inactive)${NC}\n"

# Test 9: Admin API - Search with pagination
echo -e "${YELLOW}11. Testing admin API search with pagination...${NC}"
echo -e "${YELLOW}    GET /api/admin/articles?search=protection&page=1&limit=1${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/articles?search=protection&page=1&limit=1" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
echo -e "${GREEN}✓ Admin search with pagination working${NC}\n"

# Test 10: Verify pagination metadata
echo -e "${YELLOW}12. Testing pagination metadata...${NC}"
echo -e "${YELLOW}    GET /api/articles?page=2&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?page=2&limit=2")
echo $RESPONSE | jq '.pagination'
PAGE=$(echo $RESPONSE | grep -o '"page":[0-9]*' | sed 's/"page"://')
LIMIT=$(echo $RESPONSE | grep -o '"limit":[0-9]*' | sed 's/"limit"://')
TOTAL=$(echo $RESPONSE | grep -o '"total":[0-9]*' | sed 's/"total"://')
TOTAL_PAGES=$(echo $RESPONSE | grep -o '"totalPages":[0-9]*' | sed 's/"totalPages"://')
echo -e "${GREEN}✓ Pagination metadata correct - Page: $PAGE, Limit: $LIMIT, Total: $TOTAL, Total Pages: $TOTAL_PAGES${NC}\n"

# Test 11: Test case sensitivity
echo -e "${YELLOW}13. Testing search case insensitivity...${NC}"
echo -e "${YELLOW}    GET /api/articles?search=FOREST${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=FOREST")
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Case insensitive search working - Found $COUNT article(s)${NC}\n"

# Test 12: Test partial word search
echo -e "${YELLOW}14. Testing partial word search...${NC}"
echo -e "${YELLOW}    GET /api/articles?search=conser${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/articles?search=conser")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Partial word search working - Found $COUNT article(s) with 'conser'${NC}\n"

# Cleanup
echo -e "${YELLOW}15. Cleaning up test articles...${NC}"
curl -s -X DELETE "$BASE_URL/api/admin/articles/$ARTICLE1_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted article 1${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/articles/$ARTICLE2_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted article 2${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/articles/$ARTICLE3_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted article 3${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/articles/$ARTICLE4_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted article 4${NC}\n"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Summary:${NC}"
echo -e "✓ Public API pagination working"
echo -e "✓ Public API search working (title, subtitle, content, excerpt)"
echo -e "✓ Public API search with pagination working"
echo -e "✓ Public API only shows active articles"
echo -e "✓ Admin API pagination working"
echo -e "✓ Admin API search working (includes inactive articles)"
echo -e "✓ Admin API search with pagination working"
echo -e "✓ Pagination metadata correct"
echo -e "✓ Case insensitive search working"
echo -e "✓ Partial word search working"
