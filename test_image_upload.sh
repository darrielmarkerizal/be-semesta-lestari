#!/bin/bash

# Image Upload API Test Script
# Tests the image upload, retrieval, and deletion functionality

BASE_URL="http://localhost:3000"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

echo "=========================================="
echo "Image Upload API Tests"
echo "=========================================="
echo ""

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
echo ""

# Create a test image file
echo "Creating test image file..."
TEST_IMAGE="test_upload_image.jpg"
# Create a simple 1x1 pixel JPEG image (base64 encoded)
echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=" | base64 -d > $TEST_IMAGE

if [ -f "$TEST_IMAGE" ]; then
    echo -e "${GREEN}Test image created${NC}"
else
    echo -e "${RED}Failed to create test image${NC}"
    exit 1
fi
echo ""

# Test 1: Upload image to articles entity
echo "Test 1: Upload image to articles entity"
UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@$TEST_IMAGE")

HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
BODY=$(echo "$UPLOAD_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    SUCCESS=$(echo $BODY | grep -o '"success":true')
    if [ ! -z "$SUCCESS" ]; then
        IMAGE_URL=$(echo $BODY | grep -o '"/uploads/articles/[^"]*"' | cut -d'"' -f2)
        print_result 0 "Image uploaded to articles (URL: $IMAGE_URL)"
    else
        print_result 1 "Upload response invalid"
    fi
else
    print_result 1 "Image upload failed (HTTP $HTTP_CODE)"
fi

# Test 2: Verify uploaded image is accessible
echo ""
echo "Test 2: Verify uploaded image is accessible"
if [ ! -z "$IMAGE_URL" ]; then
    IMAGE_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$IMAGE_URL")
    if [ "$IMAGE_CHECK" -eq 200 ]; then
        print_result 0 "Uploaded image is accessible"
    else
        print_result 1 "Uploaded image not accessible (HTTP $IMAGE_CHECK)"
    fi
else
    print_result 1 "No image URL to check"
fi

# Test 3: Upload image to different entity (gallery)
echo ""
echo "Test 3: Upload image to gallery entity"
GALLERY_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/gallery" \
    -H "Authorization: Bearer $TOKEN" \
    -F "image=@$TEST_IMAGE")

HTTP_CODE=$(echo "$GALLERY_RESPONSE" | tail -n1)
BODY=$(echo "$GALLERY_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    GALLERY_URL=$(echo $BODY | grep -o '"/uploads/gallery/[^"]*"' | cut -d'"' -f2)
    print_result 0 "Image uploaded to gallery (URL: $GALLERY_URL)"
else
    print_result 1 "Gallery upload failed (HTTP $HTTP_CODE)"
fi

# Test 4: Upload without authentication (should fail)
echo ""
echo "Test 4: Upload without authentication (should fail)"
UNAUTH_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/articles" \
    -F "image=@$TEST_IMAGE")

HTTP_CODE=$(echo "$UNAUTH_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result 0 "Unauthorized upload correctly rejected"
else
    print_result 1 "Unauthorized upload not rejected (HTTP $HTTP_CODE)"
fi

# Test 5: Upload without file (should fail)
echo ""
echo "Test 5: Upload without file (should fail)"
NO_FILE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/articles" \
    -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$NO_FILE_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Upload without file correctly rejected"
else
    print_result 1 "Upload without file not rejected (HTTP $HTTP_CODE)"
fi

# Test 6: Upload multiple images
echo ""
echo "Test 6: Upload multiple images"
MULTI_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/multiple/gallery" \
    -H "Authorization: Bearer $TOKEN" \
    -F "images=@$TEST_IMAGE" \
    -F "images=@$TEST_IMAGE")

HTTP_CODE=$(echo "$MULTI_RESPONSE" | tail -n1)
BODY=$(echo "$MULTI_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    COUNT=$(echo $BODY | grep -o '"count":[0-9]*' | cut -d':' -f2)
    if [ "$COUNT" -eq 2 ]; then
        print_result 0 "Multiple images uploaded (count: $COUNT)"
    else
        print_result 1 "Multiple upload count incorrect (expected 2, got $COUNT)"
    fi
else
    print_result 1 "Multiple upload failed (HTTP $HTTP_CODE)"
fi

# Test 7: Delete uploaded image
echo ""
echo "Test 7: Delete uploaded image"
if [ ! -z "$IMAGE_URL" ]; then
    DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/api/admin/upload" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"url\":\"$IMAGE_URL\"}")
    
    HTTP_CODE=$(echo "$DELETE_RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        print_result 0 "Image deleted successfully"
        
        # Verify image is no longer accessible
        IMAGE_CHECK=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL$IMAGE_URL")
        if [ "$IMAGE_CHECK" -eq 404 ]; then
            print_result 0 "Deleted image is no longer accessible"
        else
            print_result 1 "Deleted image still accessible"
        fi
    else
        print_result 1 "Image deletion failed (HTTP $HTTP_CODE)"
    fi
else
    print_result 1 "No image URL to delete"
fi

# Test 8: Test different entity types
echo ""
echo "Test 8: Test uploads to different entity types"
ENTITIES=("programs" "partners" "awards" "merchandise")
ENTITY_SUCCESS=0

for entity in "${ENTITIES[@]}"; do
    ENTITY_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/admin/upload/$entity" \
        -H "Authorization: Bearer $TOKEN" \
        -F "image=@$TEST_IMAGE")
    
    HTTP_CODE=$(echo "$ENTITY_RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" -eq 200 ]; then
        ENTITY_SUCCESS=$((ENTITY_SUCCESS + 1))
    fi
done

if [ "$ENTITY_SUCCESS" -eq 4 ]; then
    print_result 0 "All entity types accept uploads"
else
    print_result 1 "Some entity types failed ($ENTITY_SUCCESS/4 succeeded)"
fi

# Cleanup
echo ""
echo "Cleaning up test files..."
rm -f $TEST_IMAGE
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
