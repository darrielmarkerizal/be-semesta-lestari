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
echo -e "${BLUE}Partners Section - Complete Unit Tests${NC}"
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

# Test 1.1: GET /api/partners
echo -e "\n${YELLOW}Test 1.1: GET /api/partners${NC}"
PARTNERS=$(curl -s "$BASE_URL/partners")
test_endpoint "Partners endpoint accessible" "$PARTNERS" '.success == true'
test_endpoint "Has section object" "$PARTNERS" '.data.section != null'
test_endpoint "Has items array" "$PARTNERS" '.data.items | type == "array"'
test_endpoint "Section has title" "$PARTNERS" '.data.section.title != null'
test_endpoint "Section has subtitle" "$PARTNERS" '.data.section.subtitle != null'
test_endpoint "Section has image_url field" "$PARTNERS" '.data.section | has("image_url")'
test_endpoint "Items array not empty" "$PARTNERS" '.data.items | length > 0'
test_endpoint "Items have required fields" "$PARTNERS" '.data.items[0] | has("name") and has("logo_url")'

# Test 1.2: GET /api/home (partners section)
echo -e "\n${YELLOW}Test 1.2: GET /api/home (partners section)${NC}"
HOME=$(curl -s "$BASE_URL/home")
test_endpoint "Home endpoint accessible" "$HOME" '.success == true'
test_endpoint "Home has partners section" "$HOME" '.data.partners != null'
test_endpoint "Home partners has section" "$HOME" '.data.partners.section != null'
test_endpoint "Home partners has items" "$HOME" '.data.partners.items | type == "array"'

# ============================================
# ADMIN - SECTION SETTINGS TESTS
# ============================================
echo -e "\n${BLUE}2. Admin - Section Settings${NC}"

# Test 2.1: GET section settings
echo -e "\n${YELLOW}Test 2.1: GET /api/admin/homepage/partners-section${NC}"
SECTION=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/homepage/partners-section")
test_endpoint "Get section settings" "$SECTION" '.success == true'
test_endpoint "Section has id" "$SECTION" '.data.id != null'
test_endpoint "Section has title" "$SECTION" '.data.title != null'
test_endpoint "Section has subtitle" "$SECTION" '.data.subtitle != null'
test_endpoint "Section has image_url field" "$SECTION" '.data | has("image_url")'
test_endpoint "Section has is_active" "$SECTION" '.data.is_active != null'

# Test 2.2: UPDATE section settings
echo -e "\n${YELLOW}Test 2.2: PUT /api/admin/homepage/partners-section${NC}"
UPDATE_SECTION=$(curl -s -X PUT "$BASE_URL/admin/homepage/partners-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Partners Section",
    "subtitle": "Test subtitle for unit testing",
    "image_url": "/uploads/test/partners-hero.jpg"
  }')
test_endpoint "Update section settings" "$UPDATE_SECTION" '.success == true'
test_endpoint "Title updated" "$UPDATE_SECTION" '.data.title == "Test Partners Section"'
test_endpoint "Subtitle updated" "$UPDATE_SECTION" '.data.subtitle == "Test subtitle for unit testing"'
test_endpoint "Image URL updated" "$UPDATE_SECTION" '.data.image_url == "/uploads/test/partners-hero.jpg"'

# Test 2.3: Verify changes in public endpoint
echo -e "\n${YELLOW}Test 2.3: Verify section changes in public endpoint${NC}"
VERIFY=$(curl -s "$BASE_URL/partners")
test_endpoint "Public endpoint reflects changes" "$VERIFY" '.data.section.title == "Test Partners Section"'
test_endpoint "Subtitle reflected" "$VERIFY" '.data.section.subtitle == "Test subtitle for unit testing"'
test_endpoint "Image URL reflected" "$VERIFY" '.data.section.image_url == "/uploads/test/partners-hero.jpg"'

# ============================================
# ADMIN - PARTNER ITEMS TESTS
# ============================================
echo -e "\n${BLUE}3. Admin - Partner Items CRUD${NC}"

# Test 3.1: GET all items
echo -e "\n${YELLOW}Test 3.1: GET /api/admin/partners${NC}"
ITEMS=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/partners")
test_endpoint "Get all items" "$ITEMS" '.success == true'
test_endpoint "Items is array" "$ITEMS" '.data | type == "array"'
test_endpoint "Items not empty" "$ITEMS" '.data | length > 0'
INITIAL_COUNT=$(echo "$ITEMS" | jq -r '.data | length')

# Test 3.2: CREATE new item
echo -e "\n${YELLOW}Test 3.2: POST /api/admin/partners${NC}"
CREATE_ITEM=$(curl -s -X POST "$BASE_URL/admin/partners" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Partner",
    "description": "Test description for unit testing",
    "logo_url": "/uploads/partners/test-logo.png",
    "website": "https://testpartner.com",
    "order_position": 99,
    "is_active": true
  }')
test_endpoint "Create item" "$CREATE_ITEM" '.success == true'
test_endpoint "Item has id" "$CREATE_ITEM" '.data.id != null'
test_endpoint "Item name correct" "$CREATE_ITEM" '.data.name == "Test Partner"'
test_endpoint "Item website correct" "$CREATE_ITEM" '.data.website == "https://testpartner.com"'
ITEM_ID=$(echo "$CREATE_ITEM" | jq -r '.data.id')

# Test 3.3: GET single item
echo -e "\n${YELLOW}Test 3.3: GET /api/admin/partners/$ITEM_ID${NC}"
GET_ITEM=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/partners/$ITEM_ID")
test_endpoint "Get single item" "$GET_ITEM" '.success == true'
test_endpoint "Item id matches" "$GET_ITEM" ".data.id == $ITEM_ID"
test_endpoint "Item has all fields" "$GET_ITEM" '.data | has("name") and has("description") and has("logo_url")'

# Test 3.4: UPDATE item
echo -e "\n${YELLOW}Test 3.4: PUT /api/admin/partners/$ITEM_ID${NC}"
UPDATE_ITEM=$(curl -s -X PUT "$BASE_URL/admin/partners/$ITEM_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test Partner",
    "website": "https://updated-partner.com",
    "description": "Updated description"
  }')
test_endpoint "Update item" "$UPDATE_ITEM" '.success == true'
test_endpoint "Name updated" "$UPDATE_ITEM" '.data.name == "Updated Test Partner"'
test_endpoint "Website updated" "$UPDATE_ITEM" '.data.website == "https://updated-partner.com"'
test_endpoint "Description updated" "$UPDATE_ITEM" '.data.description == "Updated description"'

# Test 3.5: Verify item in public endpoint
echo -e "\n${YELLOW}Test 3.5: Verify item in public endpoint${NC}"
PUBLIC_ITEMS=$(curl -s "$BASE_URL/partners")
test_endpoint "Item appears in public endpoint" "$PUBLIC_ITEMS" ".data.items | map(select(.id == $ITEM_ID)) | length > 0"

# Test 3.6: DELETE item
echo -e "\n${YELLOW}Test 3.6: DELETE /api/admin/partners/$ITEM_ID${NC}"
DELETE_ITEM=$(curl -s -X DELETE "$BASE_URL/admin/partners/$ITEM_ID" \
  -H "Authorization: Bearer $TOKEN")
test_endpoint "Delete item" "$DELETE_ITEM" '.success == true'

# Test 3.7: Verify deletion
echo -e "\n${YELLOW}Test 3.7: Verify item deleted${NC}"
AFTER_DELETE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "$BASE_URL/admin/partners")
test_endpoint "Item count decreased" "$AFTER_DELETE" ".data | length == $INITIAL_COUNT"

# ============================================
# DATA STRUCTURE TESTS
# ============================================
echo -e "\n${BLUE}4. Data Structure Validation${NC}"

# Test 4.1: Response structure
echo -e "\n${YELLOW}Test 4.1: Response structure validation${NC}"
STRUCTURE=$(curl -s "$BASE_URL/partners")
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
test_endpoint "Item has name" "$STRUCTURE" '.data.items[0] | has("name")'
test_endpoint "Item has description" "$STRUCTURE" '.data.items[0] | has("description")'
test_endpoint "Item has logo_url" "$STRUCTURE" '.data.items[0] | has("logo_url")'
test_endpoint "Item has website" "$STRUCTURE" '.data.items[0] | has("website")'
test_endpoint "Item has order_position" "$STRUCTURE" '.data.items[0] | has("order_position")'
test_endpoint "Item has is_active" "$STRUCTURE" '.data.items[0] | has("is_active")'

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "\n${BLUE}5. Authorization Tests${NC}"

# Test 5.1: Public endpoint without auth
echo -e "\n${YELLOW}Test 5.1: Public endpoint accessible without auth${NC}"
NO_AUTH=$(curl -s "$BASE_URL/partners")
test_endpoint "Public endpoint works without auth" "$NO_AUTH" '.success == true'

# Test 5.2: Admin endpoint without auth
echo -e "\n${YELLOW}Test 5.2: Admin endpoint requires auth${NC}"
NO_AUTH_ADMIN=$(curl -s "$BASE_URL/admin/homepage/partners-section")
test_endpoint "Admin endpoint rejects without auth" "$NO_AUTH_ADMIN" '.success == false'

# Test 5.3: Admin endpoint with invalid token
echo -e "\n${YELLOW}Test 5.3: Admin endpoint rejects invalid token${NC}"
INVALID_TOKEN=$(curl -s -H "Authorization: Bearer invalid_token_123" \
  "$BASE_URL/admin/homepage/partners-section")
test_endpoint "Rejects invalid token" "$INVALID_TOKEN" '.success == false'

# ============================================
# EDGE CASES
# ============================================
echo -e "\n${BLUE}6. Edge Cases${NC}"

# Test 6.1: Update with partial data
echo -e "\n${YELLOW}Test 6.1: Update section with partial data${NC}"
PARTIAL=$(curl -s -X PUT "$BASE_URL/admin/homepage/partners-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Partial Update Test"}')
test_endpoint "Partial update works" "$PARTIAL" '.success == true'
test_endpoint "Title updated" "$PARTIAL" '.data.title == "Partial Update Test"'
test_endpoint "Other fields preserved" "$PARTIAL" '.data.subtitle != null'

# Test 6.2: Create item with minimal data
echo -e "\n${YELLOW}Test 6.2: Create item with minimal required data${NC}"
MINIMAL=$(curl -s -X POST "$BASE_URL/admin/partners" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Minimal Partner"}')
test_endpoint "Create with minimal data" "$MINIMAL" '.success == true'
MINIMAL_ID=$(echo "$MINIMAL" | jq -r '.data.id')

# Cleanup minimal item
curl -s -X DELETE "$BASE_URL/admin/partners/$MINIMAL_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

# ============================================
# RESTORE ORIGINAL DATA
# ============================================
echo -e "\n${YELLOW}Restoring original data...${NC}"
curl -s -X PUT "$BASE_URL/admin/homepage/partners-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Partners",
    "subtitle": "Working together for a sustainable future",
    "image_url": null
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
