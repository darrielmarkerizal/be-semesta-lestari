#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Program Categories API${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Get auth token
echo -e "${BLUE}Getting authentication token...${NC}"
TOKEN=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo -e "${RED}✗ Failed to get authentication token${NC}\n"
    exit 1
fi
echo -e "${GREEN}✓ Authentication token obtained${NC}\n"

# Test 1: Get all program categories (Admin)
echo -e "${BLUE}Test 1: GET /api/admin/program-categories${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/admin/program-categories" \
  -H "Authorization: Bearer $TOKEN")
echo "$RESPONSE" | jq '.'

if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
    COUNT=$(echo "$RESPONSE" | jq -r '.data | length')
    echo -e "${GREEN}✓ Retrieved $COUNT program categories${NC}\n"
else
    echo -e "${RED}✗ Failed to retrieve program categories${NC}\n"
fi

# Test 2: Create new program category
echo -e "${BLUE}Test 2: POST /api/admin/program-categories (Create)${NC}"
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/program-categories" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wildlife Protection",
    "slug": "wildlife-protection",
    "description": "Programs dedicated to protecting endangered wildlife species",
    "icon": "🦁",
    "order_position": 5,
    "is_active": true
  }')
echo "$CREATE_RESPONSE" | jq '.'

if echo "$CREATE_RESPONSE" | jq -e '.success == true' > /dev/null; then
    CATEGORY_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.id')
    echo -e "${GREEN}✓ Program category created with ID: $CATEGORY_ID${NC}\n"
else
    echo -e "${RED}✗ Failed to create program category${NC}\n"
    CATEGORY_ID=""
fi

# Test 3: Get single program category
if [ ! -z "$CATEGORY_ID" ]; then
    echo -e "${BLUE}Test 3: GET /api/admin/program-categories/$CATEGORY_ID${NC}"
    GET_RESPONSE=$(curl -s -X GET "$BASE_URL/admin/program-categories/$CATEGORY_ID" \
      -H "Authorization: Bearer $TOKEN")
    echo "$GET_RESPONSE" | jq '.'
    
    if echo "$GET_RESPONSE" | jq -e '.success == true' > /dev/null; then
        echo -e "${GREEN}✓ Retrieved program category details${NC}\n"
    else
        echo -e "${RED}✗ Failed to retrieve program category${NC}\n"
    fi
fi

# Test 4: Update program category
if [ ! -z "$CATEGORY_ID" ]; then
    echo -e "${BLUE}Test 4: PUT /api/admin/program-categories/$CATEGORY_ID (Update)${NC}"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/program-categories/$CATEGORY_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Wildlife Protection",
        "description": "Updated: Programs dedicated to protecting endangered wildlife and their habitats",
        "icon": "🦁🌿",
        "order_position": 5
      }')
    echo "$UPDATE_RESPONSE" | jq '.'
    
    if echo "$UPDATE_RESPONSE" | jq -e '.success == true' > /dev/null; then
        echo -e "${GREEN}✓ Program category updated successfully${NC}\n"
    else
        echo -e "${RED}✗ Failed to update program category${NC}\n"
    fi
fi

# Test 5: Verify footer endpoint includes program categories
echo -e "${BLUE}Test 5: GET /api/footer (Verify program categories in footer)${NC}"
FOOTER_RESPONSE=$(curl -s -X GET "$BASE_URL/footer")
FOOTER_CATEGORIES=$(echo "$FOOTER_RESPONSE" | jq -r '.data.program_categories | length')
echo "Program categories in footer: $FOOTER_CATEGORIES"

if [ "$FOOTER_CATEGORIES" -gt 0 ]; then
    echo -e "${GREEN}✓ Footer includes program categories${NC}\n"
else
    echo -e "${RED}✗ Footer does not include program categories${NC}\n"
fi

# Test 6: Delete program category
if [ ! -z "$CATEGORY_ID" ]; then
    echo -e "${BLUE}Test 6: DELETE /api/admin/program-categories/$CATEGORY_ID${NC}"
    DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/admin/program-categories/$CATEGORY_ID" \
      -H "Authorization: Bearer $TOKEN")
    echo "$DELETE_RESPONSE" | jq '.'
    
    if echo "$DELETE_RESPONSE" | jq -e '.success == true' > /dev/null; then
        echo -e "${GREEN}✓ Program category deleted successfully${NC}\n"
    else
        echo -e "${RED}✗ Failed to delete program category${NC}\n"
    fi
fi

# Test 7: Verify settings endpoints for social media
echo -e "${BLUE}Test 7: GET /api/admin/config/social_facebook${NC}"
SOCIAL_RESPONSE=$(curl -s -X GET "$BASE_URL/admin/config/social_facebook" \
  -H "Authorization: Bearer $TOKEN")
echo "$SOCIAL_RESPONSE" | jq '.'

if echo "$SOCIAL_RESPONSE" | jq -e '.success == true' > /dev/null; then
    echo -e "${GREEN}✓ Social media settings accessible${NC}\n"
else
    echo -e "${RED}✗ Failed to retrieve social media settings${NC}\n"
fi

# Test 8: Update social media setting
echo -e "${BLUE}Test 8: PUT /api/admin/config/social_facebook (Update)${NC}"
UPDATE_SOCIAL=$(curl -s -X PUT "$BASE_URL/admin/config/social_facebook" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://facebook.com/semestalestari"}')
echo "$UPDATE_SOCIAL" | jq '.'

if echo "$UPDATE_SOCIAL" | jq -e '.success == true' > /dev/null; then
    echo -e "${GREEN}✓ Social media setting updated${NC}\n"
else
    echo -e "${RED}✗ Failed to update social media setting${NC}\n"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Program Categories Tests Completed${NC}"
echo -e "${BLUE}========================================${NC}"
