#!/bin/bash

# Image Delete Operations Test Script
# Focused tests for image deletion functionality

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

# Create test image
create_test_image() {
    local filename=$1
    echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=" | base64 -d > $filename
}

echo "=========================================="
echo "Image Delete Operations Tests"
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
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

echo -e "${GREEN}Authentication successful${NC}"
echo ""

# Create test image
create_test_image "test_delete.jpg"

# Test 1: Upload an image
echo "Test 1: Upload image for deletion test"
sleep 0.5
UPLOAD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@test_delete.jpg")

IMAGE_URL=$(echo $UPLOAD_RESPONSE | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
FULL_IMAGE_URL=$(echo $UPLOAD_RESPONSE | grep -o '"fullUrl":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$IMAGE_URL" ]; then
    print_result 0 "Image uploaded: $IMAGE_URL"
else
    print_result 1 "Image upload failed"
    echo "Response: $UPLOAD_RESPONSE"
    exit 1
fi

# Test 2: Verify image is accessible
echo ""
echo "Test 2: Verify uploaded image is accessible"
sleep 0.5
IMG_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$IMAGE_URL")

if [ "$IMG_CHECK" -eq 200 ]; then
    print_result 0 "Image is accessible (HTTP $IMG_CHECK)"
else
    print_result 1 "Image not accessible (HTTP $IMG_CHECK)"
fi

# Test 3: Delete without authentication (should fail)
echo ""
echo "Test 3: Delete without authentication (should fail)"
sleep 0.5
UNAUTH_DELETE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$IMAGE_URL\"}")

HTTP_CODE=$(echo "$UNAUTH_DELETE" | tail -n1)

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result 0 "Unauthorized delete correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Unauthorized delete not rejected (HTTP $HTTP_CODE)"
fi

# Test 4: Delete without URL (should fail)
echo ""
echo "Test 4: Delete without URL (should fail)"
sleep 0.5
NO_URL_DELETE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{}")

HTTP_CODE=$(echo "$NO_URL_DELETE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Delete without URL correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Delete without URL not rejected (HTTP $HTTP_CODE)"
fi

# Test 5: Delete with invalid URL
echo ""
echo "Test 5: Delete with invalid URL format"
sleep 0.5
INVALID_DELETE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"invalid-url\"}")

HTTP_CODE=$(echo "$INVALID_DELETE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ] || [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Invalid URL correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Invalid URL not rejected (HTTP $HTTP_CODE)"
fi

# Test 6: Delete non-existent image
echo ""
echo "Test 6: Delete non-existent image"
sleep 0.5
NONEXIST_DELETE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"/uploads/articles/nonexistent-12345.jpg\"}")

HTTP_CODE=$(echo "$NONEXIST_DELETE" | tail -n1)

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Non-existent image correctly handled (HTTP $HTTP_CODE)"
else
    print_result 1 "Non-existent image not handled correctly (HTTP $HTTP_CODE)"
fi

# Test 7: Successfully delete the uploaded image
echo ""
echo "Test 7: Delete uploaded image"
sleep 0.5
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$IMAGE_URL\"}")

if echo $DELETE_RESPONSE | grep -q '"success":true'; then
    print_result 0 "Image deleted successfully"
else
    print_result 1 "Image deletion failed"
    echo "Response: $DELETE_RESPONSE"
fi

# Test 8: Verify image is no longer accessible
echo ""
echo "Test 8: Verify deleted image is no longer accessible"
sleep 0.5
IMG_GONE=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$IMAGE_URL")

if [ "$IMG_GONE" -eq 404 ]; then
    print_result 0 "Deleted image is no longer accessible (HTTP $IMG_GONE)"
else
    print_result 1 "Deleted image still accessible (HTTP $IMG_GONE)"
fi

# Test 9: Try to delete already deleted image (should fail)
echo ""
echo "Test 9: Delete already deleted image (should fail)"
sleep 0.5
DOUBLE_DELETE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$IMAGE_URL\"}")

HTTP_CODE=$(echo "$DOUBLE_DELETE" | tail -n1)

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result 0 "Double delete correctly rejected (HTTP $HTTP_CODE)"
else
    print_result 1 "Double delete not handled correctly (HTTP $HTTP_CODE)"
fi

# Test 10: Upload and delete multiple images
echo ""
echo "Test 10: Upload and delete multiple images"
sleep 0.5

# Upload 3 images
URLS=()
for i in {1..3}; do
    UPLOAD=$(curl -s -X POST "$BASE_URL/api/admin/upload/gallery" \
        -H "Authorization: Bearer $TOKEN" \
        -F "image=@test_delete.jpg")
    
    URL=$(echo $UPLOAD | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    if [ ! -z "$URL" ]; then
        URLS+=("$URL")
    fi
    sleep 0.3
done

if [ ${#URLS[@]} -eq 3 ]; then
    print_result 0 "Multiple images uploaded (${#URLS[@]} images)"
    
    # Delete all images
    DELETED=0
    for url in "${URLS[@]}"; do
        DELETE=$(curl -s -X DELETE "$BASE_URL/api/admin/upload" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"url\": \"$url\"}")
        
        if echo $DELETE | grep -q '"success":true'; then
            DELETED=$((DELETED + 1))
        fi
        sleep 0.3
    done
    
    if [ $DELETED -eq 3 ]; then
        print_result 0 "All multiple images deleted ($DELETED images)"
    else
        print_result 1 "Not all images deleted ($DELETED/3)"
    fi
else
    print_result 1 "Failed to upload multiple images (${#URLS[@]}/3)"
fi

# Cleanup
echo ""
echo "Cleaning up test files..."
rm -f test_delete.jpg
echo "Test image removed"

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
