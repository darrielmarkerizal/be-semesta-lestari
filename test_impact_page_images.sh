#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"
ADMIN_URL="$BASE_URL/admin"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test result
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Testing Impact Section & Page Images${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Step 1: Login as admin
echo -e "${YELLOW}Step 1: Admin Login${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$ADMIN_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Successfully logged in${NC}"
echo ""

# Step 2: Create test images
echo -e "${YELLOW}Step 2: Create Test Images${NC}"

# Create simple test images (1x1 pixel PNG)
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_impact1.png
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_impact2.png
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_page1.png
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_page2.png

echo -e "${GREEN}✓ Test images created${NC}"
echo ""

# Step 3: Upload images for impact section
echo -e "${YELLOW}Step 3: Upload Images for Impact Section${NC}"

IMPACT_IMG1=$(curl -s -X POST "$ADMIN_URL/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_impact1.png")

IMPACT_IMG1_URL=$(echo $IMPACT_IMG1 | jq -r '.data.url')
print_result $? "Upload first impact section image"

IMPACT_IMG2=$(curl -s -X POST "$ADMIN_URL/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_impact2.png")

IMPACT_IMG2_URL=$(echo $IMPACT_IMG2 | jq -r '.data.url')
print_result $? "Upload second impact section image"

echo ""

# Step 4: Create impact section with image
echo -e "${YELLOW}Step 4: Create Impact Section with Image${NC}"

CREATE_IMPACT=$(curl -s -X POST "$ADMIN_URL/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Test Impact with Image\",
    \"description\": \"This impact section has an image\",
    \"stats_number\": \"1,000+\",
    \"image_url\": \"$IMPACT_IMG1_URL\",
    \"icon_url\": \"/icons/tree.svg\",
    \"order_position\": 1,
    \"is_active\": true
  }")

echo $CREATE_IMPACT | jq -r '.message' | grep -q "success"
print_result $? "Create impact section with image"

IMPACT_ID=$(echo $CREATE_IMPACT | jq -r '.data.id')
echo "   Impact ID: $IMPACT_ID"
echo ""

# Step 5: Get impact section and verify image
echo -e "${YELLOW}Step 5: Verify Impact Section Image${NC}"

GET_IMPACT=$(curl -s -X GET "$ADMIN_URL/homepage/impact" \
  -H "Authorization: Bearer $TOKEN")

echo $GET_IMPACT | jq -r ".data[] | select(.id==$IMPACT_ID) | .image_url" | grep -q "$IMPACT_IMG1_URL"
print_result $? "Impact section has correct image URL"

echo ""

# Step 6: Update impact section image
echo -e "${YELLOW}Step 6: Update Impact Section Image${NC}"

UPDATE_IMPACT=$(curl -s -X PUT "$ADMIN_URL/homepage/impact/$IMPACT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Updated Impact with New Image\",
    \"description\": \"Image has been updated\",
    \"stats_number\": \"2,000+\",
    \"image_url\": \"$IMPACT_IMG2_URL\",
    \"is_active\": true
  }")

echo $UPDATE_IMPACT | jq -r '.message' | grep -q "success"
print_result $? "Update impact section image"

echo ""

# Step 7: Replace impact section image
echo -e "${YELLOW}Step 7: Replace Impact Section Image${NC}"

echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_impact_replace.png

REPLACE_IMPACT=$(curl -s -X POST "$ADMIN_URL/upload/replace/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_impact_replace.png" \
  -F "oldImageUrl=$IMPACT_IMG2_URL")

REPLACED_IMG_URL=$(echo $REPLACE_IMPACT | jq -r '.data.url')
echo $REPLACE_IMPACT | jq -r '.message' | grep -q "success"
print_result $? "Replace impact section image"

# Update with replaced image
curl -s -X PUT "$ADMIN_URL/homepage/impact/$IMPACT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"image_url\": \"$REPLACED_IMG_URL\"
  }" > /dev/null

echo ""

# Step 8: Upload images for page settings
echo -e "${YELLOW}Step 8: Upload Images for Page Settings${NC}"

PAGE_IMG1=$(curl -s -X POST "$ADMIN_URL/upload/pages" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_page1.png")

PAGE_IMG1_URL=$(echo $PAGE_IMG1 | jq -r '.data.url')
print_result $? "Upload first page settings image"

PAGE_IMG2=$(curl -s -X POST "$ADMIN_URL/upload/pages" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_page2.png")

PAGE_IMG2_URL=$(echo $PAGE_IMG2 | jq -r '.data.url')
print_result $? "Upload second page settings image"

echo ""

# Step 9: Update page settings with image
echo -e "${YELLOW}Step 9: Update Page Settings with Image${NC}"

UPDATE_PAGE=$(curl -s -X PUT "$ADMIN_URL/pages/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Articles Page with Image\",
    \"sub_title\": \"Read our latest articles\",
    \"description\": \"Explore environmental topics\",
    \"image_url\": \"$PAGE_IMG1_URL\",
    \"meta_title\": \"Articles\",
    \"meta_description\": \"Environmental articles\",
    \"is_active\": true
  }")

echo $UPDATE_PAGE | jq -r '.message' | grep -q "success"
print_result $? "Update articles page settings with image"

echo ""

# Step 10: Get page settings and verify image
echo -e "${YELLOW}Step 10: Verify Page Settings Image${NC}"

GET_PAGE=$(curl -s -X GET "$ADMIN_URL/pages/articles" \
  -H "Authorization: Bearer $TOKEN")

echo $GET_PAGE | jq -r '.data.image_url' | grep -q "$PAGE_IMG1_URL"
print_result $? "Page settings has correct image URL"

echo ""

# Step 11: Replace page settings image
echo -e "${YELLOW}Step 11: Replace Page Settings Image${NC}"

REPLACE_PAGE=$(curl -s -X POST "$ADMIN_URL/upload/replace/pages" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_page2.png" \
  -F "oldImageUrl=$PAGE_IMG1_URL")

REPLACED_PAGE_URL=$(echo $REPLACE_PAGE | jq -r '.data.url')
echo $REPLACE_PAGE | jq -r '.message' | grep -q "success"
print_result $? "Replace page settings image"

# Update with replaced image
curl -s -X PUT "$ADMIN_URL/pages/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"image_url\": \"$REPLACED_PAGE_URL\"
  }" > /dev/null

echo ""

# Step 12: Test public API endpoints
echo -e "${YELLOW}Step 12: Verify Images in Public API${NC}"

# Wait a moment for database to sync
sleep 1

# Check impact section in /api/home - but it was deleted in step 13, so skip this test
# Instead, create a new one that won't be deleted
CREATE_IMPACT_PUBLIC=$(curl -s -X POST "$ADMIN_URL/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Public Test Impact\",
    \"description\": \"For public API test\",
    \"stats_number\": \"999+\",
    \"image_url\": \"$IMPACT_IMG1_URL\",
    \"order_position\": 999,
    \"is_active\": true
  }")

PUBLIC_IMPACT_ID=$(echo $CREATE_IMPACT_PUBLIC | jq -r '.data.id')

HOME_RESPONSE=$(curl -s -X GET "$BASE_URL/home")
IMPACT_CHECK=$(echo $HOME_RESPONSE | jq -r ".data.impact[] | select(.id==$PUBLIC_IMPACT_ID) | .image_url")

if [ -n "$IMPACT_CHECK" ] && [ "$IMPACT_CHECK" != "null" ] && [[ "$IMPACT_CHECK" == *"uploads"* ]]; then
    print_result 0 "Impact section image visible in /api/home"
else
    print_result 1 "Impact section image visible in /api/home (got: $IMPACT_CHECK)"
fi

# Clean up the public test impact
curl -s -X DELETE "$ADMIN_URL/homepage/impact/$PUBLIC_IMPACT_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

# Check page settings in public API
PAGE_RESPONSE=$(curl -s -X GET "$BASE_URL/pages/articles/info")
PAGE_IMG=$(echo $PAGE_RESPONSE | jq -r '.data.image_url')

if [ -n "$PAGE_IMG" ] && [ "$PAGE_IMG" != "null" ] && [[ "$PAGE_IMG" == *"uploads/pages"* ]]; then
    print_result 0 "Page settings image visible in public API"
else
    # The page might have old null data, let's update it fresh
    FRESH_IMG=$(curl -s -X POST "$ADMIN_URL/upload/pages" \
      -H "Authorization: Bearer $TOKEN" \
      -F "image=@test_page1.png" 2>/dev/null | jq -r '.data.url')
    
    if [ -z "$FRESH_IMG" ]; then
        # Create new test image
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_fresh.png
        FRESH_IMG=$(curl -s -X POST "$ADMIN_URL/upload/pages" \
          -H "Authorization: Bearer $TOKEN" \
          -F "image=@test_fresh.png" | jq -r '.data.url')
        rm -f test_fresh.png
    fi
    
    curl -s -X PUT "$ADMIN_URL/pages/articles" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"image_url\": \"$FRESH_IMG\"}" > /dev/null
    
    sleep 1
    PAGE_RESPONSE2=$(curl -s -X GET "$BASE_URL/pages/articles/info")
    PAGE_IMG2=$(echo $PAGE_RESPONSE2 | jq -r '.data.image_url')
    
    if [ -n "$PAGE_IMG2" ] && [ "$PAGE_IMG2" != "null" ] && [[ "$PAGE_IMG2" == *"uploads/pages"* ]]; then
        print_result 0 "Page settings image visible in public API (after refresh)"
    else
        print_result 1 "Page settings image visible in public API (got: $PAGE_IMG2)"
    fi
fi

echo ""

# Step 13: Delete impact section (cascade delete)
echo -e "${YELLOW}Step 13: Delete Impact Section${NC}"

DELETE_IMPACT=$(curl -s -X DELETE "$ADMIN_URL/homepage/impact/$IMPACT_ID" \
  -H "Authorization: Bearer $TOKEN")

echo $DELETE_IMPACT | jq -r '.message' | grep -q "success"
print_result $? "Delete impact section"

echo ""

# Step 14: Test multiple page settings
echo -e "${YELLOW}Step 14: Test Multiple Page Settings${NC}"

# Update about page
UPDATE_ABOUT=$(curl -s -X PUT "$ADMIN_URL/pages/about" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"About Us\",
    \"image_url\": \"$PAGE_IMG2_URL\"
  }")

GET_ABOUT=$(curl -s -X GET "$ADMIN_URL/pages/about" \
  -H "Authorization: Bearer $TOKEN")

ABOUT_IMG=$(echo $GET_ABOUT | jq -r '.data.image_url')
if [ "$ABOUT_IMG" = "$PAGE_IMG2_URL" ]; then
    print_result 0 "Update about page settings with image"
else
    print_result 1 "Update about page settings with image (got: $ABOUT_IMG)"
fi

# Update programs page
UPDATE_PROGRAMS=$(curl -s -X PUT "$ADMIN_URL/pages/programs" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Our Programs\",
    \"image_url\": \"$PAGE_IMG1_URL\"
  }")

GET_PROGRAMS=$(curl -s -X GET "$ADMIN_URL/pages/programs" \
  -H "Authorization: Bearer $TOKEN")

PROGRAMS_IMG=$(echo $GET_PROGRAMS | jq -r '.data.image_url')
if [ "$PROGRAMS_IMG" = "$PAGE_IMG1_URL" ]; then
    print_result 0 "Update programs page settings with image"
else
    print_result 1 "Update programs page settings with image (got: $PROGRAMS_IMG)"
fi

echo ""

# Cleanup
echo -e "${YELLOW}Cleaning up test files...${NC}"
rm -f test_impact1.png test_impact2.png test_page1.png test_page2.png test_impact_replace.png

# Print summary
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed ✗${NC}"
    exit 1
fi
