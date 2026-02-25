#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Complete Footer System Test${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to test endpoint
test_endpoint() {
    local test_name=$1
    local response=$2
    local expected=$3
    
    if echo "$response" | jq -e "$expected" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $test_name${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ $test_name${NC}"
        ((FAILED++))
    fi
}

# Get auth token
echo -e "${YELLOW}Authenticating...${NC}"
TOKEN=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo -e "${RED}✗ Authentication failed${NC}\n"
    exit 1
fi
echo -e "${GREEN}✓ Authenticated${NC}\n"

# Test 1: Footer endpoint returns all required data
echo -e "${BLUE}1. Testing Footer Endpoint${NC}"
FOOTER=$(curl -s -X GET "$BASE_URL/footer")
test_endpoint "Footer endpoint accessible" "$FOOTER" '.success == true'
test_endpoint "Contact email present" "$FOOTER" '.data.contact.email != ""'
test_endpoint "Contact phones array present" "$FOOTER" '.data.contact.phones | length > 0'
test_endpoint "Contact address present" "$FOOTER" '.data.contact.address != ""'
test_endpoint "Work hours present" "$FOOTER" '.data.contact.work_hours != ""'
test_endpoint "Facebook link present" "$FOOTER" '.data.social_media.facebook != ""'
test_endpoint "Instagram link present" "$FOOTER" '.data.social_media.instagram != ""'
test_endpoint "Twitter link present" "$FOOTER" '.data.social_media.twitter != ""'
test_endpoint "YouTube link present" "$FOOTER" '.data.social_media.youtube != ""'
test_endpoint "LinkedIn link present" "$FOOTER" '.data.social_media.linkedin != ""'
test_endpoint "TikTok link present" "$FOOTER" '.data.social_media.tiktok != ""'
test_endpoint "Program categories present" "$FOOTER" '.data.program_categories | length > 0'
echo ""

# Test 2: Program Categories CRUD
echo -e "${BLUE}2. Testing Program Categories CRUD${NC}"
CATEGORIES=$(curl -s -X GET "$BASE_URL/admin/program-categories" -H "Authorization: Bearer $TOKEN")
test_endpoint "Get all categories" "$CATEGORIES" '.success == true'
test_endpoint "Categories have required fields" "$CATEGORIES" '.data[0] | has("name") and has("slug") and has("icon")'

# Create category
CREATE=$(curl -s -X POST "$BASE_URL/admin/program-categories" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Category","slug":"test-category","description":"Test","icon":"🧪","order_position":99}')
test_endpoint "Create category" "$CREATE" '.success == true'
CAT_ID=$(echo "$CREATE" | jq -r '.data.id')

# Update category
if [ ! -z "$CAT_ID" ] && [ "$CAT_ID" != "null" ]; then
    UPDATE=$(curl -s -X PUT "$BASE_URL/admin/program-categories/$CAT_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"description":"Updated description"}')
    test_endpoint "Update category" "$UPDATE" '.success == true'
    
    # Delete category
    DELETE=$(curl -s -X DELETE "$BASE_URL/admin/program-categories/$CAT_ID" \
      -H "Authorization: Bearer $TOKEN")
    test_endpoint "Delete category" "$DELETE" '.success == true'
fi
echo ""

# Test 3: Settings Management
echo -e "${BLUE}3. Testing Settings Management${NC}"
SETTING=$(curl -s -X GET "$BASE_URL/admin/config/contact_email" -H "Authorization: Bearer $TOKEN")
test_endpoint "Get contact email setting" "$SETTING" '.success == true'

SETTING=$(curl -s -X GET "$BASE_URL/admin/config/social_facebook" -H "Authorization: Bearer $TOKEN")
test_endpoint "Get social media setting" "$SETTING" '.success == true'
echo ""

# Test 4: Programs with Categories
echo -e "${BLUE}4. Testing Programs with Categories${NC}"
PROGRAMS=$(curl -s -X GET "$BASE_URL/programs")
test_endpoint "Get programs" "$PROGRAMS" '.success == true'
test_endpoint "Programs have category_id field" "$PROGRAMS" '.data[0] | has("category_id")'

# Update program with category
PROGRAM_ID=$(echo "$PROGRAMS" | jq -r '.data[0].id')
if [ ! -z "$PROGRAM_ID" ] && [ "$PROGRAM_ID" != "null" ]; then
    UPDATE_PROG=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"category_id":1}')
    test_endpoint "Update program with category" "$UPDATE_PROG" '.success == true'
fi
echo ""

# Test 5: Data Consistency
echo -e "${BLUE}5. Testing Data Consistency${NC}"
FOOTER_CATS=$(curl -s -X GET "$BASE_URL/footer" | jq -r '.data.program_categories | length')
ADMIN_CATS=$(curl -s -X GET "$BASE_URL/admin/program-categories" -H "Authorization: Bearer $TOKEN" | jq -r '.data | length')

if [ "$FOOTER_CATS" == "$ADMIN_CATS" ]; then
    echo -e "${GREEN}✓ Footer and admin categories count match ($FOOTER_CATS)${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ Footer ($FOOTER_CATS) and admin ($ADMIN_CATS) categories count mismatch${NC}"
    ((FAILED++))
fi
echo ""

# Test 6: API Documentation
echo -e "${BLUE}6. Testing API Documentation${NC}"
DOCS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api-docs/")
if [ "$DOCS" == "200" ]; then
    echo -e "${GREEN}✓ API documentation accessible at /api-docs${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ API documentation not accessible${NC}"
    ((FAILED++))
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))
echo -e "Success Rate: ${PERCENTAGE}%"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
