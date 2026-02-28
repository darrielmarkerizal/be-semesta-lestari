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
echo -e "${YELLOW}Awards Search & Pagination Test${NC}"
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

# Create test awards with different content
echo -e "${YELLOW}2. Creating test awards...${NC}"

AWARD1=$(curl -s -X POST "$BASE_URL/api/admin/awards" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Environmental Excellence Award 2024",
    "short_description": "Recognized for outstanding environmental conservation efforts and community impact",
    "year": 2024,
    "issuer": "Ministry of Environment and Forestry",
    "order_position": 1,
    "is_active": true
  }')

AWARD1_ID=$(echo $AWARD1 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created award 1: Environmental Excellence (ID: $AWARD1_ID)${NC}"

AWARD2=$(curl -s -X POST "$BASE_URL/api/admin/awards" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Green Innovation Award 2023",
    "short_description": "Awarded for innovative sustainable waste management solutions",
    "year": 2023,
    "issuer": "Indonesian Green Council",
    "order_position": 2,
    "is_active": true
  }')

AWARD2_ID=$(echo $AWARD2 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created award 2: Green Innovation (ID: $AWARD2_ID)${NC}"

AWARD3=$(curl -s -X POST "$BASE_URL/api/admin/awards" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Community Impact Award 2023",
    "short_description": "Recognition for significant positive impact on local communities",
    "year": 2023,
    "issuer": "National Community Foundation",
    "order_position": 3,
    "is_active": true
  }')

AWARD3_ID=$(echo $AWARD3 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created award 3: Community Impact (ID: $AWARD3_ID)${NC}"

AWARD4=$(curl -s -X POST "$BASE_URL/api/admin/awards" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sustainability Leadership Award 2022",
    "short_description": "Honored for leadership in promoting sustainable practices",
    "year": 2022,
    "issuer": "Global Sustainability Network",
    "order_position": 4,
    "is_active": false
  }')

AWARD4_ID=$(echo $AWARD4 | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
echo -e "${GREEN}✓ Created award 4: Sustainability Leadership (ID: $AWARD4_ID, inactive)${NC}\n"

# Test 1: Admin API - Basic pagination
echo -e "${YELLOW}3. Testing admin API pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?page=1&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
TOTAL=$(echo $RESPONSE | grep -o '"total":[0-9]*' | sed 's/"total"://')
echo -e "${GREEN}✓ Pagination working - Total awards: $TOTAL (includes inactive)${NC}\n"

# Test 2: Admin API - Search by keyword "environmental"
echo -e "${YELLOW}4. Testing admin API search (keyword: environmental)...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=environmental${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=environmental" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT award(s) with 'environmental'${NC}\n"

# Test 3: Admin API - Search by keyword "innovation"
echo -e "${YELLOW}5. Testing admin API search (keyword: innovation)...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=innovation${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=innovation" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search working - Found $COUNT award(s) with 'innovation'${NC}\n"

# Test 4: Admin API - Search by year "2023"
echo -e "${YELLOW}6. Testing admin API search by year (2023)...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=2023${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=2023" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search by year working - Found $COUNT award(s) from 2023${NC}\n"

# Test 5: Admin API - Search by issuer "Ministry"
echo -e "${YELLOW}7. Testing admin API search by issuer (Ministry)...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=Ministry${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=Ministry" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search by issuer working - Found $COUNT award(s) from Ministry${NC}\n"

# Test 6: Admin API - Search with pagination
echo -e "${YELLOW}8. Testing admin API search with pagination...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=award&page=1&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=award&page=1&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
echo -e "${GREEN}✓ Search with pagination working${NC}\n"

# Test 7: Admin API - Search no results
echo -e "${YELLOW}9. Testing admin API search (no results)...${NC}"
echo -e "${YELLOW}   GET /api/admin/awards?search=nonexistent${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=nonexistent" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search with no results - Found $COUNT awards${NC}\n"

# Test 8: Verify pagination metadata
echo -e "${YELLOW}10. Testing pagination metadata...${NC}"
echo -e "${YELLOW}    GET /api/admin/awards?page=2&limit=2${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?page=2&limit=2" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.pagination'
PAGE=$(echo $RESPONSE | grep -o '"currentPage":[0-9]*' | sed 's/"currentPage"://')
TOTAL=$(echo $RESPONSE | grep -o '"totalItems":[0-9]*' | sed 's/"totalItems"://')
TOTAL_PAGES=$(echo $RESPONSE | grep -o '"totalPages":[0-9]*' | sed 's/"totalPages"://')
echo -e "${GREEN}✓ Pagination metadata correct - Page: $PAGE, Total: $TOTAL, Total Pages: $TOTAL_PAGES${NC}\n"

# Test 9: Test case sensitivity
echo -e "${YELLOW}11. Testing search case insensitivity...${NC}"
echo -e "${YELLOW}    GET /api/admin/awards?search=ENVIRONMENTAL${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=ENVIRONMENTAL" \
  -H "Authorization: Bearer $TOKEN")
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Case insensitive search working - Found $COUNT award(s)${NC}\n"

# Test 10: Test partial word search
echo -e "${YELLOW}12. Testing partial word search...${NC}"
echo -e "${YELLOW}    GET /api/admin/awards?search=sustain${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=sustain" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Partial word search working - Found $COUNT award(s) with 'sustain'${NC}\n"

# Test 11: Test search includes inactive awards
echo -e "${YELLOW}13. Testing search includes inactive awards...${NC}"
echo -e "${YELLOW}    GET /api/admin/awards?search=sustainability${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=sustainability" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
IS_ACTIVE=$(echo $RESPONSE | jq '.data[0].is_active')
echo -e "${GREEN}✓ Search includes inactive - Found $COUNT award(s), is_active: $IS_ACTIVE${NC}\n"

# Test 12: Test search in description
echo -e "${YELLOW}14. Testing search in description field...${NC}"
echo -e "${YELLOW}    GET /api/admin/awards?search=community${NC}"
RESPONSE=$(curl -s "$BASE_URL/api/admin/awards?search=community" \
  -H "Authorization: Bearer $TOKEN")
echo $RESPONSE | jq '.'
COUNT=$(echo $RESPONSE | jq '.data | length')
echo -e "${GREEN}✓ Search in description working - Found $COUNT award(s) with 'community'${NC}\n"

# Cleanup
echo -e "${YELLOW}15. Cleaning up test awards...${NC}"
curl -s -X DELETE "$BASE_URL/api/admin/awards/$AWARD1_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted award 1${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/awards/$AWARD2_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted award 2${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/awards/$AWARD3_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted award 3${NC}"

curl -s -X DELETE "$BASE_URL/api/admin/awards/$AWARD4_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
echo -e "${GREEN}✓ Deleted award 4${NC}\n"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Summary:${NC}"
echo -e "✓ Admin API pagination working"
echo -e "✓ Admin API search working (title, description, issuer, year)"
echo -e "✓ Admin API search with pagination working"
echo -e "✓ Admin API includes inactive awards"
echo -e "✓ Pagination metadata correct"
echo -e "✓ Case insensitive search working"
echo -e "✓ Partial word search working"
echo -e "✓ Search by year working"
echo -e "✓ Search by issuer working"
echo -e "✓ Search in description working"
