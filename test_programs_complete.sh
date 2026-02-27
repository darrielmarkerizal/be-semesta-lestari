#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

BASE_URL="http://localhost:3000"
PASSED=0
FAILED=0
TOTAL=0

# Helper function
check_response() {
  local response=$1
  local expected_field=$2
  
  if echo "$response" | jq -e "$expected_field" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

print_result() {
  TOTAL=$((TOTAL + 1))
  if [ $1 -eq 0 ]; then
    echo -e "${GREEN}✓${NC} $2"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}✗${NC} $2"
    FAILED=$((FAILED + 1))
  fi
}

echo "=== Programs Section Complete Test Suite ==="
echo ""

# Login as admin
echo "Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo -e "${RED}Failed to login${NC}"
  exit 1
fi

echo "Successfully logged in"
echo ""

# ============================================
# PUBLIC API TESTS
# ============================================
echo -e "${YELLOW}--- Public API Tests ---${NC}"

# Test 1: GET /api/programs returns section and items
PUBLIC_RESPONSE=$(curl -s -X GET "$BASE_URL/api/programs")
check_response "$PUBLIC_RESPONSE" '.data.section' && \
check_response "$PUBLIC_RESPONSE" '.data.items'
print_result $? "GET /api/programs returns section and items"

# Test 2: Section has required fields
check_response "$PUBLIC_RESPONSE" '.data.section.title' && \
check_response "$PUBLIC_RESPONSE" '.data.section.subtitle'
print_result $? "Section has title and subtitle"

# Test 3: Items is an array
ITEMS_TYPE=$(echo "$PUBLIC_RESPONSE" | jq -r '.data.items | type')
[ "$ITEMS_TYPE" = "array" ]
print_result $? "Items is an array"

echo ""

# ============================================
# ADMIN SECTION TESTS
# ============================================
echo -e "${YELLOW}--- Admin Section Management Tests ---${NC}"

# Test 4: GET section
SECTION_GET=$(curl -s -X GET "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN")
check_response "$SECTION_GET" '.success' && \
[ "$(echo $SECTION_GET | jq -r '.success')" = "true" ]
print_result $? "GET /api/admin/homepage/programs-section"

# Test 5: Section has all fields
check_response "$SECTION_GET" '.data.id' && \
check_response "$SECTION_GET" '.data.title' && \
check_response "$SECTION_GET" '.data.subtitle' && \
check_response "$SECTION_GET" '.data.is_active'
print_result $? "Section has all required fields (id, title, subtitle, is_active)"

# Test 6: Update section title
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Programs Title"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.title')" = "Updated Programs Title" ]
print_result $? "PUT updates section title"

# Test 7: Update section subtitle
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subtitle": "Updated Programs Subtitle"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.subtitle')" = "Updated Programs Subtitle" ]
print_result $? "PUT updates section subtitle"

# Test 8: Update multiple fields at once
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Programs",
    "subtitle": "Making a difference through various initiatives",
    "is_active": true
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.title')" = "Our Programs" ] && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.subtitle')" = "Making a difference through various initiatives" ]
print_result $? "PUT updates multiple fields simultaneously"

# Test 9: Verify changes in public API
PUBLIC_AFTER=$(curl -s -X GET "$BASE_URL/api/programs")
[ "$(echo $PUBLIC_AFTER | jq -r '.data.section.title')" = "Our Programs" ] && \
[ "$(echo $PUBLIC_AFTER | jq -r '.data.section.subtitle')" = "Making a difference through various initiatives" ]
print_result $? "Changes reflected in public API"

echo ""

# ============================================
# ADMIN PROGRAMS CRUD TESTS
# ============================================
echo -e "${YELLOW}--- Admin Programs CRUD Tests ---${NC}"

# Test 10: GET all programs (admin)
PROGRAMS_GET=$(curl -s -X GET "$BASE_URL/api/admin/programs" \
  -H "Authorization: Bearer $TOKEN")
check_response "$PROGRAMS_GET" '.success' && \
check_response "$PROGRAMS_GET" '.data'
print_result $? "GET /api/admin/programs"

# Test 11: Pagination support
check_response "$PROGRAMS_GET" '.pagination.currentPage' && \
check_response "$PROGRAMS_GET" '.pagination.totalPages' && \
check_response "$PROGRAMS_GET" '.pagination.totalItems'
print_result $? "Admin programs endpoint supports pagination"

# Test 12: Create new program
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/programs" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Program",
    "description": "Test program description",
    "image_url": "/uploads/test-program.jpg",
    "is_highlighted": false,
    "order_position": 1,
    "is_active": true
  }')
check_response "$CREATE_RESPONSE" '.success' && \
[ "$(echo $CREATE_RESPONSE | jq -r '.data.name')" = "Test Program" ]
print_result $? "POST /api/admin/programs creates new program"

PROGRAM_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')

# Test 13: GET single program by ID
PROGRAM_GET=$(curl -s -X GET "$BASE_URL/api/admin/programs/$PROGRAM_ID" \
  -H "Authorization: Bearer $TOKEN")
check_response "$PROGRAM_GET" '.success' && \
[ "$(echo $PROGRAM_GET | jq -r '.data.id')" = "$PROGRAM_ID" ]
print_result $? "GET /api/admin/programs/:id"

# Test 14: Update program
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/programs/$PROGRAM_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test Program",
    "description": "Updated description"
  }')
check_response "$UPDATE_RESPONSE" '.success' && \
[ "$(echo $UPDATE_RESPONSE | jq -r '.data.name')" = "Updated Test Program" ]
print_result $? "PUT /api/admin/programs/:id updates program"

# Test 15: Program appears in public API
PUBLIC_PROGRAMS=$(curl -s -X GET "$BASE_URL/api/programs")
PROGRAM_EXISTS=$(echo "$PUBLIC_PROGRAMS" | jq ".data.items[] | select(.id == $PROGRAM_ID)" | wc -l | tr -d ' ')
[ "$PROGRAM_EXISTS" -gt 0 ]
print_result $? "Created program appears in public API"

# Test 16: Delete program
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/programs/$PROGRAM_ID" \
  -H "Authorization: Bearer $TOKEN")
check_response "$DELETE_RESPONSE" '.success' && \
[ "$(echo $DELETE_RESPONSE | jq -r '.success')" = "true" ]
print_result $? "DELETE /api/admin/programs/:id"

# Test 17: Deleted program not in public API
PUBLIC_AFTER_DELETE=$(curl -s -X GET "$BASE_URL/api/programs")
PROGRAM_COUNT=$(echo "$PUBLIC_AFTER_DELETE" | jq ".data.items[] | select(.id == $PROGRAM_ID)" | wc -l | tr -d ' ')
[ "$PROGRAM_COUNT" -eq 0 ]
print_result $? "Deleted program removed from public API"

echo ""

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "${YELLOW}--- Authorization Tests ---${NC}"

# Test 18: Public API doesn't require auth
PUBLIC_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/programs")
[ "$PUBLIC_NO_AUTH" = "200" ]
print_result $? "GET /api/programs doesn't require authentication"

# Test 19: Admin section GET requires auth
SECTION_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/admin/homepage/programs-section")
[ "$SECTION_NO_AUTH" = "401" ]
print_result $? "GET /api/admin/homepage/programs-section requires authentication"

# Test 20: Admin section PUT requires auth
SECTION_PUT_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test"}')
[ "$SECTION_PUT_NO_AUTH" = "401" ]
print_result $? "PUT /api/admin/homepage/programs-section requires authentication"

# Test 21: Admin programs GET requires auth
PROGRAMS_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/admin/programs")
[ "$PROGRAMS_NO_AUTH" = "401" ]
print_result $? "GET /api/admin/programs requires authentication"

# Test 22: Admin programs POST requires auth
PROGRAMS_POST_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/admin/programs" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}')
[ "$PROGRAMS_POST_NO_AUTH" = "401" ]
print_result $? "POST /api/admin/programs requires authentication"

echo ""

# ============================================
# DATA STRUCTURE TESTS
# ============================================
echo -e "${YELLOW}--- Data Structure Tests ---${NC}"

# Test 23: Public API response structure
PUBLIC_FINAL=$(curl -s -X GET "$BASE_URL/api/programs")
check_response "$PUBLIC_FINAL" '.success' && \
check_response "$PUBLIC_FINAL" '.message' && \
check_response "$PUBLIC_FINAL" '.data' && \
check_response "$PUBLIC_FINAL" '.data.section' && \
check_response "$PUBLIC_FINAL" '.data.items'
print_result $? "Public API has correct response structure"

# Test 24: Section object structure
check_response "$PUBLIC_FINAL" '.data.section.id' && \
check_response "$PUBLIC_FINAL" '.data.section.title' && \
check_response "$PUBLIC_FINAL" '.data.section.subtitle' && \
check_response "$PUBLIC_FINAL" '.data.section.is_active'
print_result $? "Section object has all required fields"

# Test 25: Items array contains program objects
FIRST_ITEM=$(echo "$PUBLIC_FINAL" | jq -r '.data.items[0]')
if [ "$FIRST_ITEM" != "null" ] && [ -n "$FIRST_ITEM" ]; then
  echo "$FIRST_ITEM" | jq -e '.id' > /dev/null 2>&1 && \
  echo "$FIRST_ITEM" | jq -e '.name' > /dev/null 2>&1 && \
  echo "$FIRST_ITEM" | jq -e '.description' > /dev/null 2>&1
  print_result $? "Program items have correct structure"
else
  echo -e "${YELLOW}⊘${NC} Program items have correct structure (no items to test)"
fi

# Test 26: Admin section response structure
ADMIN_SECTION=$(curl -s -X GET "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN")
check_response "$ADMIN_SECTION" '.success' && \
check_response "$ADMIN_SECTION" '.message' && \
check_response "$ADMIN_SECTION" '.data'
print_result $? "Admin section API has correct response structure"

# Test 27: Admin programs response structure
ADMIN_PROGRAMS=$(curl -s -X GET "$BASE_URL/api/admin/programs" \
  -H "Authorization: Bearer $TOKEN")
check_response "$ADMIN_PROGRAMS" '.success' && \
check_response "$ADMIN_PROGRAMS" '.message' && \
check_response "$ADMIN_PROGRAMS" '.data' && \
check_response "$ADMIN_PROGRAMS" '.pagination'
print_result $? "Admin programs API has correct response structure with pagination"

echo ""

# ============================================
# INTEGRATION TESTS
# ============================================
echo -e "${YELLOW}--- Integration Tests ---${NC}"

# Test 28: Section changes reflect immediately in public API
UNIQUE_TITLE="Programs Test $(date +%s)"
curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"$UNIQUE_TITLE\"}" > /dev/null

PUBLIC_CHECK=$(curl -s -X GET "$BASE_URL/api/programs")
[ "$(echo $PUBLIC_CHECK | jq -r '.data.section.title')" = "$UNIQUE_TITLE" ]
print_result $? "Section updates reflect immediately in public API"

# Restore original title
curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Our Programs","subtitle":"Making a difference through various initiatives"}' > /dev/null

# Test 29: is_active flag works
curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_active":false}' > /dev/null

INACTIVE_CHECK=$(curl -s -X GET "$BASE_URL/api/programs")
SECTION_IS_ACTIVE=$(echo "$INACTIVE_CHECK" | jq -r '.data.section.is_active')
[ "$SECTION_IS_ACTIVE" = "0" ] || [ "$SECTION_IS_ACTIVE" = "false" ]
print_result $? "is_active flag can be toggled"

# Restore active state
curl -s -X PUT "$BASE_URL/api/admin/homepage/programs-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_active":true}' > /dev/null

echo ""

# ============================================
# SUMMARY
# ============================================
echo "=== Test Summary ==="
echo "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $FAILED${NC}"
  echo ""
  exit 1
else
  echo -e "${RED}Failed: $FAILED${NC}"
  echo ""
  echo -e "${GREEN}✓ All tests passed!${NC}"
fi
