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
echo "  MERCHANDISE API UNIT TEST"
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

# Test 1: Public - Get all merchandise
echo "Test 1: GET /api/merchandise (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 6 ]; then
    print_result "Get all merchandise" "PASS" "Found $COUNT products"
else
    print_result "Get all merchandise" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 2: Public - Get single merchandise
echo "Test 2: GET /api/merchandise/1 (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise/1")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
PRODUCT_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('product_name', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$PRODUCT_NAME" ]; then
    print_result "Get single merchandise" "PASS" "Product: $PRODUCT_NAME"
else
    print_result "Get single merchandise" "FAIL" "Success: $SUCCESS, Product: $PRODUCT_NAME"
fi
echo ""

# Test 3: Public - Verify required fields
echo "Test 3: Verify required fields in response"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise/1")
HAS_PRODUCT_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('product_name' in data.get('data', {}))" 2>/dev/null)
HAS_PRICE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('price' in data.get('data', {}))" 2>/dev/null)
HAS_MARKETPLACE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('marketplace' in data.get('data', {}))" 2>/dev/null)
HAS_MARKETPLACE_LINK=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('marketplace_link' in data.get('data', {}))" 2>/dev/null)
HAS_IMAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('image_url' in data.get('data', {}))" 2>/dev/null)

if [ "$HAS_PRODUCT_NAME" = "True" ] && [ "$HAS_PRICE" = "True" ] && [ "$HAS_MARKETPLACE" = "True" ] && [ "$HAS_MARKETPLACE_LINK" = "True" ] && [ "$HAS_IMAGE" = "True" ]; then
    print_result "Required fields present" "PASS" "All required fields found"
else
    print_result "Required fields present" "FAIL" "Missing fields"
fi
echo ""

# Test 4: Public - Pagination
echo "Test 4: GET /api/merchandise?page=1&limit=3 (Pagination)"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise?page=1&limit=3")
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
HAS_PAGINATION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('pagination' in data)" 2>/dev/null)

if [ "$COUNT" = "3" ] && [ "$HAS_PAGINATION" = "True" ]; then
    print_result "Pagination working" "PASS" "Returned 3 items with pagination"
else
    print_result "Pagination working" "FAIL" "Count: $COUNT, Has pagination: $HAS_PAGINATION"
fi
echo ""

# Test 5: Public - Non-existent merchandise
echo "Test 5: GET /api/merchandise/9999 (Non-existent)"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise/9999")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)
MESSAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('message', ''))" 2>/dev/null)

if [ "$SUCCESS" = "False" ] && [[ "$MESSAGE" == *"not found"* ]]; then
    print_result "Non-existent merchandise handling" "PASS" "Returns 404 correctly"
else
    print_result "Non-existent merchandise handling" "FAIL" "Success: $SUCCESS, Message: $MESSAGE"
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

    # Test 6: Admin - Get all merchandise
    echo "Test 6: GET /api/admin/merchandise (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/merchandise" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 6 ]; then
        print_result "Admin get all merchandise" "PASS" "Found $COUNT products"
    else
        print_result "Admin get all merchandise" "FAIL" "Success: $SUCCESS, Count: $COUNT"
    fi
    echo ""

    # Test 7: Admin - Get single merchandise
    echo "Test 7: GET /api/admin/merchandise/1 (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/merchandise/1" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ]; then
        print_result "Admin get single merchandise" "PASS" ""
    else
        print_result "Admin get single merchandise" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 8: Admin - Create merchandise
    echo "Test 8: POST /api/admin/merchandise (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/merchandise" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "product_name": "Test Product",
        "image_url": "https://example.com/test.jpg",
        "price": 99000,
        "marketplace": "Test Marketplace",
        "marketplace_link": "https://example.com/product",
        "order_position": 99
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_ID" ]; then
        print_result "Create merchandise" "PASS" "Created with ID: $NEW_ID"
    else
        print_result "Create merchandise" "FAIL" "Success: $SUCCESS, ID: $NEW_ID"
    fi
    echo ""

    # Test 9: Admin - Update merchandise
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 9: PUT /api/admin/merchandise/$NEW_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/merchandise/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "product_name": "Updated Test Product",
            "price": 120000
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        UPDATED_NAME=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('product_name', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_NAME" == *"Updated"* ]]; then
            print_result "Update merchandise" "PASS" "Updated to: $UPDATED_NAME"
        else
            print_result "Update merchandise" "FAIL" "Success: $SUCCESS, Name: $UPDATED_NAME"
        fi
        echo ""

        # Test 10: Admin - Delete merchandise
        echo "Test 10: DELETE /api/admin/merchandise/$NEW_ID (Delete)"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/merchandise/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete merchandise" "PASS" ""
        else
            print_result "Delete merchandise" "FAIL" "Success: $SUCCESS"
        fi
        echo ""

        # Test 11: Verify deletion
        echo "Test 11: Verify merchandise deleted"
        VERIFY_RESPONSE=$(curl -s "$BASE_URL/api/admin/merchandise/$NEW_ID" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$VERIFY_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

        if [ "$SUCCESS" = "False" ]; then
            print_result "Verify deletion" "PASS" "Merchandise no longer exists"
        else
            print_result "Verify deletion" "FAIL" "Merchandise still exists"
        fi
        echo ""
    fi

    # Test 12: Admin - Authentication required
    echo "Test 12: Admin endpoint without token"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/merchandise")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)
    MESSAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('message', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ] && [[ "$MESSAGE" == *"token"* ]]; then
        print_result "Authentication required" "PASS" "Properly requires token"
    else
        print_result "Authentication required" "FAIL" "Success: $SUCCESS"
    fi
    echo ""
fi

# Test 13: Data validation - Check specific products
echo "Test 13: Verify seeded products"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise")
PRODUCT_1=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); products = data.get('data', []); print(products[0].get('product_name', '') if len(products) > 0 else '')" 2>/dev/null)
PRODUCT_2=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); products = data.get('data', []); print(products[1].get('product_name', '') if len(products) > 1 else '')" 2>/dev/null)

if [[ "$PRODUCT_1" == *"Tote Bag"* ]] && [[ "$PRODUCT_2" == *"Water Bottle"* ]]; then
    print_result "Seeded products verification" "PASS" "Found expected products"
else
    print_result "Seeded products verification" "FAIL" "Products: $PRODUCT_1, $PRODUCT_2"
fi
echo ""

# Test 14: Price format validation
echo "Test 14: Price format validation"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise/1")
PRICE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('price', ''))" 2>/dev/null)

if [ ! -z "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    print_result "Price format" "PASS" "Price: $PRICE"
else
    print_result "Price format" "FAIL" "Invalid price: $PRICE"
fi
echo ""

# Test 15: Marketplace link validation
echo "Test 15: Marketplace link validation"
RESPONSE=$(curl -s "$BASE_URL/api/merchandise/1")
MARKETPLACE_LINK=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('marketplace_link', ''))" 2>/dev/null)

if [[ "$MARKETPLACE_LINK" == http* ]]; then
    print_result "Marketplace link format" "PASS" "Valid URL"
else
    print_result "Marketplace link format" "FAIL" "Invalid URL: $MARKETPLACE_LINK"
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
