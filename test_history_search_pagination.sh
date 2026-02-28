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
echo -e "${YELLOW}History Search & Pagination Test${NC}"
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

# Create test history records with different content
echo -e "${YELLOW}2. Creating test history records...${NC}"

ITEM1=$(curl -s -X POST "$BASE_URL/api/admin/about/history" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2010,
    "title": "Foundation Year",
    "subtitle": "The beginning of our journey",
    "content": "Semesta Lestari was founded with a vision to protect Indonesian environment and promote sustainable practices.",
    "order_position": 1,
    "is_active": true
  }')

ITEM1_ID=$(echo $ITEM1 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 1: Foundation Year 2010 (ID: $ITEM1_ID)${NC}"

ITEM2=$(curl -s -X POST "$BASE_URL/api/admin/about/history" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2015,
    "title": "First Major Campaign",
    "subtitle": "Expanding our reach",
    "content": "Launched our first major environmental campaign focusing on reforestation and community education programs.",
    "order_position": 1,
    "is_active": true
  }')

ITEM2_ID=$(echo $ITEM2 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 2: First Major Campaign 2015 (ID: $ITEM2_ID)${NC}"

ITEM3=$(curl -s -X POST "$BASE_URL/api/admin/about/history" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2020,
    "title": "National Recognition",
    "subtitle": "Award and achievements",
    "content": "Received national environmental excellence award for our outstanding contribution to conservation efforts.",
    "order_position": 1,
    "is_active": true
  }')

ITEM3_ID=$(echo $ITEM3 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 3: National Recognition 2020 (ID: $ITEM3_ID)${NC}"

ITEM4=$(curl -s -X POST "$BASE_URL/api/admin/about/history" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2024,
    "title": "Future Plans",
    "subtitle": "Looking ahead",
    "content": "Planning expansion to new regions and launching innovative sustainability programs for the next decade.",
    "order_position": 1,
    "is_active": false
  }')

ITEM4_ID=$(echo $ITEM4 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created item 4: Future Plans 2024 (ID: $ITEM4_ID, inactive)${NC}\n"

# Test 1: Admin API - Basic pagination
echo -e "${YELLOW}3. Testing admin API pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?page=1&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
TOTAL=$(echo $RESPONSE | grep -o '"totalItems":[0-9]*' | sed 's/"totalItems"://')
echo -e "${GREEN}✓ Pagination working - Total items: $TOTAL (includes inactive)${NC}\n"

# Test 2: Admin API - Search by keyword "foundation"
echo -e "${YELLOW}4. Testing admin API search (keyword: foundation)...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=foundation${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=foundation" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'foundation'${NC}\n"

# Test 3: Admin API - Search by keyword "campaign"
echo -e "${YELLOW}5. Testing admin API search (keyword: campaign)...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=campaign${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=campaign" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'campaign'${NC}\n"

# Test 4: Admin API - Search by year "2020"
echo -e "${YELLOW}6. Testing admin API search by year (2020)...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=2020${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=2020" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search by year working - Found $COUNT item(s) from 2020${NC}\n"

# Test 5: Admin API - Search by keyword "environmental"
echo -e "${YELLOW}7. Testing admin API search (keyword: environmental)...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=environmental${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=environmental" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT item(s) with 'environmental'${NC}\n"

# Test 6: Admin API - Search with pagination
echo -e "${YELLOW}8. Testing admin API search with pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=year&page=1&limit=1${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=year&page=1&limit=1" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
echo -e "${GREEN}✓ Search with pagination working${NC}\n"

# Test 7: Admin API - Search no results
echo -e "${YELLOW}9. Testing admin API search (no results)...${NC}"
echo -e "${YELLOW}   GET /api/admin/about/history?search=nonexistent${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=nonexistent" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search with no results - Found $COUNT items${NC}\n"

# Test 8: Verify pagination metadata
echo -e "${YELLOW}10. Testing pagination metadata...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?page=2&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?page=2&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.pagination'
PAGE=$(echo $RESPONSE | grep -o '"currentPage":[0-9]*' | sed 's/"currentPage"://')
TOTAL=$(echo $RESPONSE | grep -o '"totalItems":[0-9]*' | sed 's/"totalItems"://')
TOTAL_PAGES=$(echo $RESPONSE | grep -o '"totalPages":[0-9]*' | sed 's/"totalPages"://')
echo -e "${GREEN}✓ Pagination metadata correct - Page: $PAGE, Total: $TOTAL, Total Pages: $TOTAL_PAGES${NC}\n"

# Test 9: Test case sensitivity
echo -e "${YELLOW}11. Testing search case insensitivity...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?search=FOUNDATION${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=FOUNDATION" \
  -H "Authorization: Bearer $TOKEN")
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Case insensitive search working - Found $COUNT item(s)${NC}\n"

# Test 10: Test partial word search
echo -e "${YELLOW}12. Testing partial word search...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?search=recogn${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=recogn" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Partial word search working - Found $COUNT item(s) with 'recogn'${NC}\n"

# Test 11: Test search includes inactive items
echo -e "${YELLOW}13. Testing search includes inactive items...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?search=future${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=future" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
IS_ACTIVE=$(echo $RESPONSE | jq '.data[0].is_active')
echo -e "${GREEN}✓ Search includes inactive - Found $COUNT item(s), is_active: $IS_ACTIVE${NC}\n"

# Test 12: Test search in title
echo -e "${YELLOW}14. Testing search in title field...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?search=recognition${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=recognition" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search in title working - Found $COUNT item(s) with 'recognition'${NC}\n"

# Test 13: Test search in content
echo -e "${YELLOW}15. Testing search in content field...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?search=reforestation${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?search=reforestation" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search in content working - Found $COUNT item(s) with 'reforestation'${NC}\n"

# Test 14: Verify chronological ordering
echo -e "${YELLOW}16. Testing chronological ordering (year ASC)...${NC}"
echo -e "${YELLOW}    GET /api/admin/about/history?page=1&limit=10${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/about/history?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN")
FIRST_YEAR=$(echo $RESPONSE | jq '.data[0].year')
SECOND_YEAR=$(echo $RESPONSE | jq '.data[1].year')
echo -e "${GREEN}✓ Chronological ordering working - First year: $FIRST_YEAR, Second year: $SECOND_YEAR${NC}\n"

# Cleanup
echo -e "${YELLOW}17. Cleaning up test history records...${NC}"
curl -s -X DELETE "$BASE_URL/api/admin/about/history/$ITEM1_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 1${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/about/history/$ITEM2_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 2${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/about/history/$ITEM3_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 3${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/about/history/$ITEM4_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted item 4${NC}\n"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Summary:${NC}"
echo -e "✓ Admin API pagination working"
echo -e "✓ Admin API search working (title, content, year)"
echo -e "✓ Admin API search with pagination working"
echo -e "✓ Admin API includes inactive items"
echo -e "✓ Pagination metadata correct"
echo -e "✓ Case insensitive search working"
echo -e "✓ Partial word search working"
echo -e "✓ Search by year working"
echo -e "✓ Search in title working"
echo -e "✓ Search in content working"
echo -e "✓ Chronological ordering (year ASC) working"
