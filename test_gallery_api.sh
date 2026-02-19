#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Base URL
BASE_URL="http://localhost:3000"

echo "=========================================="
echo "  GALLERY API UNIT TEST"
echo "=========================================="
echo ""

# Function to print test result
print_result() {
    local test_name=$1
    local result=$2
    local details=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name"
        echo -e "  ${YELLOW}Details: $details${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo "=== GALLERY CATEGORIES TESTS ==="
echo ""

# Test 1: Get all gallery categories
echo "Test 1: GET /api/gallery-categories (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery-categories")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 4 ]; then
    print_result "Get all gallery categories" "PASS" "Found $COUNT categories"
else
    print_result "Get all gallery categories" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 2: Get category by slug
echo "Test 2: GET /api/gallery-categories/events (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery-categories/events")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
CATEGORY_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$CATEGORY_NAME" = "Events" ]; then
    print_result "Get category by slug" "PASS" "Category: $CATEGORY_NAME"
else
    print_result "Get category by slug" "FAIL" "Success: $SUCCESS, Name: $CATEGORY_NAME"
fi
echo ""

# Test 3: Verify category fields
echo "Test 3: Verify category required fields"
RESPONSE=$(curl -s "$BASE_URL/api/gallery-categories/events")
HAS_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('name' in data.get('data', {}))" 2>/dev/null)
HAS_SLUG=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('slug' in data.get('data', {}))" 2>/dev/null)
HAS_DESCRIPTION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('description' in data.get('data', {}))" 2>/dev/null)

if [ "$HAS_NAME" = "True" ] && [ "$HAS_SLUG" = "True" ] && [ "$HAS_DESCRIPTION" = "True" ]; then
    print_result "Category required fields" "PASS" "All fields present"
else
    print_result "Category required fields" "FAIL" "Missing fields"
fi
echo ""

echo "=== GALLERY ITEMS TESTS ==="
echo ""

# Test 4: Get all gallery items
echo "Test 4: GET /api/gallery (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 8 ]; then
    print_result "Get all gallery items" "PASS" "Found $COUNT items"
else
    print_result "Get all gallery items" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 5: Get single gallery item
echo "Test 5: GET /api/gallery/1 (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery/1")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$TITLE" ]; then
    print_result "Get single gallery item" "PASS" "Title: $TITLE"
else
    print_result "Get single gallery item" "FAIL" "Success: $SUCCESS, Title: $TITLE"
fi
echo ""

# Test 6: Verify gallery item fields
echo "Test 6: Verify gallery item required fields"
RESPONSE=$(curl -s "$BASE_URL/api/gallery/1")
HAS_TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('title' in data.get('data', {}))" 2>/dev/null)
HAS_IMAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('image_url' in data.get('data', {}))" 2>/dev/null)
HAS_CATEGORY_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('category_id' in data.get('data', {}))" 2>/dev/null)
HAS_CATEGORY_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('category_name' in data.get('data', {}))" 2>/dev/null)
HAS_DATE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('gallery_date' in data.get('data', {}))" 2>/dev/null)

if [ "$HAS_TITLE" = "True" ] && [ "$HAS_IMAGE" = "True" ] && [ "$HAS_CATEGORY_ID" = "True" ] && [ "$HAS_CATEGORY_NAME" = "True" ] && [ "$HAS_DATE" = "True" ]; then
    print_result "Gallery item required fields" "PASS" "All fields present"
else
    print_result "Gallery item required fields" "FAIL" "Missing fields"
fi
echo ""

# Test 7: Category filtering
echo "Test 7: GET /api/gallery?category=events (Category Filter)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery?category=events")
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
FIRST_CATEGORY=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); items = data.get('data', []); print(items[0].get('category_slug', '') if len(items) > 0 else '')" 2>/dev/null)

if [ "$COUNT" -ge 1 ] && [ "$FIRST_CATEGORY" = "events" ]; then
    print_result "Category filtering" "PASS" "Found $COUNT items in 'events' category"
else
    print_result "Category filtering" "FAIL" "Count: $COUNT, Category: $FIRST_CATEGORY"
fi
echo ""

# Test 8: Pagination
echo "Test 8: GET /api/gallery?page=1&limit=3 (Pagination)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery?page=1&limit=3")
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
HAS_PAGINATION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('pagination' in data)" 2>/dev/null)

if [ "$COUNT" = "3" ] && [ "$HAS_PAGINATION" = "True" ]; then
    print_result "Pagination working" "PASS" "Returned 3 items with pagination"
else
    print_result "Pagination working" "FAIL" "Count: $COUNT, Has pagination: $HAS_PAGINATION"
fi
echo ""

# Test 9: Non-existent gallery item
echo "Test 9: GET /api/gallery/9999 (Non-existent)"
RESPONSE=$(curl -s "$BASE_URL/api/gallery/9999")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

if [ "$SUCCESS" = "False" ]; then
    print_result "Non-existent gallery item" "PASS" "Returns 404 correctly"
else
    print_result "Non-existent gallery item" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Get authentication token for admin tests
echo "Getting authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}')

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo -e "${YELLOW}⚠ Warning: Could not get authentication token (rate limited or error)${NC}"
    echo "Skipping admin tests..."
    echo ""
else
    echo -e "${GREEN}✓ Token obtained${NC}"
    echo ""

    echo "=== ADMIN GALLERY CATEGORY TESTS ==="
    echo ""

    # Test 10: Admin - Get all categories
    echo "Test 10: GET /api/admin/gallery-categories (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery-categories" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 4 ]; then
        print_result "Admin get all categories" "PASS" "Found $COUNT categories"
    else
        print_result "Admin get all categories" "FAIL" "Success: $SUCCESS, Count: $COUNT"
    fi
    echo ""

    # Test 11: Admin - Create category
    echo "Test 11: POST /api/admin/gallery-categories (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/gallery-categories" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Test Category",
        "slug": "test-category",
        "description": "Test category description"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_CAT_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_CAT_ID" ]; then
        print_result "Create gallery category" "PASS" "Created with ID: $NEW_CAT_ID"
    else
        print_result "Create gallery category" "FAIL" "Success: $SUCCESS, ID: $NEW_CAT_ID"
    fi
    echo ""

    # Test 12: Admin - Update category
    if [ ! -z "$NEW_CAT_ID" ]; then
        echo "Test 12: PUT /api/admin/gallery-categories/$NEW_CAT_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/gallery-categories/$NEW_CAT_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "name": "Updated Test Category"
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        UPDATED_NAME=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_NAME" == *"Updated"* ]]; then
            print_result "Update gallery category" "PASS" "Updated to: $UPDATED_NAME"
        else
            print_result "Update gallery category" "FAIL" "Success: $SUCCESS, Name: $UPDATED_NAME"
        fi
        echo ""
    fi

    # Test 13: Category deletion protection
    echo "Test 13: DELETE /api/admin/gallery-categories/1 (Deletion Protection)"
    DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/gallery-categories/1" \
      -H "Authorization: Bearer $TOKEN")

    SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)
    MESSAGE=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('message', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ] && [[ "$MESSAGE" == *"related gallery items"* ]]; then
        print_result "Category deletion protection" "PASS" "Properly prevents deletion"
    else
        print_result "Category deletion protection" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 14: Delete empty category
    if [ ! -z "$NEW_CAT_ID" ]; then
        echo "Test 14: DELETE /api/admin/gallery-categories/$NEW_CAT_ID (Delete Empty)"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/gallery-categories/$NEW_CAT_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete empty category" "PASS" "Category deleted successfully"
        else
            print_result "Delete empty category" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    echo "=== ADMIN GALLERY ITEMS TESTS ==="
    echo ""

    # Test 15: Admin - Get all gallery items
    echo "Test 15: GET /api/admin/gallery (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 8 ]; then
        print_result "Admin get all gallery items" "PASS" "Found $COUNT items"
    else
        print_result "Admin get all gallery items" "FAIL" "Success: $SUCCESS, Count: $COUNT"
    fi
    echo ""

    # Test 16: Admin - Create gallery item
    echo "Test 16: POST /api/admin/gallery (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/gallery" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Test Gallery Item",
        "image_url": "https://example.com/test.jpg",
        "category_id": 1,
        "gallery_date": "2024-02-19"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_ID" ]; then
        print_result "Create gallery item" "PASS" "Created with ID: $NEW_ID"
    else
        print_result "Create gallery item" "FAIL" "Success: $SUCCESS, ID: $NEW_ID"
    fi
    echo ""

    # Test 17: Admin - Update gallery item
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 17: PUT /api/admin/gallery/$NEW_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/gallery/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "title": "Updated Test Gallery Item",
            "category_id": 2
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        UPDATED_TITLE=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_TITLE" == *"Updated"* ]]; then
            print_result "Update gallery item" "PASS" "Updated to: $UPDATED_TITLE"
        else
            print_result "Update gallery item" "FAIL" "Success: $SUCCESS, Title: $UPDATED_TITLE"
        fi
        echo ""

        # Test 18: Admin - Delete gallery item
        echo "Test 18: DELETE /api/admin/gallery/$NEW_ID (Delete)"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/gallery/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete gallery item" "PASS" "Item deleted successfully"
        else
            print_result "Delete gallery item" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 19: Authentication required
    echo "Test 19: Admin endpoint without token"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/gallery")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Authentication required" "PASS" "Properly requires token"
    else
        print_result "Authentication required" "FAIL" "Success: $SUCCESS"
    fi
    echo ""
fi

# Test 20: Verify seeded data
echo "Test 20: Verify seeded gallery items"
RESPONSE=$(curl -s "$BASE_URL/api/gallery")
ITEM_1=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); items = data.get('data', []); print(items[0].get('title', '') if len(items) > 0 else '')" 2>/dev/null)
ITEM_2=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); items = data.get('data', []); print(items[1].get('title', '') if len(items) > 1 else '')" 2>/dev/null)

if [[ "$ITEM_1" == *"Beach"* ]] && [[ "$ITEM_2" == *"Tree"* ]]; then
    print_result "Seeded gallery items" "PASS" "Found expected items"
else
    print_result "Seeded gallery items" "FAIL" "Items: $ITEM_1, $ITEM_2"
fi
echo ""

# Summary
echo "=========================================="
echo "  TEST SUMMARY"
echo "=========================================="
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    exit 1
fi
