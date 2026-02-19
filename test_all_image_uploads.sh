#!/bin/bash

# Comprehensive Image Upload Tests for All Entities
# Tests CRUD operations with image upload/change for all entities that support images

BASE_URL="http://localhost:3000"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test results
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

print_section() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
    echo ""
    # Add small delay between sections to avoid rate limiting
    sleep 0.5
}

# Create test image
create_test_image() {
    local filename=$1
    echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=" | base64 -d > $filename
}

print_section "Image Upload Tests for All Entities"

# Get admin token
echo "Getting admin authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}Authentication successful${NC}"

# Create test images
create_test_image "test_image1.jpg"
create_test_image "test_image2.jpg"

# ==========================================
# TEST 1: ARTICLES
# ==========================================
print_section "TEST 1: Articles with Image Upload"

# Upload image for article
echo "1.1: Upload image for article"
ARTICLE_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

ARTICLE_IMG_URL=$(echo $ARTICLE_IMG_RESPONSE | grep -o '"fullUrl":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$ARTICLE_IMG_URL" ]; then
    print_result 0 "Article image uploaded: $ARTICLE_IMG_URL"
else
    print_result 1 "Article image upload failed"
fi

# Create article with image
echo "1.2: Create article with image"
ARTICLE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Article with Image\",
        \"content\": \"Test content\",
        \"excerpt\": \"Test excerpt\",
        \"image_url\": \"$ARTICLE_IMG_URL\",
        \"category_id\": 1
    }")

ARTICLE_ID=$(echo $ARTICLE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$ARTICLE_ID" ]; then
    print_result 0 "Article created with image (ID: $ARTICLE_ID)"
else
    print_result 1 "Article creation failed"
fi

# Update article image
echo "1.3: Update article image"
NEW_ARTICLE_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_ARTICLE_IMG_URL=$(echo $NEW_ARTICLE_IMG_RESPONSE | grep -o '"fullUrl":"[^"]*"' | cut -d'"' -f4)
OLD_ARTICLE_IMG_URL="$ARTICLE_IMG_URL"

UPDATE_ARTICLE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/articles/$ARTICLE_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_ARTICLE_IMG_URL\"}")

if echo $UPDATE_ARTICLE_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Article image updated"
else
    print_result 1 "Article image update failed"
fi

# Delete old article image
echo "1.4: Delete old article image"
DELETE_ARTICLE_IMG_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$OLD_ARTICLE_IMG_URL\"}")

if echo $DELETE_ARTICLE_IMG_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Old article image deleted"
    
    # Verify image is no longer accessible
    IMG_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$OLD_ARTICLE_IMG_URL")
    if [ "$IMG_CHECK" -eq 404 ]; then
        print_result 0 "Deleted article image is no longer accessible"
    else
        print_result 1 "Deleted article image still accessible (HTTP $IMG_CHECK)"
    fi
else
    print_result 1 "Article image deletion failed"
fi

# ==========================================
# TEST 2: AWARDS
# ==========================================
print_section "TEST 2: Awards with Image Upload"

# Upload image for award
echo "2.1: Upload image for award"
AWARD_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/awards" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

AWARD_IMG_URL=$(echo $AWARD_IMG_RESPONSE | grep -o '"/uploads/awards/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$AWARD_IMG_URL" ]; then
    print_result 0 "Award image uploaded: $AWARD_IMG_URL"
else
    print_result 1 "Award image upload failed"
fi

# Create award with image
echo "2.2: Create award with image"
AWARD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/awards" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Award with Image\",
        \"short_description\": \"Test description\",
        \"image_url\": \"$AWARD_IMG_URL\",
        \"year\": 2024,
        \"issuer\": \"Test Organization\"
    }")

AWARD_ID=$(echo $AWARD_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$AWARD_ID" ]; then
    print_result 0 "Award created with image (ID: $AWARD_ID)"
else
    print_result 1 "Award creation failed"
fi

# Update award image
echo "2.3: Update award image"
NEW_AWARD_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/awards" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_AWARD_IMG_URL=$(echo $NEW_AWARD_IMG_RESPONSE | grep -o '"/uploads/awards/[^"]*"' | cut -d'"' -f2)
OLD_AWARD_IMG_URL="$AWARD_IMG_URL"

UPDATE_AWARD_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/awards/$AWARD_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_AWARD_IMG_URL\"}")

if echo $UPDATE_AWARD_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Award image updated"
else
    print_result 1 "Award image update failed"
fi

# Delete old award image
echo "2.4: Delete old award image"
DELETE_AWARD_IMG_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$OLD_AWARD_IMG_URL\"}")

if echo $DELETE_AWARD_IMG_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Old award image deleted"
else
    print_result 1 "Award image deletion failed"
fi

# ==========================================
# TEST 3: GALLERY
# ==========================================
print_section "TEST 3: Gallery with Image Upload"

# Upload image for gallery
echo "3.1: Upload image for gallery"
GALLERY_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/gallery" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

GALLERY_IMG_URL=$(echo $GALLERY_IMG_RESPONSE | grep -o '"/uploads/gallery/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$GALLERY_IMG_URL" ]; then
    print_result 0 "Gallery image uploaded: $GALLERY_IMG_URL"
else
    print_result 1 "Gallery image upload failed"
fi

# Create gallery item with image
echo "3.2: Create gallery item with image"
GALLERY_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Gallery Item\",
        \"image_url\": \"$GALLERY_IMG_URL\",
        \"category_id\": 1,
        \"gallery_date\": \"2024-01-01\"
    }")

GALLERY_ID=$(echo $GALLERY_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$GALLERY_ID" ]; then
    print_result 0 "Gallery item created with image (ID: $GALLERY_ID)"
else
    print_result 1 "Gallery item creation failed"
fi

# Update gallery image
echo "3.3: Update gallery image"
NEW_GALLERY_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/gallery" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_GALLERY_IMG_URL=$(echo $NEW_GALLERY_IMG_RESPONSE | grep -o '"/uploads/gallery/[^"]*"' | cut -d'"' -f2)
OLD_GALLERY_IMG_URL="$GALLERY_IMG_URL"

UPDATE_GALLERY_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/gallery/$GALLERY_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_GALLERY_IMG_URL\"}")

if echo $UPDATE_GALLERY_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Gallery image updated"
else
    print_result 1 "Gallery image update failed"
fi

# Delete old gallery image
echo "3.4: Delete old gallery image"
DELETE_GALLERY_IMG_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$OLD_GALLERY_IMG_URL\"}")

if echo $DELETE_GALLERY_IMG_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Old gallery image deleted"
else
    print_result 1 "Gallery image deletion failed"
fi

# ==========================================
# TEST 4: MERCHANDISE
# ==========================================
print_section "TEST 4: Merchandise with Image Upload"

# Upload image for merchandise
echo "4.1: Upload image for merchandise"
MERCH_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/merchandise" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

MERCH_IMG_URL=$(echo $MERCH_IMG_RESPONSE | grep -o '"/uploads/merchandise/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$MERCH_IMG_URL" ]; then
    print_result 0 "Merchandise image uploaded: $MERCH_IMG_URL"
else
    print_result 1 "Merchandise image upload failed"
fi

# Create merchandise with image
echo "4.2: Create merchandise with image"
MERCH_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/merchandise" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"product_name\": \"Test Product\",
        \"image_url\": \"$MERCH_IMG_URL\",
        \"price\": 100000,
        \"marketplace\": \"Tokopedia\",
        \"marketplace_link\": \"https://tokopedia.com/test\"
    }")

MERCH_ID=$(echo $MERCH_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$MERCH_ID" ]; then
    print_result 0 "Merchandise created with image (ID: $MERCH_ID)"
else
    print_result 1 "Merchandise creation failed"
fi

# Update merchandise image
echo "4.3: Update merchandise image"
NEW_MERCH_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/merchandise" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_MERCH_IMG_URL=$(echo $NEW_MERCH_IMG_RESPONSE | grep -o '"/uploads/merchandise/[^"]*"' | cut -d'"' -f2)

UPDATE_MERCH_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/merchandise/$MERCH_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_MERCH_IMG_URL\"}")

if echo $UPDATE_MERCH_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Merchandise image updated"
else
    print_result 1 "Merchandise image update failed"
fi

# ==========================================
# TEST 5: PROGRAMS
# ==========================================
print_section "TEST 5: Programs with Image Upload"

# Upload image for program
echo "5.1: Upload image for program"
PROGRAM_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/programs" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

PROGRAM_IMG_URL=$(echo $PROGRAM_IMG_RESPONSE | grep -o '"/uploads/programs/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$PROGRAM_IMG_URL" ]; then
    print_result 0 "Program image uploaded: $PROGRAM_IMG_URL"
else
    print_result 1 "Program image upload failed"
fi

# Create program with image
echo "5.2: Create program with image"
PROGRAM_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/programs" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Test Program\",
        \"description\": \"Test description\",
        \"image_url\": \"$PROGRAM_IMG_URL\"
    }")

PROGRAM_ID=$(echo $PROGRAM_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$PROGRAM_ID" ]; then
    print_result 0 "Program created with image (ID: $PROGRAM_ID)"
else
    print_result 1 "Program creation failed"
fi

# Update program image
echo "5.3: Update program image"
NEW_PROGRAM_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/programs" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_PROGRAM_IMG_URL=$(echo $NEW_PROGRAM_IMG_RESPONSE | grep -o '"/uploads/programs/[^"]*"' | cut -d'"' -f2)

UPDATE_PROGRAM_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/programs/$PROGRAM_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_PROGRAM_IMG_URL\"}")

if echo $UPDATE_PROGRAM_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Program image updated"
else
    print_result 1 "Program image update failed"
fi

# ==========================================
# TEST 6: PARTNERS (logo_url)
# ==========================================
print_section "TEST 6: Partners with Logo Upload"

# Upload logo for partner
echo "6.1: Upload logo for partner"
PARTNER_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/partners" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

PARTNER_IMG_URL=$(echo $PARTNER_IMG_RESPONSE | grep -o '"/uploads/partners/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$PARTNER_IMG_URL" ]; then
    print_result 0 "Partner logo uploaded: $PARTNER_IMG_URL"
else
    print_result 1 "Partner logo upload failed"
fi

# Create partner with logo
echo "6.2: Create partner with logo"
PARTNER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/partners" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Test Partner\",
        \"description\": \"Test description\",
        \"logo_url\": \"$PARTNER_IMG_URL\",
        \"website\": \"https://example.com\"
    }")

PARTNER_ID=$(echo $PARTNER_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$PARTNER_ID" ]; then
    print_result 0 "Partner created with logo (ID: $PARTNER_ID)"
else
    print_result 1 "Partner creation failed"
fi

# Update partner logo
echo "6.3: Update partner logo"
NEW_PARTNER_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/partners" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_PARTNER_IMG_URL=$(echo $NEW_PARTNER_IMG_RESPONSE | grep -o '"/uploads/partners/[^"]*"' | cut -d'"' -f2)

UPDATE_PARTNER_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/partners/$PARTNER_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"logo_url\": \"$NEW_PARTNER_IMG_URL\"}")

if echo $UPDATE_PARTNER_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Partner logo updated"
else
    print_result 1 "Partner logo update failed"
fi

# ==========================================
# TEST 7: PAGE SETTINGS
# ==========================================
print_section "TEST 7: Page Settings with Image Upload"

# Upload image for page
echo "7.1: Upload image for page"
PAGE_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/pages" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

PAGE_IMG_URL=$(echo $PAGE_IMG_RESPONSE | grep -o '"/uploads/pages/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$PAGE_IMG_URL" ]; then
    print_result 0 "Page image uploaded: $PAGE_IMG_URL"
else
    print_result 1 "Page image upload failed"
fi

# Update page settings with image
echo "7.2: Update page settings with image"
UPDATE_PAGE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$PAGE_IMG_URL\"}")

if echo $UPDATE_PAGE_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Page settings image updated"
else
    print_result 1 "Page settings image update failed"
fi

# ==========================================
# TEST 8: HERO SECTION
# ==========================================
print_section "TEST 8: Hero Section with Image Upload"

# Upload image for hero
echo "8.1: Upload image for hero section"
HERO_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/hero" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

HERO_IMG_URL=$(echo $HERO_IMG_RESPONSE | grep -o '"/uploads/hero/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$HERO_IMG_URL" ]; then
    print_result 0 "Hero image uploaded: $HERO_IMG_URL"
else
    print_result 1 "Hero image upload failed"
fi

# Update hero section with image
echo "8.2: Update hero section with image"
UPDATE_HERO_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/hero" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$HERO_IMG_URL\"}")

if echo $UPDATE_HERO_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Hero section image updated"
else
    print_result 1 "Hero section image update failed"
fi

# ==========================================
# TEST 9: DONATION CTA
# ==========================================
print_section "TEST 9: Donation CTA with Image Upload"

# Upload image for donation CTA
echo "9.1: Upload image for donation CTA"
DONATION_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/donation" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

DONATION_IMG_URL=$(echo $DONATION_IMG_RESPONSE | grep -o '"/uploads/donation/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$DONATION_IMG_URL" ]; then
    print_result 0 "Donation CTA image uploaded: $DONATION_IMG_URL"
else
    print_result 1 "Donation CTA image upload failed"
fi

# Update donation CTA with image
echo "9.2: Update donation CTA with image"
# Get donation CTA ID first
DONATION_CTA_DATA=$(curl -s -X GET "$BASE_URL/api/admin/homepage/donation-cta" \
    -H "Authorization: Bearer $TOKEN")
DONATION_CTA_ID=$(echo $DONATION_CTA_DATA | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$DONATION_CTA_ID" ]; then
    UPDATE_DONATION_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/homepage/donation-cta/$DONATION_CTA_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"image_url\": \"$DONATION_IMG_URL\"}")
    
    if echo $UPDATE_DONATION_RESPONSE | grep -q '"success":true'; then
        print_result 0 "Donation CTA image updated"
    else
        print_result 1 "Donation CTA image update failed"
    fi
else
    print_result 1 "Could not get Donation CTA ID"
fi

# ==========================================
# TEST 10: LEADERSHIP
# ==========================================
print_section "TEST 10: Leadership with Image Upload"

# Upload image for leadership
echo "10.1: Upload image for leadership"
LEADERSHIP_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/leadership" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

LEADERSHIP_IMG_URL=$(echo $LEADERSHIP_IMG_RESPONSE | grep -o '"/uploads/leadership/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$LEADERSHIP_IMG_URL" ]; then
    print_result 0 "Leadership image uploaded: $LEADERSHIP_IMG_URL"
else
    print_result 1 "Leadership image upload failed"
fi

# Create leadership with image
echo "10.2: Create leadership member with image"
LEADERSHIP_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/about/leadership" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Test Leader\",
        \"position\": \"Test Position\",
        \"bio\": \"Test bio\",
        \"image_url\": \"$LEADERSHIP_IMG_URL\"
    }")

LEADERSHIP_ID=$(echo $LEADERSHIP_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$LEADERSHIP_ID" ]; then
    print_result 0 "Leadership member created with image (ID: $LEADERSHIP_ID)"
else
    print_result 1 "Leadership member creation failed"
fi

# Update leadership image
echo "10.3: Update leadership image"
NEW_LEADERSHIP_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/leadership" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_LEADERSHIP_IMG_URL=$(echo $NEW_LEADERSHIP_IMG_RESPONSE | grep -o '"/uploads/leadership/[^"]*"' | cut -d'"' -f2)

UPDATE_LEADERSHIP_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/leadership/$LEADERSHIP_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_LEADERSHIP_IMG_URL\"}")

if echo $UPDATE_LEADERSHIP_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Leadership image updated"
else
    print_result 1 "Leadership image update failed"
fi

# ==========================================
# TEST 11: HISTORY
# ==========================================
print_section "TEST 11: History with Image Upload"

# Upload image for history
echo "11.1: Upload image for history"
HISTORY_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/history" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

HISTORY_IMG_URL=$(echo $HISTORY_IMG_RESPONSE | grep -o '"/uploads/history/[^"]*"' | cut -d'"' -f2)

if [ ! -z "$HISTORY_IMG_URL" ]; then
    print_result 0 "History image uploaded: $HISTORY_IMG_URL"
else
    print_result 1 "History image upload failed"
fi

# Create history with image
echo "11.2: Create history item with image"
HISTORY_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/about/history" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"year\": 2024,
        \"title\": \"Test History\",
        \"content\": \"Test content\",
        \"image_url\": \"$HISTORY_IMG_URL\"
    }")

HISTORY_ID=$(echo $HISTORY_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ ! -z "$HISTORY_ID" ]; then
    print_result 0 "History item created with image (ID: $HISTORY_ID)"
else
    print_result 1 "History item creation failed"
fi

# Update history image
echo "11.3: Update history image"
NEW_HISTORY_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/history" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image2.jpg")

NEW_HISTORY_IMG_URL=$(echo $NEW_HISTORY_IMG_RESPONSE | grep -o '"/uploads/history/[^"]*"' | cut -d'"' -f2)

UPDATE_HISTORY_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/about/history/$HISTORY_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"image_url\": \"$NEW_HISTORY_IMG_URL\"}")

if echo $UPDATE_HISTORY_RESPONSE | grep -q '"success":true'; then
    print_result 0 "History image updated"
else
    print_result 1 "History image update failed"
fi

# ==========================================
# TEST 12: DELETE IMAGE OPERATIONS
# ==========================================
print_section "TEST 12: Delete Image Operations"

# Test delete without authentication (should fail)
echo "12.1: Delete image without authentication (should fail)"
UNAUTH_DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$NEW_ARTICLE_IMG_URL\"}")

HTTP_CODE=$(echo "$UNAUTH_DELETE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result 0 "Unauthorized delete correctly rejected"
else
    print_result 1 "Unauthorized delete not rejected (HTTP $HTTP_CODE)"
fi

# Test delete without URL (should fail)
echo "12.2: Delete image without URL (should fail)"
NO_URL_DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{}")

HTTP_CODE=$(echo "$NO_URL_DELETE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Delete without URL correctly rejected"
else
    print_result 1 "Delete without URL not rejected (HTTP $HTTP_CODE)"
fi

# Test delete non-existent image (should fail gracefully)
echo "12.3: Delete non-existent image"
NONEXIST_DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"/uploads/articles/nonexistent-image.jpg\"}")

HTTP_CODE=$(echo "$NONEXIST_DELETE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Non-existent image delete handled correctly"
else
    print_result 1 "Non-existent image delete not handled correctly (HTTP $HTTP_CODE)"
fi

# Test delete with invalid URL format
echo "12.4: Delete with invalid URL format"
INVALID_DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"invalid-url\"}")

HTTP_CODE=$(echo "$INVALID_DELETE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ] || [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Invalid URL format handled correctly"
else
    print_result 1 "Invalid URL format not handled correctly (HTTP $HTTP_CODE)"
fi

# Test successful delete and verify file is gone
echo "12.5: Delete valid image and verify removal"
TEST_DELETE_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_image1.jpg")

TEST_DELETE_IMG_URL=$(echo $TEST_DELETE_IMG_RESPONSE | grep -o '"url":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$TEST_DELETE_IMG_URL" ]; then
    # Verify image exists
    IMG_EXISTS=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$TEST_DELETE_IMG_URL")
    
    if [ "$IMG_EXISTS" -eq 200 ]; then
        # Delete the image
        DELETE_SUCCESS_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"url\": \"$TEST_DELETE_IMG_URL\"}")
        
        if echo $DELETE_SUCCESS_RESPONSE | grep -q '"success":true'; then
            print_result 0 "Image deleted successfully"
            
            # Verify image is gone
            IMG_GONE=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$TEST_DELETE_IMG_URL")
            
            if [ "$IMG_GONE" -eq 404 ]; then
                print_result 0 "Deleted image file is no longer accessible"
            else
                print_result 1 "Deleted image file still accessible (HTTP $IMG_GONE)"
            fi
        else
            print_result 1 "Image deletion failed"
        fi
    else
        print_result 1 "Test image not accessible before delete"
    fi
else
    print_result 1 "Could not upload test image for deletion"
fi

# Test delete already deleted image (should fail)
echo "12.6: Delete already deleted image"
DOUBLE_DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$TEST_DELETE_IMG_URL\"}")

HTTP_CODE=$(echo "$DOUBLE_DELETE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Double delete correctly rejected"
else
    print_result 1 "Double delete not handled correctly (HTTP $HTTP_CODE)"
fi

# Cleanup
echo ""
echo "Cleaning up test files..."
rm -f test_image1.jpg test_image2.jpg
echo "Test images removed"

# Summary
print_section "Test Summary"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
