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

echo -e "${YELLOW}=== Contact Section Complete Test Suite ===${NC}\n"

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

# Test 1: GET /api/home - Returns contact section
HOME_RESPONSE=$(curl -s -X GET "$BASE_URL/api/home")
check_field "$HOME_RESPONSE" '.success' && \
check_field "$HOME_RESPONSE" '.data.contact'
print_result $? "GET /api/home returns contact section"

# Test 2: Verify contact object structure
CONTACT=$(echo $HOME_RESPONSE | jq '.data.contact')
check_field "$CONTACT" '.id' && \
check_field "$CONTACT" '.title' && \
check_field "$CONTACT" '.description' && \
check_field "$CONTACT" '.email' && \
check_field "$CONTACT" '.phone' && \
check_field "$CONTACT" '.address' && \
check_field "$CONTACT" '.work_hours'
print_result $? "Contact object has all required fields"

# Test 3: Verify field types
[ "$(echo $CONTACT | jq -r '.title | type')" = "string" ] && \
[ "$(echo $CONTACT | jq -r '.description | type')" = "string" ] && \
[ "$(echo $CONTACT | jq -r '.phone | type')" = "string" ]
print_result $? "Contact fields have correct types"

# ============================================
# ADMIN - SECTION SETTINGS TESTS
# ============================================
echo -e "\n${YELLOW}--- Admin Section Settings Tests ---${NC}"

# Test 4: GET /api/admin/homepage/contact-section
SECTION_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN")
check_field "$SECTION_RESPONSE" '.success' && \
check_field "$SECTION_RESPONSE" '.data.title'
print_result $? "GET /api/admin/homepage/contact-section retrieves settings"

# Store original section data
ORIGINAL_TITLE=$(echo $SECTION_RESPONSE | jq -r '.data.title')
ORIGINAL_DESCRIPTION=$(echo $SECTION_RESPONSE | jq -r '.data.description')
ORIGINAL_PHONE=$(echo $SECTION_RESPONSE | jq -r '.data.phone')
ORIGINAL_EMAIL=$(echo $SECTION_RESPONSE | jq -r '.data.email')
ORIGINAL_ADDRESS=$(echo $SECTION_RESPONSE | jq -r '.data.address')
ORIGINAL_WORK_HOURS=$(echo $SECTION_RESPONSE | jq -r '.data.work_hours')

# Test 5: PUT /api/admin/homepage/contact-section - Update title
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Updated Contact Title"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.title')" = "Updated Contact Title" ]
print_result $? "PUT /api/admin/homepage/contact-section updates title"

# Test 6: PUT /api/admin/homepage/contact-section - Update description
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"description":"Updated contact description"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.description')" = "Updated contact description" ]
print_result $? "PUT /api/admin/homepage/contact-section updates description"

# Test 7: PUT /api/admin/homepage/contact-section - Update phone
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"phone":"+62 21 9999 8888"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.phone')" = "+62 21 9999 8888" ]
print_result $? "PUT /api/admin/homepage/contact-section updates phone"

# Test 8: PUT /api/admin/homepage/contact-section - Update email
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"email":"updated@example.com"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.email')" = "updated@example.com" ]
print_result $? "PUT /api/admin/homepage/contact-section updates email"

# Test 9: PUT /api/admin/homepage/contact-section - Update address
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"address":"Updated Address, Jakarta"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.address')" = "Updated Address, Jakarta" ]
print_result $? "PUT /api/admin/homepage/contact-section updates address"

# Test 10: PUT /api/admin/homepage/contact-section - Update work_hours
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"work_hours":"Monday - Sunday: 24/7"}')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.work_hours')" = "Monday - Sunday: 24/7" ]
print_result $? "PUT /api/admin/homepage/contact-section updates work_hours"

# Test 11: Verify changes reflected in public endpoint
PUBLIC_RESPONSE=$(curl -s -X GET "$BASE_URL/api/home")
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.contact.title')" = "Updated Contact Title" ] && \
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.contact.description')" = "Updated contact description" ] && \
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.contact.phone')" = "+62 21 9999 8888" ] && \
[ "$(echo $PUBLIC_RESPONSE | jq -r '.data.contact.email')" = "updated@example.com" ]
print_result $? "Section changes reflected in public endpoint"

# Test 12: PUT /api/admin/homepage/contact-section - Update multiple fields at once
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "title":"Multi Update Test",
        "description":"Testing multiple fields",
        "phone":"+62 21 1111 2222",
        "email":"multi@test.com"
    }')
check_field "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.title')" = "Multi Update Test" ] && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.description')" = "Testing multiple fields" ] && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.phone')" = "+62 21 1111 2222" ] && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.email')" = "multi@test.com" ]
print_result $? "PUT /api/admin/homepage/contact-section updates multiple fields"

# ============================================
# DATA STRUCTURE VALIDATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Data Structure Validation Tests ---${NC}"

# Test 13-20: Response structure validation
FULL_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN")

check_field "$FULL_RESPONSE" '.success'
print_result $? "Response has 'success' field"

check_field "$FULL_RESPONSE" '.message'
print_result $? "Response has 'message' field"

check_field "$FULL_RESPONSE" '.data'
print_result $? "Response has 'data' field"

check_field "$FULL_RESPONSE" '.data.id'
print_result $? "Data has 'id' field"

check_field "$FULL_RESPONSE" '.data.title'
print_result $? "Data has 'title' field"

check_field "$FULL_RESPONSE" '.data.description'
print_result $? "Data has 'description' field"

check_field "$FULL_RESPONSE" '.data.email'
print_result $? "Data has 'email' field"

check_field "$FULL_RESPONSE" '.data.phone'
print_result $? "Data has 'phone' field"

# Test 21-24: Additional fields
check_field "$FULL_RESPONSE" '.data.address'
print_result $? "Data has 'address' field"

check_field "$FULL_RESPONSE" '.data.work_hours'
print_result $? "Data has 'work_hours' field"

check_field "$FULL_RESPONSE" '.data.is_active'
print_result $? "Data has 'is_active' field"

check_field "$FULL_RESPONSE" '.data.created_at'
print_result $? "Data has 'created_at' field"

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Authorization Tests ---${NC}"

# Test 25: Public endpoint accessible without auth
PUBLIC_NO_AUTH=$(curl -s -X GET "$BASE_URL/api/home")
check_field "$PUBLIC_NO_AUTH" '.success'
print_result $? "Public endpoint accessible without authentication"

# Test 26: Admin endpoint requires auth
ADMIN_NO_AUTH=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section")
[ "$(echo $ADMIN_NO_AUTH | jq -r '.success')" = "false" ]
print_result $? "Admin endpoint requires authentication"

# Test 27: Invalid token rejected
INVALID_TOKEN_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer invalid_token_12345")
[ "$(echo $INVALID_TOKEN_RESPONSE | jq -r '.success')" = "false" ]
print_result $? "Invalid token is rejected"

# Test 28: PUT requires authentication
PUT_NO_AUTH=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Content-Type: application/json" \
    -d '{"title":"Test"}')
[ "$(echo $PUT_NO_AUTH | jq -r '.success')" = "false" ]
print_result $? "PUT endpoint requires authentication"

# ============================================
# EDGE CASES TESTS
# ============================================
echo -e "\n${YELLOW}--- Edge Cases Tests ---${NC}"

# Test 29: Partial update preserves other fields
CURRENT_SECTION=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN")
CURRENT_EMAIL=$(echo $CURRENT_SECTION | jq -r '.data.email')

PARTIAL_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"title":"Partial Update Test"}')
NEW_EMAIL=$(echo $PARTIAL_UPDATE | jq -r '.data.email')

[ "$CURRENT_EMAIL" = "$NEW_EMAIL" ]
print_result $? "Partial update preserves other fields"

# Test 30: Empty string updates
EMPTY_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"description":""}')
check_field "$EMPTY_UPDATE" '.success'
print_result $? "Empty string updates are accepted"

# Test 31: Update with special characters
SPECIAL_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"description":"Test with special chars: @#$%^&*()"}')
check_field "$SPECIAL_UPDATE" '.success' && \
[ "$(echo $SPECIAL_UPDATE | jq -r '.data.description')" = "Test with special chars: @#$%^&*()" ]
print_result $? "Special characters in updates are handled"

# Test 32: Long text in description
LONG_TEXT="This is a very long description that contains multiple sentences and should be stored properly in the database without any truncation issues. It includes various punctuation marks, numbers like 123, and special characters."
LONG_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"description\":\"$LONG_TEXT\"}")
check_field "$LONG_UPDATE" '.success'
print_result $? "Long text in description is handled"

# Test 33: Update is_active field
ACTIVE_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"is_active":false}')
check_field "$ACTIVE_UPDATE" '.success' && \
[ "$(echo $ACTIVE_UPDATE | jq -r '.data.is_active')" = "0" -o "$(echo $ACTIVE_UPDATE | jq -r '.data.is_active')" = "false" ]
print_result $? "is_active field can be updated"

# Restore is_active to true
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"is_active":true}' > /dev/null

# Test 34: Restore original data
FINAL_RESTORE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\":\"$ORIGINAL_TITLE\",
        \"description\":\"$ORIGINAL_DESCRIPTION\",
        \"phone\":\"$ORIGINAL_PHONE\",
        \"email\":\"$ORIGINAL_EMAIL\",
        \"address\":\"$ORIGINAL_ADDRESS\",
        \"work_hours\":\"$ORIGINAL_WORK_HOURS\"
    }")
check_field "$FINAL_RESTORE" '.success'
print_result $? "Final data restoration successful"

# ============================================
# INTEGRATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Integration Tests ---${NC}"

# Test 35: Verify data consistency between admin and public endpoints
ADMIN_DATA=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
    -H "Authorization: Bearer $TOKEN")
PUBLIC_DATA=$(curl -s -X GET "$BASE_URL/api/home")

ADMIN_TITLE=$(echo $ADMIN_DATA | jq -r '.data.title')
PUBLIC_TITLE=$(echo $PUBLIC_DATA | jq -r '.data.contact.title')

[ "$ADMIN_TITLE" = "$PUBLIC_TITLE" ]
print_result $? "Data consistency between admin and public endpoints"

# Test 36: Verify all fields match between endpoints
ADMIN_PHONE=$(echo $ADMIN_DATA | jq -r '.data.phone')
PUBLIC_PHONE=$(echo $PUBLIC_DATA | jq -r '.data.contact.phone')
ADMIN_EMAIL=$(echo $ADMIN_DATA | jq -r '.data.email')
PUBLIC_EMAIL=$(echo $PUBLIC_DATA | jq -r '.data.contact.email')

[ "$ADMIN_PHONE" = "$PUBLIC_PHONE" ] && [ "$ADMIN_EMAIL" = "$PUBLIC_EMAIL" ]
print_result $? "All fields match between admin and public endpoints"

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
