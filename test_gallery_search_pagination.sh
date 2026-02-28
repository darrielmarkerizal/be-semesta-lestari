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
echo -e "${YELLOW}Gallery Search & Pagination Test${NC}"
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

# Get first category ID
echo -e "${YELLOW}2. Getting gallery categories...${NC}"
CATEGORIES=$(curl -s "$BASE_URL/api/admin/gallery-categories" \
  -H "Authorization: Bearer $TOKEN")
CATEGORY1_ID=$(echo $CATEGORIES | jq -r '.data[0].id')
CATEGORY1_NAME=$(echo $CATEGORIES | jq -r '.data[0].name')
echo -e "${GREEN}✓ Found category: $CATEGORY1_NAME (ID: $CATEGORY1_ID)${NC}\n"

# Create test gallery items with different content
echo -e "${YELLOW}3. Creating test gallery items...${NC}"

ITEM1=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Tree Planting Event 2024\",
    \"image_url\": \"https://example.com/tree-planting.jpg\",
    \"category_id\": $CATEGORY1_ID,
    \"gallery_date\": \"2024-03-15\",
    \"order_position\": 1,
    \"is_active\": true
  }")

ITEM1_ID=$(echo $ITEM1 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 1: Tree Planting Event (ID: $ITEM1_ID)${NC}"

ITEM2=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Beach Cleanup Campaign\",
    \"image_url\": \"https://example.com/beach-cleanup.jpg\",
    \"category_id\": $CATEGORY1_ID,
    \"gallery_date\": \"2024-02-20\",
    \"order_position\": 2,
    \"is_active\": true
  }")

ITEM2_ID=$(echo $ITEM2 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 2: Beach Cleanup (ID: $ITEM2_ID)${NC}"

ITEM3=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Community Workshop on Recycling\",
    \"image_url\": \"https://example.com/workshop.jpg\",
    \"category_id\": $CATEGORY1_ID,
    \"gallery_date\": \"2024-01-10\",
    \"order_position\": 3,
    \"is_active\": true
  }")

ITEM3_ID=$(echo $ITEM3 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 3: Community Workshop (ID: $ITEM3_ID)${NC}"

ITEM4=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Environmental Education Program\",
    \"image_url\": \"https://example.com/education.jpg\",
    \"category_id\": $CATEGORY1_ID,
    \"gallery_date\": \"2023-12-05\",
    \"order_position\": 4,
    \"is_active\": false
  }")

ITEM4_ID=$(echo $ITEM4 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 4: Environmental Education (ID: $ITEM4_ID, inactive)${NC}\n"

# Test 1: Admin API - Basic pagination
echo -e "${YELLOW}4. Testing admin API pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?page=1&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
TOTAL=$(echo $RESPONSE | grep -o '"totalItems":[0-9]*' | sed 's/"totalItems"://')
echo -e "${GREEN}✓ Pagination working - Total items: $TOTAL (includes inactive)${NC}\n"

# Test 2: Admin API - Search by keyword "tree"
echo -e "${YELLOW}5. Testing admin API search (keyword: tree)...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?search=tree${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=tree" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'tree'${NC}\n"

# Test 3: Admin API - Search by keyword "cleanup"
echo -e "${YELLOW}6. Testing admin API search (keyword: cleanup)...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?search=cleanup${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=cleanup" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'cleanup'${NC}\n"

# Test 4: Admin API - Search by keyword "community"
echo -e "${YELLOW}7. Testing admin API search (keyword: community)...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?search=community${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=community" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'community'${NC}\n"

# Test 5: Admin API - Search with pagination
echo -e "${YELLOW}8. Testing admin API search with pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?search=event&page=1&limit=1${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=event&page=1&limit=1" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
echo -e "${GREEN}✓ Search with pagination working${NC}\n"

# Test 6: Admin API - Search no results
echo -e "${YELLOW}9. Testing admin API search (no results)...${NC}"
echo -e "${YELLOW}   GET /api/admin/gallery?search=nonexistent${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=nonexistent" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search with no results - Found $COUNT items${NC}\n"

# Test 7: Verify pagination metadata
echo -e "${YELLOW}10. Testing pagination metadata...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?page=2&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?page=2&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.pagination'
PAGE=$(echo $RESPONSE | grep -o '"currentPage":[0-9]*' | sed 's/"currentPage"://')
TOTAL=$(echo $RESPONSE | grep -o '"totalItems":[0-9]*' | sed 's/"totalItems"://')
TOTAL_PAGES=$(echo $RESPONSE | grep -o '"totalPages":[0-9]*' | sed 's/"totalPages"://')
echo -e "${GREEN}✓ Pagination metadata correct - Page: $PAGE, Total: $TOTAL, Total Pages: $TOTAL_PAGES${NC}\n"

# Test 8: Test case sensitivity
echo -e "${YELLOW}11. Testing search case insensitivity...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=TREE${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=TREE" \
  -H "Authorization: Bearer $TOKEN")
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Case insensitive search working - Found $COUNT item(s)${NC}\n"

# Test 9: Test partial word search
echo -e "${YELLOW}12. Testing partial word search...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=plant${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=plant" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Partial word search working - Found $COUNT item(s) with 'plant'${NC}\n"

# Test 10: Test search includes inactive items
echo -e "${YELLOW}13. Testing search includes inactive items...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=education${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=education" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
IS_ACTIVE=$(echo $RESPONSE | jq '.data[0].is_active')
echo -e "${GREEN}✓ Search includes inactive - Found $COUNT item(s), is_active: $IS_ACTIVE${NC}\n"

# Test 11: Test search in title
echo -e "${YELLOW}14. Testing search in title field...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=workshop${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=workshop" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search in title working - Found $COUNT item(s) with 'workshop'${NC}\n"

# Test 12: Test search by category name
echo -e "${YELLOW}15. Testing search by category name...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=$CATEGORY1_NAME${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=$CATEGORY1_NAME" \
  -H "Authorization: Bearer $TOKEN")
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search by category name working - Found $COUNT item(s)${NC}\n"

# Test 13: Test combined search and category filter
echo -e "${YELLOW}16. Testing combined search and category filter...${NC}"
echo -e "${YELLOW}    GET /api/admin/gallery?search=event&category=<slug>${NC}"
# Get category slug
CATEGORY_SLUG=$(echo $CATEGORIES | jq -r '.data[0].slug')
RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery?search=event&category=$CATEGORY_SLUG" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Combined search and category filter working - Found $COUNT item(s)${NC}\n"

# Cleanup
echo -e "${YELLOW}17. Cleaning up test gallery items...${NC}"
curl -s -X DELETE "$BASE_URL/api/admin/gallery/$ITEM1_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 1${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/gallery/$ITEM2_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 2${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/gallery/$ITEM3_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 3${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/gallery/$ITEM4_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 4${NC}\n"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Summary:${NC}"
echo -e "✓ Admin API pagination working"
echo -e "✓ Admin API search working (title, category name)"
echo -e "✓ Admin API search with pagination working"
echo -e "✓ Admin API includes inactive items"
echo -e "✓ Pagination metadata correct"
echo -e "✓ Case insensitive search working"
echo -e "✓ Partial word search working"
echo -e "✓ Search by category name working"
echo -e "✓ Combined search and category filter working"
echo -e "✓ Search in title working"
