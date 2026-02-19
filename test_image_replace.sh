#!/bin/bash

# Image Replace Test Script
# Tests the replace image functionality

BASE_URL="http://localhost:3000"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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

# Create test image
create_test_image() {
    local filename=$1
    echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=" | base64 -d > $filename
}

echo "=========================================="
echo "Image Replace Functionality Tests"
echo "=========================================="
echo ""

# Get admin token
echo "Getting admin authentication token..."
sleep 1
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}Authentication successful${NC}"
echo ""

# Create test images
create_test_image "old_image.jpg"
create_test_image "new_image.jpg"

# Test 1: Upload initial image
echo "Test 1: Upload initial image"
sleep 0.5
OLD_IMG_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@old_image.jpg")

OLD_IMG_URL=$(echo $OLD_IMG_RESPONSE | grep -o '"url":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$OLD_IMG_URL" ]; then
    print_result 0 "Initial image uploaded: $OLD_IMG_URL"
else
    print_result 1 "Initial image upload failed"
    exit 1
fi

# Test 2: Verify old image is accessible
echo ""
echo "Test 2: Verify old image is accessible"
sleep 0.5
OLD_IMG_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$OLD_IMG_URL")

if [ "$OLD_IMG_CHECK" -eq 200 ]; then
    print_result 0 "Old image is accessible (HTTP $OLD_IMG_CHECK)"
else
    print_result 1 "Old image not accessible (HTTP $OLD_IMG_CHECK)"
fi

# Test 3: Replace image
echo ""
echo "Test 3: Replace old image with new image"
sleep 0.5
REPLACE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/replace/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@new_image.jpg" \
    -F "oldImageUrl=$OLD_IMG_URL")

NEW_IMG_URL=$(echo $REPLACE_RESPONSE | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
OLD_DELETED=$(echo $REPLACE_RESPONSE | grep -o '"oldImageDeleted":[^,}]*' | cut -d':' -f2)

if [ ! -z "$NEW_IMG_URL" ]; then
    print_result 0 "New image uploaded: $NEW_IMG_URL"
else
    print_result 1 "Image replacement failed"
    echo "Response: $REPLACE_RESPONSE"
fi

# Test 4: Verify old image was deleted
echo ""
echo "Test 4: Verify old image was deleted"
sleep 0.5

if echo "$OLD_DELETED" | grep -q "true"; then
    print_result 0 "Old image deletion flag is true"
    
    # Verify file is actually gone
    OLD_IMG_GONE=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$OLD_IMG_URL")
    
    if [ "$OLD_IMG_GONE" -eq 404 ]; then
        print_result 0 "Old image file is no longer accessible (HTTP $OLD_IMG_GONE)"
    else
        print_result 1 "Old image file still accessible (HTTP $OLD_IMG_GONE)"
    fi
else
    print_result 1 "Old image deletion flag is false"
fi

# Test 5: Verify new image is accessible
echo ""
echo "Test 5: Verify new image is accessible"
sleep 0.5
NEW_IMG_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$NEW_IMG_URL")

if [ "$NEW_IMG_CHECK" -eq 200 ]; then
    print_result 0 "New image is accessible (HTTP $NEW_IMG_CHECK)"
else
    print_result 1 "New image not accessible (HTTP $NEW_IMG_CHECK)"
fi

# Test 6: Replace without old image URL (should fail)
echo ""
echo "Test 6: Replace without old image URL (should fail)"
sleep 0.5
NO_OLD_URL_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/replace/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@new_image.jpg")

HTTP_CODE=$(echo "$NO_OLD_URL_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Replace without old URL correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Replace without old URL not rejected (HTTP $HTTP_CODE)"
fi

# Test 7: Replace without new image (should fail)
echo ""
echo "Test 7: Replace without new image (should fail)"
sleep 0.5
NO_NEW_IMG_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/replace/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "oldImageUrl=$NEW_IMG_URL")

HTTP_CODE=$(echo "$NO_NEW_IMG_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Replace without new image correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Replace without new image not rejected (HTTP $HTTP_CODE)"
fi

# Test 8: Replace with non-existent old image (should still upload new)
echo ""
echo "Test 8: Replace with non-existent old image"
sleep 0.5
NONEXIST_REPLACE=$(curl -s -X POST "$BASE_URL/api/admin/upload/replace/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@new_image.jpg" \
    -F "oldImageUrl=/uploads/articles/nonexistent-123.jpg")

NONEXIST_NEW_URL=$(echo $NONEXIST_REPLACE | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
NONEXIST_DELETED=$(echo $NONEXIST_REPLACE | grep -o '"oldImageDeleted":[^,}]*' | cut -d':' -f2)

if [ ! -z "$NONEXIST_NEW_URL" ]; then
    print_result 0 "New image uploaded even with non-existent old image"
    
    if echo "$NONEXIST_DELETED" | grep -q "false"; then
        print_result 0 "Old image deletion flag correctly false for non-existent file"
    else
        print_result 1 "Old image deletion flag should be false"
    fi
else
    print_result 1 "Replace with non-existent old image failed"
fi

# Test 9: Replace without authentication (should fail)
echo ""
echo "Test 9: Replace without authentication (should fail)"
sleep 0.5
UNAUTH_REPLACE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/replace/articles" \
    -F "image=@new_image.jpg" \
    -F "oldImageUrl=$NEW_IMG_URL")

HTTP_CODE=$(echo "$UNAUTH_REPLACE" | tail -n1)

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result 0 "Unauthorized replace correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Unauthorized replace not rejected (HTTP $HTTP_CODE)"
fi

# Cleanup
echo ""
echo "Cleaning up test files..."
rm -f old_image.jpg new_image.jpg
echo "Test images removed"

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
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
