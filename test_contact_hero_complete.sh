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

echo "=== Contact Section Hero Test Suite ==="
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
# ADMIN SECTION TESTS
# ============================================
echo -e "${YELLOW}--- Admin Contact Section Tests ---${NC}"

# Test 1: GET contact section
SECTION_GET=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
check_response "$SECTION_GET" '.success' && \
[ "$(echo $SECTION_GET | jq -r '.success')" = "true" ]
print_result $? "GET /api/admin/homepage/contact-section"

# Test 2: Section has all required fields
check_response "$SECTION_GET" '.data.id' && \
check_response "$SECTION_GET" '.data.title' && \
check_response "$SECTION_GET" '.data.subtitle' && \
check_response "$SECTION_GET" '.data.image_url' && \
check_response "$SECTION_GET" '.data.description' && \
check_response "$SECTION_GET" '.data.address' && \
check_response "$SECTION_GET" '.data.email' && \
check_response "$SECTION_GET" '.data.phone' && \
check_response "$SECTION_GET" '.data.work_hours' && \
check_response "$SECTION_GET" '.data.is_active'
print_result $? "Section has all required fields (title, subtitle, image_url, description, address, email, phone, work_hours)"

# Test 3: Update title
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Contact Title"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.title')" = "Updated Contact Title" ]
print_result $? "PUT updates title"

# Test 4: Update subtitle
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subtitle": "Updated Contact Subtitle"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.subtitle')" = "Updated Contact Subtitle" ]
print_result $? "PUT updates subtitle"

# Test 5: Update image_url
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "/uploads/new-contact-hero.jpg"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.image_url')" = "/uploads/new-contact-hero.jpg" ]
print_result $? "PUT updates image_url"

# Test 6: Update description
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated description text"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.description')" = "Updated description text" ]
print_result $? "PUT updates description"

# Test 7: Update address
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "New Address 456"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.address')" = "New Address 456" ]
print_result $? "PUT updates address"

# Test 8: Update email
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newemail@example.com"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.email')" = "newemail@example.com" ]
print_result $? "PUT updates email"

# Test 9: Update phone
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+62 21 9999 8888"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.phone')" = "+62 21 9999 8888" ]
print_result $? "PUT updates phone"

# Test 10: Update work_hours
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "work_hours": "24/7"
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.work_hours')" = "24/7" ]
print_result $? "PUT updates work_hours"

# Test 11: Update multiple fields at once
SECTION_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Get in Touch",
    "subtitle": "We'\''d love to hear from you",
    "image_url": "/uploads/contact-hero.jpg",
    "description": "Have questions or want to get involved?",
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta",
    "email": "info@semestalestari.com",
    "phone": "+62 21 1234 5678",
    "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
    "is_active": true
  }')
check_response "$SECTION_UPDATE" '.success' && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.title')" = "Get in Touch" ] && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.subtitle')" = "We'd love to hear from you" ] && \
[ "$(echo $SECTION_UPDATE | jq -r '.data.image_url')" = "/uploads/contact-hero.jpg" ]
print_result $? "PUT updates multiple fields simultaneously"

echo ""

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "${YELLOW}--- Authorization Tests ---${NC}"

# Test 12: GET requires auth
SECTION_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/admin/homepage/contact-section")
[ "$SECTION_NO_AUTH" = "401" ]
print_result $? "GET /api/admin/homepage/contact-section requires authentication"

# Test 13: PUT requires auth
SECTION_PUT_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test"}')
[ "$SECTION_PUT_NO_AUTH" = "401" ]
print_result $? "PUT /api/admin/homepage/contact-section requires authentication"

echo ""

# ============================================
# DATA STRUCTURE TESTS
# ============================================
echo -e "${YELLOW}--- Data Structure Tests ---${NC}"

# Test 14: Response structure
ADMIN_SECTION=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
check_response "$ADMIN_SECTION" '.success' && \
check_response "$ADMIN_SECTION" '.message' && \
check_response "$ADMIN_SECTION" '.data'
print_result $? "Admin API has correct response structure"

# Test 15: All fields present
check_response "$ADMIN_SECTION" '.data.title' && \
check_response "$ADMIN_SECTION" '.data.subtitle' && \
check_response "$ADMIN_SECTION" '.data.image_url' && \
check_response "$ADMIN_SECTION" '.data.description' && \
check_response "$ADMIN_SECTION" '.data.address' && \
check_response "$ADMIN_SECTION" '.data.email' && \
check_response "$ADMIN_SECTION" '.data.phone' && \
check_response "$ADMIN_SECTION" '.data.work_hours'
print_result $? "All contact fields are present"

# Test 16: Field types are correct
TITLE_TYPE=$(echo "$ADMIN_SECTION" | jq -r '.data.title | type')
SUBTITLE_TYPE=$(echo "$ADMIN_SECTION" | jq -r '.data.subtitle | type')
EMAIL_TYPE=$(echo "$ADMIN_SECTION" | jq -r '.data.email | type')
[ "$TITLE_TYPE" = "string" ] && [ "$SUBTITLE_TYPE" = "string" ] && [ "$EMAIL_TYPE" = "string" ]
print_result $? "Field types are correct"

echo ""

# ============================================
# INTEGRATION TESTS
# ============================================
echo -e "${YELLOW}--- Integration Tests ---${NC}"

# Test 17: Changes persist
UNIQUE_TITLE="Contact Test $(date +%s)"
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"$UNIQUE_TITLE\"}" > /dev/null

sleep 1

CHECK_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
[ "$(echo $CHECK_RESPONSE | jq -r '.data.title')" = "$UNIQUE_TITLE" ]
print_result $? "Changes persist after update"

# Restore original title
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Get in Touch","subtitle":"We'\''d love to hear from you"}' > /dev/null

# Test 18: is_active flag works
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_active":false}' > /dev/null

INACTIVE_CHECK=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
SECTION_IS_ACTIVE=$(echo "$INACTIVE_CHECK" | jq -r '.data.is_active')
[ "$SECTION_IS_ACTIVE" = "0" ] || [ "$SECTION_IS_ACTIVE" = "false" ]
print_result $? "is_active flag can be toggled"

# Restore active state
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_active":true}' > /dev/null

# Test 19: Partial updates work
BEFORE_EMAIL=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.data.email')

curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+62 21 5555 6666"}' > /dev/null

AFTER_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
AFTER_EMAIL=$(echo "$AFTER_RESPONSE" | jq -r '.data.email')
AFTER_PHONE=$(echo "$AFTER_RESPONSE" | jq -r '.data.phone')

[ "$BEFORE_EMAIL" = "$AFTER_EMAIL" ] && [ "$AFTER_PHONE" = "+62 21 5555 6666" ]
print_result $? "Partial updates preserve other fields"

# Restore original phone
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+62 21 1234 5678"}' > /dev/null

# Test 20: Empty string updates work
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"work_hours":""}' > /dev/null

EMPTY_CHECK=$(curl -s -X GET "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN")
WORK_HOURS=$(echo "$EMPTY_CHECK" | jq -r '.data.work_hours')
[ "$WORK_HOURS" = "" ]
print_result $? "Empty string updates work"

# Restore work hours
curl -s -X PUT "$BASE_URL/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"work_hours":"Monday - Friday: 9:00 AM - 5:00 PM"}' > /dev/null

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
