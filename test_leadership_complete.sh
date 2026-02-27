#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:3000"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Admin credentials
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Function to print test result
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ $2${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to check JSON field
check_field() {
    local json=$1
    local field=$2
    echo "$json" | jq -e "$field" > /dev/null 2>&1
    return $?
}

echo -e "${YELLOW}=== Leadership Section Complete Test Suite ===${NC}\n"

# Login to get token
echo "Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully logged in${NC}\n"

# ============================================
# PUBLIC ENDPOINT TESTS
# ============================================
echo -e "${YELLOW}--- Public Endpoint Tests ---${NC}"

# Test 1: GET /api/about/leadership - Returns section + items structure
RESPONSE=$(curl -s -X GET "$BASE_URL/api/about/leadership")
check_field "$RESPONSE" '.success' && \
check_field "$RESPONSE" '.data.section' && \
check_field "$RESPONSE" '.data.items'
print_result $? "GET /api/about/leadership returns section + items structure"

# Test 2: Verify section object structure
check_field "$RESPONSE" '.data.section.id' && \
check_field "$RESPONSE" '.data.section.title' && \
check_field "$RESPONSE" '.data.section.subtitle' && \
check_field "$RESPONSE" '.data.section.is_active'
print_result $? "Section object has required fields (id, title, subtitle, is_active)"

# Test 3: Verify items array structure
check_field "$RESPONSE" '.data.items | type' && \
[ "$(echo $RESPONSE | jq -r '.data.items | type')" = "array" ]
print_result $? "Items is an array"

# Test 4: Verify items have required fields
FIRST_ITEM=$(echo $RESPONSE | jq '.data.items[0]')
if [ "$FIRST_ITEM" != "null" ]; then
    check_field "$FIRST_ITEM" '.id' && \
    check_field "$FIRST_ITEM" '.name' && \
    check_field "$FIRST_ITEM" '.position' && \
    check_field "$FIRST_ITEM" '.order_position' && \
    check_field "$FIRST_ITEM" '.is_active'
    print_result $? "Leadership items have required fields"
else
    print_result 1 "Leadership items have required fields (no items found)"
fi

# ============================================
# ADMIN - SECTION SETTINGS TESTS
# ============================================
echo -e "\n${YELLOW}--- Admin Section Settings Tests ---${NC}"

# Test 5: GET /api/admin/about/leadership-section
SECTION_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN")
check_field "$SECTION_RESPONSE" '.success' && \
check_field "$SECTION_RESPONSE" '.data.title'
print_result $? "GET /api/admin/about/leadership-section retrieves settings"

# Store original section data
ORIGINAL_TITLE=$(echo $SECTION_RESPONSE | jq -r '.data.title')
ORIGINAL_SUBTITLE=$(echo $SECTION_RESPONSE | jq -r '.data.subtitle')

# Test 6: PUT /api/admin/about/leadership-section - Update title
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Updated Leadership Title"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.title')" = "Updated Leadership Title" ]
print_result $? "PUT /api/admin/about/leadership-section updates title"

# Test 7: PUT /api/admin/about/leadership-section - Update subtitle
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"subtitle":"Updated Leadership Subtitle"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.subtitle')" = "Updated Leadership Subtitle" ]
print_result $? "PUT /api/admin/about/leadership-section updates subtitle"

# Test 8: PUT /api/admin/about/leadership-section - Update image_url
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"image_url":"/uploads/leadership/test-hero.jpg"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.image_url')" = "/uploads/leadership/test-hero.jpg" ]
print_result $? "PUT /api/admin/about/leadership-section updates image_url"

# Test 9: Verify changes reflected in public endpoint
PUBLIC_RESPONSE=$(curl -s -X GET "$BASE_URL/api/about/leadership")
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.section.title')" = "Updated Leadership Title" ] && \
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.section.subtitle')" = "Updated Leadership Subtitle" ] && \
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.section.image_url')" = "/uploads/leadership/test-hero.jpg" ]
print_result $? "Section changes reflected in public endpoint"

# Test 10: Restore original section data
RESTORE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"$ORIGINAL_TITLE\",\"subtitle\":\"$ORIGINAL_SUBTITLE\",\"image_url\":null}")
check_field "$RESTORE_RESPONSE" '.success'
print_result $? "Restore original section settings"

# ============================================
# ADMIN - LEADERSHIP ITEMS CRUD TESTS
# ============================================
echo -e "\n${YELLOW}--- Admin Leadership Items CRUD Tests ---${NC}"

# Test 11: GET /api/admin/about/leadership - List all items
ITEMS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership" \
    -H "Authorization: Bearer $TOKEN")
check_field "$ITEMS_RESPONSE" '.success' && \
check_field "$ITEMS_RESPONSE" '.data' && \
[ "$(echo $ITEMS_RESPONSE | jq -r '.data | type')" = "array" ]
print_result $? "GET /api/admin/about/leadership lists all items"

# Test 12: POST /api/admin/about/leadership - Create new item
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/about/leadership" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "name":"Test Leader",
        "position":"Test Position",
        "bio":"Test bio for leadership member",
        "email":"test@example.com",
        "order_position":99
    }')
check_field "$CREATE_RESPONSE" '.success' && \
[ "$(echo $CREATE_RESPONSE | jq -r '.data.name')" = "Test Leader" ]
print_result $? "POST /api/admin/about/leadership creates new item"

# Store created item ID
CREATED_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')

# Test 13: GET /api/admin/about/leadership/:id - Get single item
SINGLE_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership/$CREATED_ID" \
    -H "Authorization: Bearer $TOKEN")
check_field "$SINGLE_RESPONSE" '.success' && \
[ "$(echo $SINGLE_RESPONSE | jq -r '.data.id')" = "$CREATED_ID" ]
print_result $? "GET /api/admin/about/leadership/:id retrieves single item"

# Test 14: PUT /api/admin/about/leadership/:id - Update item
UPDATE_ITEM_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership/$CREATED_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"Updated Test Leader","position":"Updated Position"}')
check_field "$UPDATE_ITEM_RESPONSE" '.success' && \
[ "$(echo $UPDATE_ITEM_RESPONSE | jq -r '.data.name')" = "Updated Test Leader" ]
print_result $? "PUT /api/admin/about/leadership/:id updates item"

# Test 15: Verify item appears in public endpoint
PUBLIC_ITEMS=$(curl -s -X GET "$BASE_URL/api/about/leadership")
echo "$PUBLIC_ITEMS" | jq -e ".data.items[] | select(.id == $CREATED_ID)" > /dev/null
print_result $? "Created item appears in public endpoint"

# Test 16: DELETE /api/admin/about/leadership/:id - Delete item
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/about/leadership/$CREATED_ID" \
    -H "Authorization: Bearer $TOKEN")
check_field "$DELETE_RESPONSE" '.success'
print_result $? "DELETE /api/admin/about/leadership/:id deletes item"

# Test 17: Verify item removed from public endpoint
PUBLIC_ITEMS_AFTER=$(curl -s -X GET "$BASE_URL/api/about/leadership")
echo "$PUBLIC_ITEMS_AFTER" | jq -e ".data.items[] | select(.id == $CREATED_ID)" > /dev/null
if [ $? -ne 0 ]; then
    print_result 0 "Deleted item removed from public endpoint"
else
    print_result 1 "Deleted item removed from public endpoint"
fi

# ============================================
# DATA STRUCTURE VALIDATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Data Structure Validation Tests ---${NC}"

# Test 18-25: Response structure validation
FULL_RESPONSE=$(curl -s -X GET "$BASE_URL/api/about/leadership")

check_field "$FULL_RESPONSE" '.success'
print_result $? "Response has 'success' field"

check_field "$FULL_RESPONSE" '.message'
print_result $? "Response has 'message' field"

check_field "$FULL_RESPONSE" '.data'
print_result $? "Response has 'data' field"

check_field "$FULL_RESPONSE" '.data.section'
print_result $? "Data has 'section' object"

check_field "$FULL_RESPONSE" '.data.items'
print_result $? "Data has 'items' array"

check_field "$FULL_RESPONSE" '.data.section.id'
print_result $? "Section has 'id' field"

check_field "$FULL_RESPONSE" '.data.section.title'
print_result $? "Section has 'title' field"

check_field "$FULL_RESPONSE" '.data.section.subtitle'
print_result $? "Section has 'subtitle' field"

# Test 26-35: Items structure validation
FIRST_ITEM=$(echo $FULL_RESPONSE | jq '.data.items[] | select(.email != null) | select(.phone != null)' | jq -s '.[0]')
if [ "$FIRST_ITEM" = "null" ] || [ "$FIRST_ITEM" = "" ]; then
    FIRST_ITEM=$(echo $FULL_RESPONSE | jq '.data.items[0]')
fi

if [ "$FIRST_ITEM" != "null" ]; then
    check_field "$FIRST_ITEM" '.id'
    print_result $? "Item has 'id' field"
    
    check_field "$FIRST_ITEM" '.name'
    print_result $? "Item has 'name' field"
    
    check_field "$FIRST_ITEM" '.position'
    print_result $? "Item has 'position' field"
    
    check_field "$FIRST_ITEM" '.bio'
    print_result $? "Item has 'bio' field"
    
    echo "$FIRST_ITEM" | jq -e 'has("email")' > /dev/null 2>&1
    print_result $? "Item has 'email' field"
    
    echo "$FIRST_ITEM" | jq -e 'has("phone")' > /dev/null 2>&1
    print_result $? "Item has 'phone' field"
    
    echo "$FIRST_ITEM" | jq -e 'has("linkedin_link")' > /dev/null 2>&1
    print_result $? "Item has 'linkedin_link' field"
    
    echo "$FIRST_ITEM" | jq -e 'has("instagram_link")' > /dev/null 2>&1
    print_result $? "Item has 'instagram_link' field"
    
    check_field "$FIRST_ITEM" '.is_highlighted'
    print_result $? "Item has 'is_highlighted' field"
    
    check_field "$FIRST_ITEM" '.order_position'
    print_result $? "Item has 'order_position' field"
else
    for i in {1..10}; do
        print_result 1 "Item field validation (no items found)"
    done
fi

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Authorization Tests ---${NC}"

# Test 36: Public endpoint accessible without auth
PUBLIC_NO_AUTH=$(curl -s -X GET "$BASE_URL/api/about/leadership")
check_field "$PUBLIC_NO_AUTH" '.success'
print_result $? "Public endpoint accessible without authentication"

# Test 37: Admin section endpoint requires auth
ADMIN_NO_AUTH=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership-section")
[ "$(echo $ADMIN_NO_AUTH | jq -r '.success')" = "false" ]
print_result $? "Admin section endpoint requires authentication"

# Test 38: Admin items endpoint requires auth
ADMIN_ITEMS_NO_AUTH=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership")
[ "$(echo $ADMIN_ITEMS_NO_AUTH | jq -r '.success')" = "false" ]
print_result $? "Admin items endpoint requires authentication"

# Test 39: Invalid token rejected
INVALID_TOKEN_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer invalid_token_12345")
[ "$(echo $INVALID_TOKEN_RESPONSE | jq -r '.success')" = "false" ]
print_result $? "Invalid token is rejected"

# ============================================
# EDGE CASES TESTS
# ============================================
echo -e "\n${YELLOW}--- Edge Cases Tests ---${NC}"

# Test 40: Partial update preserves other fields
CURRENT_SECTION=$(curl -s -X GET "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN")
CURRENT_SUBTITLE=$(echo $CURRENT_SECTION | jq -r '.data.subtitle')

PARTIAL_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Partial Update Test"}')
NEW_SUBTITLE=$(echo $PARTIAL_UPDATE | jq -r '.data.subtitle')

[ "$CURRENT_SUBTITLE" = "$NEW_SUBTITLE" ]
print_result $? "Partial update preserves other fields"

# Test 41: Create item with minimal required data
MINIMAL_CREATE=$(curl -s -X POST "$BASE_URL/api/admin/about/leadership" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"Minimal Leader","position":"Minimal Position"}')
check_field "$MINIMAL_CREATE" '.success'
MINIMAL_ID=$(echo $MINIMAL_CREATE | jq -r '.data.id')
print_result $? "Create item with minimal required data"

# Cleanup minimal item
if [ "$MINIMAL_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/api/admin/about/leadership/$MINIMAL_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
fi

# Test 42: Restore original data
FINAL_RESTORE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"$ORIGINAL_TITLE\",\"subtitle\":\"$ORIGINAL_SUBTITLE\"}")
check_field "$FINAL_RESTORE" '.success'
print_result $? "Final data restoration successful"

# ============================================
# SUMMARY
# ============================================
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    SUCCESS_RATE=100
else
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "\n${YELLOW}Success Rate: ${SUCCESS_RATE}%${NC}"
fi

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
    exit 0
else
    exit 1
fi
