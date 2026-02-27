#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

BASE_URL="http://localhost:3000/api"
PASSED=0
FAILED=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Impact Section - Complete Unit Tests${NC}"
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
        echo "  Response: $(echo "$response" | jq -c '.')"
        ((FAILED++))
    fi
}

# Get authentication token
echo -e "${YELLOW}Authenticating...${NC}"
TOKEN=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo -e "${RED}✗ Authentication failed${NC}\n"
    exit 1
fi
echo -e "${GREEN}✓ Authenticated${NC}\n"

# ============================================
# PUBLIC ENDPOINTS TESTS
# ============================================
echo -e "${BLUE}1. Public Endpoints${NC}"

# Test 1.1: GET /api/impact
echo -e "\n${YELLOW}Test 1.1: GET /api/impact${NC}"
IMPACT=$(curl -s "$BASE_URL/impact")
test_endpoint "Impact endpoint accessible" "$IMPACT" '.success == true'
test_endpoint "Has section object" "$IMPACT" '.data.section != null'
test_endpoint "Has items array" "$IMPACT" '.data.items | type == "array"'
test_endpoint "Section has title" "$IMPACT" '.data.section.title != null'
test_endpoint "Section has subtitle" "$IMPACT" '.data.section.subtitle != null'
test_endpoint "Items array not empty" "$IMPACT" '.data.items | length > 0'
test_endpoint "Items have required fields" "$IMPACT" '.data.items[0] | has("title") and has("stats_number")'

# Test 1.2: GET /api/home (impact section)
echo -e "\n${YELLOW}Test 1.2: GET /api/home (impact section)${NC}"
HOME=$(curl -s "$BASE_URL/home")
test_endpoint "Home endpoint accessible" "$HOME" '.success == true'
test_endpoint "Home has impact section" "$HOME" '.data.impact != null'
test_endpoint "Home impact has section" "$HOME" '.data.impact.section != null'
test_endpoint "Home impact has items" "$HOME" '.data.impact.items | type == "array"'

# ============================================
# ADMIN - SECTION SETTINGS TESTS
# ============================================
echo -e "\n${BLUE}2. Admin - Section Settings${NC}"

# Test 2.1: GET section settings
echo -e "\n${YELLOW}Test 2.1: GET /api/admin/homepage/impact-section${NC}"
SECTION=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/homepage/impact-section")
test_endpoint "Get section settings" "$SECTION" '.success == true'
test_endpoint "Section has id" "$SECTION" '.data.id != null'
test_endpoint "Section has title" "$SECTION" '.data.title != null'
test_endpoint "Section has subtitle" "$SECTION" '.data.subtitle != null'
test_endpoint "Section has image_url field" "$SECTION" '.data | has("image_url")'
test_endpoint "Section has is_active" "$SECTION" '.data.is_active != null'

# Test 2.2: UPDATE section settings
echo -e "\n${YELLOW}Test 2.2: PUT /api/admin/homepage/impact-section${NC}"
UPDATE_SECTION=$(curl -s -X PUT "$BASE_URL/admin/homepage/impact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Impact Section",
    "subtitle": "Test subtitle for unit testing",
    "image_url": "/uploads/test/impact-hero.jpg"
  }')
test_endpoint "Update section settings" "$UPDATE_SECTION" '.success == true'
test_endpoint "Title updated" "$UPDATE_SECTION" '.data.title == "Test Impact Section"'
test_endpoint "Subtitle updated" "$UPDATE_SECTION" '.data.subtitle == "Test subtitle for unit testing"'
test_endpoint "Image URL updated" "$UPDATE_SECTION" '.data.image_url == "/uploads/test/impact-hero.jpg"'

# Test 2.3: Verify changes in public endpoint
echo -e "\n${YELLOW}Test 2.3: Verify section changes in public endpoint${NC}"
VERIFY=$(curl -s "$BASE_URL/impact")
test_endpoint "Public endpoint reflects changes" "$VERIFY" '.data.section.title == "Test Impact Section"'
test_endpoint "Subtitle reflected" "$VERIFY" '.data.section.subtitle == "Test subtitle for unit testing"'

# ============================================
# ADMIN - IMPACT ITEMS TESTS
# ============================================
echo -e "\n${BLUE}3. Admin - Impact Items CRUD${NC}"

# Test 3.1: GET all items
echo -e "\n${YELLOW}Test 3.1: GET /api/admin/homepage/impact${NC}"
ITEMS=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/homepage/impact")
test_endpoint "Get all items" "$ITEMS" '.success == true'
test_endpoint "Items is array" "$ITEMS" '.data | type == "array"'
test_endpoint "Items not empty" "$ITEMS" '.data | length > 0'
INITIAL_COUNT=$(echo "$ITEMS" | jq -r '.data | length')

# Test 3.2: CREATE new item
echo -e "\n${YELLOW}Test 3.2: POST /api/admin/homepage/impact${NC}"
CREATE_ITEM=$(curl -s -X POST "$BASE_URL/admin/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Impact Item",
    "description": "Test description for unit testing",
    "stats_number": "999+",
    "icon_url": "/uploads/icons/test.svg",
    "image_url": "/uploads/impact/test-item.jpg",
    "order_position": 99,
    "is_active": true
  }')
test_endpoint "Create item" "$CREATE_ITEM" '.success == true'
test_endpoint "Item has id" "$CREATE_ITEM" '.data.id != null'
test_endpoint "Item title correct" "$CREATE_ITEM" '.data.title == "Test Impact Item"'
test_endpoint "Item stats_number correct" "$CREATE_ITEM" '.data.stats_number == "999+"'
ITEM_ID=$(echo "$CREATE_ITEM" | jq -r '.data.id')

# Test 3.3: GET single item
echo -e "\n${YELLOW}Test 3.3: GET /api/admin/homepage/impact/$ITEM_ID${NC}"
GET_ITEM=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/homepage/impact/$ITEM_ID")
test_endpoint "Get single item" "$GET_ITEM" '.success == true'
test_endpoint "Item id matches" "$GET_ITEM" ".data.id == $ITEM_ID"
test_endpoint "Item has all fields" "$GET_ITEM" '.data | has("title") and has("description") and has("stats_number")'

# Test 3.4: UPDATE item
echo -e "\n${YELLOW}Test 3.4: PUT /api/admin/homepage/impact/$ITEM_ID${NC}"
UPDATE_ITEM=$(curl -s -X PUT "$BASE_URL/admin/homepage/impact/$ITEM_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Test Item",
    "stats_number": "1,500+",
    "description": "Updated description"
  }')
test_endpoint "Update item" "$UPDATE_ITEM" '.success == true'
test_endpoint "Title updated" "$UPDATE_ITEM" '.data.title == "Updated Test Item"'
test_endpoint "Stats updated" "$UPDATE_ITEM" '.data.stats_number == "1,500+"'
test_endpoint "Description updated" "$UPDATE_ITEM" '.data.description == "Updated description"'

# Test 3.5: Verify item in public endpoint
echo -e "\n${YELLOW}Test 3.5: Verify item in public endpoint${NC}"
PUBLIC_ITEMS=$(curl -s "$BASE_URL/impact")
test_endpoint "Item appears in public endpoint" "$PUBLIC_ITEMS" ".data.items | map(select(.id == $ITEM_ID)) | length > 0"

# Test 3.6: DELETE item
echo -e "\n${YELLOW}Test 3.6: DELETE /api/admin/homepage/impact/$ITEM_ID${NC}"
DELETE_ITEM=$(curl -s -X DELETE "$BASE_URL/admin/homepage/impact/$ITEM_ID" \
  -H "Authorization: Bearer $TOKEN")
test_endpoint "Delete item" "$DELETE_ITEM" '.success == true'

# Test 3.7: Verify deletion
echo -e "\n${YELLOW}Test 3.7: Verify item deleted${NC}"
AFTER_DELETE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/homepage/impact")
test_endpoint "Item count decreased" "$AFTER_DELETE" ".data | length == $INITIAL_COUNT"

# ============================================
# DATA STRUCTURE TESTS
# ============================================
echo -e "\n${BLUE}4. Data Structure Validation${NC}"

# Test 4.1: Response structure
echo -e "\n${YELLOW}Test 4.1: Response structure validation${NC}"
STRUCTURE=$(curl -s "$BASE_URL/impact")
test_endpoint "Has success field" "$STRUCTURE" 'has("success")'
test_endpoint "Has message field" "$STRUCTURE" 'has("message")'
test_endpoint "Has data field" "$STRUCTURE" 'has("data")'
test_endpoint "Data has section" "$STRUCTURE" '.data | has("section")'
test_endpoint "Data has items" "$STRUCTURE" '.data | has("items")'

# Test 4.2: Section structure
echo -e "\n${YELLOW}Test 4.2: Section structure validation${NC}"
test_endpoint "Section has id" "$STRUCTURE" '.data.section | has("id")'
test_endpoint "Section has title" "$STRUCTURE" '.data.section | has("title")'
test_endpoint "Section has subtitle" "$STRUCTURE" '.data.section | has("subtitle")'
test_endpoint "Section has image_url" "$STRUCTURE" '.data.section | has("image_url")'
test_endpoint "Section has is_active" "$STRUCTURE" '.data.section | has("is_active")'
test_endpoint "Section has timestamps" "$STRUCTURE" '.data.section | has("created_at") and has("updated_at")'

# Test 4.3: Items structure
echo -e "\n${YELLOW}Test 4.3: Items structure validation${NC}"
test_endpoint "Items is array" "$STRUCTURE" '.data.items | type == "array"'
test_endpoint "Item has id" "$STRUCTURE" '.data.items[0] | has("id")'
test_endpoint "Item has title" "$STRUCTURE" '.data.items[0] | has("title")'
test_endpoint "Item has description" "$STRUCTURE" '.data.items[0] | has("description")'
test_endpoint "Item has stats_number" "$STRUCTURE" '.data.items[0] | has("stats_number")'
test_endpoint "Item has order_position" "$STRUCTURE" '.data.items[0] | has("order_position")'
test_endpoint "Item has is_active" "$STRUCTURE" '.data.items[0] | has("is_active")'

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "\n${BLUE}5. Authorization Tests${NC}"

# Test 5.1: Public endpoint without auth
echo -e "\n${YELLOW}Test 5.1: Public endpoint accessible without auth${NC}"
NO_AUTH=$(curl -s "$BASE_URL/impact")
test_endpoint "Public endpoint works without auth" "$NO_AUTH" '.success == true'

# Test 5.2: Admin endpoint without auth
echo -e "\n${YELLOW}Test 5.2: Admin endpoint requires auth${NC}"
NO_AUTH_ADMIN=$(curl -s "$BASE_URL/admin/homepage/impact-section")
test_endpoint "Admin endpoint rejects without auth" "$NO_AUTH_ADMIN" '.success == false'

# Test 5.3: Admin endpoint with invalid token
echo -e "\n${YELLOW}Test 5.3: Admin endpoint rejects invalid token${NC}"
INVALID_TOKEN=$(curl -s -H "Authorization: Bearer invalid_token_123" \
  "$BASE_URL/admin/homepage/impact-section")
test_endpoint "Rejects invalid token" "$INVALID_TOKEN" '.success == false'

# ============================================
# EDGE CASES
# ============================================
echo -e "\n${BLUE}6. Edge Cases${NC}"

# Test 6.1: Update with partial data
echo -e "\n${YELLOW}Test 6.1: Update section with partial data${NC}"
PARTIAL=$(curl -s -X PUT "$BASE_URL/admin/homepage/impact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Partial Update Test"}')
test_endpoint "Partial update works" "$PARTIAL" '.success == true'
test_endpoint "Title updated" "$PARTIAL" '.data.title == "Partial Update Test"'
test_endpoint "Other fields preserved" "$PARTIAL" '.data.subtitle != null'

# Test 6.2: Create item with minimal data
echo -e "\n${YELLOW}Test 6.2: Create item with minimal required data${NC}"
MINIMAL=$(curl -s -X POST "$BASE_URL/admin/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Minimal Item"}')
test_endpoint "Create with minimal data" "$MINIMAL" '.success == true'
MINIMAL_ID=$(echo "$MINIMAL" | jq -r '.data.id')

# Cleanup minimal item
curl -s -X DELETE "$BASE_URL/admin/homepage/impact/$MINIMAL_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

# ============================================
# RESTORE ORIGINAL DATA
# ============================================
echo -e "\n${YELLOW}Restoring original data...${NC}"
curl -s -X PUT "$BASE_URL/admin/homepage/impact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Amazing Impact",
    "subtitle": "Making a real difference in the world",
    "image_url": "/uploads/impact/hero.jpg"
  }' > /dev/null
echo -e "${GREEN}✓ Original data restored${NC}"

# ============================================
# SUMMARY
# ============================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))
echo -e "Success Rate: ${PERCENTAGE}%"
echo -e "Total Tests: $TOTAL"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
