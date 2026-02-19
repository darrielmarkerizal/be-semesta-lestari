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
echo -e "${YELLOW}Testing Home Page Image Features${NC}"
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

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Successfully logged in${NC}"
echo ""

# Step 2: Upload test images
echo -e "${YELLOW}Step 2: Upload Test Images${NC}"

# Create a simple test image (1x1 pixel PNG)
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_vision.png
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_donation.png
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_impact.png

# Upload vision image
VISION_UPLOAD=$(curl -s -X POST "$ADMIN_URL/upload/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_vision.png")

VISION_IMAGE_URL=$(echo $VISION_UPLOAD | jq -r '.data.url')
print_result $? "Upload vision image"

# Upload donation CTA image
DONATION_UPLOAD=$(curl -s -X POST "$ADMIN_URL/upload/donation_cta" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_donation.png")

DONATION_IMAGE_URL=$(echo $DONATION_UPLOAD | jq -r '.data.url')
print_result $? "Upload donation CTA image"

# Upload impact section image
IMPACT_UPLOAD=$(curl -s -X POST "$ADMIN_URL/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_impact.png")

IMPACT_IMAGE_URL=$(echo $IMPACT_UPLOAD | jq -r '.data.url')
print_result $? "Upload impact section image"

echo ""

# Step 3: Update Vision with image
echo -e "${YELLOW}Step 3: Update Vision Section with Image${NC}"

VISION_UPDATE=$(curl -s -X PUT "$ADMIN_URL/homepage/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Our Vision with Image\",
    \"description\": \"This is our vision with an image\",
    \"image_url\": \"$VISION_IMAGE_URL\",
    \"is_active\": true
  }")

echo $VISION_UPDATE | grep -q '"success":true'
print_result $? "Update vision section with image_url"

echo ""

# Step 4: Update Donation CTA with image
echo -e "${YELLOW}Step 4: Update Donation CTA Section with Image${NC}"

# First get the donation CTA ID
DONATION_CTA_ID=$(curl -s -X GET "$ADMIN_URL/homepage/donation-cta" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.data.id')

DONATION_UPDATE=$(curl -s -X PUT "$ADMIN_URL/homepage/donation-cta/$DONATION_CTA_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Support Our Cause\",
    \"description\": \"Your donation makes a difference\",
    \"button_text\": \"Donate Now\",
    \"button_url\": \"/donate\",
    \"image_url\": \"$DONATION_IMAGE_URL\",
    \"is_active\": true
  }")

echo $DONATION_UPDATE | grep -q '"success":true'
print_result $? "Update donation CTA with image_url"

echo ""

# Step 5: Create Impact Section with image
echo -e "${YELLOW}Step 5: Create Impact Section with Image${NC}"

IMPACT_CREATE=$(curl -s -X POST "$ADMIN_URL/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Trees Planted\",
    \"description\": \"We have planted thousands of trees\",
    \"stats_number\": \"10,000+\",
    \"image_url\": \"$IMPACT_IMAGE_URL\",
    \"order_position\": 1,
    \"is_active\": true
  }")

echo $IMPACT_CREATE | grep -q '"success":true'
print_result $? "Create impact section with image_url"

IMPACT_ID=$(echo $IMPACT_CREATE | jq -r '.data.id')

echo ""

# Step 6: Verify images in /api/home response
echo -e "${YELLOW}Step 6: Verify Images in Public Home API${NC}"

HOME_RESPONSE=$(curl -s -X GET "$BASE_URL/home")

# Check vision image
echo $HOME_RESPONSE | grep -q "\"vision\".*\"image_url\":\"$VISION_IMAGE_URL\""
print_result $? "Vision image_url present in /api/home"

# Check donation CTA image
echo $HOME_RESPONSE | grep -q "\"donationCta\".*\"image_url\":\"$DONATION_IMAGE_URL\""
print_result $? "Donation CTA image_url present in /api/home"

# Check impact section image
echo $HOME_RESPONSE | grep -q "\"impact\".*\"image_url\":\"$IMPACT_IMAGE_URL\""
print_result $? "Impact section image_url present in /api/home"

echo ""

# Step 7: Update Impact Section image
echo -e "${YELLOW}Step 7: Update Impact Section Image${NC}"

# Upload new image
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_impact_new.png

NEW_IMPACT_UPLOAD=$(curl -s -X POST "$ADMIN_URL/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_impact_new.png")

NEW_IMPACT_IMAGE_URL=$(echo $NEW_IMPACT_UPLOAD | jq -r '.data.url')

IMPACT_UPDATE=$(curl -s -X PUT "$ADMIN_URL/homepage/impact/$IMPACT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Trees Planted Updated\",
    \"description\": \"Updated description\",
    \"stats_number\": \"15,000+\",
    \"image_url\": \"$NEW_IMPACT_IMAGE_URL\",
    \"is_active\": true
  }")

echo $IMPACT_UPDATE | grep -q '"success":true'
print_result $? "Update impact section with new image"

echo ""

# Step 8: Test Replace Image Feature
echo -e "${YELLOW}Step 8: Test Replace Image Feature${NC}"

# Create another test image
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test_vision_replace.png

REPLACE_RESPONSE=$(curl -s -X POST "$ADMIN_URL/upload/replace/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test_vision_replace.png" \
  -F "oldImageUrl=$VISION_IMAGE_URL")

echo $REPLACE_RESPONSE | grep -q '"success":true'
print_result $? "Replace vision image"

REPLACED_IMAGE_URL=$(echo $REPLACE_RESPONSE | jq -r '.data.url')

# Update vision with replaced image
VISION_UPDATE_REPLACED=$(curl -s -X PUT "$ADMIN_URL/homepage/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Our Vision with Replaced Image\",
    \"description\": \"This is our vision with a replaced image\",
    \"image_url\": \"$REPLACED_IMAGE_URL\",
    \"is_active\": true
  }")

echo $VISION_UPDATE_REPLACED | grep -q '"success":true'
print_result $? "Update vision with replaced image"

echo ""

# Step 9: Verify all sections have images
echo -e "${YELLOW}Step 9: Final Verification${NC}"

FINAL_HOME=$(curl -s -X GET "$BASE_URL/home")

# Verify vision has image
echo $FINAL_HOME | grep -q "\"vision\".*\"image_url\""
print_result $? "Vision section has image_url field"

# Verify donation CTA has image
echo $FINAL_HOME | grep -q "\"donationCta\".*\"image_url\""
print_result $? "Donation CTA section has image_url field"

# Verify impact sections have images
echo $FINAL_HOME | grep -q "\"impact\".*\"image_url\""
print_result $? "Impact sections have image_url field"

echo ""

# Step 10: Test admin GET endpoints
echo -e "${YELLOW}Step 10: Test Admin GET Endpoints${NC}"

# Get vision
ADMIN_VISION=$(curl -s -X GET "$ADMIN_URL/homepage/vision" \
  -H "Authorization: Bearer $TOKEN")

echo $ADMIN_VISION | grep -q '"image_url"'
print_result $? "Admin GET vision includes image_url"

# Get donation CTA
ADMIN_DONATION=$(curl -s -X GET "$ADMIN_URL/homepage/donation-cta" \
  -H "Authorization: Bearer $TOKEN")

echo $ADMIN_DONATION | grep -q '"image_url"'
print_result $? "Admin GET donation CTA includes image_url"

# Get impact sections
ADMIN_IMPACT=$(curl -s -X GET "$ADMIN_URL/homepage/impact" \
  -H "Authorization: Bearer $TOKEN")

echo $ADMIN_IMPACT | grep -q '"image_url"'
print_result $? "Admin GET impact sections includes image_url"

echo ""

# Cleanup
echo -e "${YELLOW}Cleaning up test files...${NC}"
rm -f test_vision.png test_donation.png test_impact.png test_impact_new.png test_vision_replace.png

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
