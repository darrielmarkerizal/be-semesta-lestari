#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

BASE_URL="http://localhost:3000"

echo "=========================================="
echo "  PARTNERS API UNIT TEST"
echo "=========================================="
echo ""

# Login first
echo "Logging in to get authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}')

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}✗ Failed to get authentication token${NC}"
    echo "Please wait 15 minutes for rate limit to reset"
    echo "Continuing with public tests only..."
    echo ""
else
    echo -e "${GREEN}✓ Authentication successful${NC}"
    echo ""
fi

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

echo "=== PUBLIC PARTNERS TESTS ==="
echo ""

# Test 1
echo "Test 1: GET /api/partners"
RESPONSE=$(curl -s "$BASE_URL/api/partners")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 1 ]; then
    print_result "Get all partners" "PASS" "Found $COUNT partners"
else
    print_result "Get all partners" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 2
echo "Test 2: Data consistency /api/partners vs /api/home"
PARTNERS_RESPONSE=$(curl -s "$BASE_URL/api/partners")
HOME_RESPONSE=$(curl -s "$BASE_URL/api/home")
PARTNERS_COUNT=$(echo "$PARTNERS_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
HOME_COUNT=$(echo "$HOME_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('partners', {}).get('items', [])))" 2>/dev/null)

if [ "$PARTNERS_COUNT" = "$HOME_COUNT" ]; then
    print_result "Data consistency" "PASS" "Both return $PARTNERS_COUNT partners"
else
    print_result "Data consistency" "FAIL" "Partners: $PARTNERS_COUNT, Home: $HOME_COUNT"
fi
echo ""

if [ ! -z "$TOKEN" ]; then
    echo "=== ADMIN PARTNERS TESTS ==="
    echo ""

    # Test 3
    echo "Test 3: POST /api/admin/partners (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/partners" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Test Partner Organization",
        "description": "A test partner for unit testing",
        "logo_url": "https://via.placeholder.com/150",
        "website": "https://testpartner.org"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_ID" ]; then
        print_result "Create partner" "PASS" "Created with ID: $NEW_ID"
    else
        print_result "Create partner" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 4
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 4: GET /api/admin/partners/$NEW_ID"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/partners/$NEW_ID" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Get single partner" "PASS" "Retrieved successfully"
        else
            print_result "Get single partner" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 5
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 5: PUT /api/admin/partners/$NEW_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/partners/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"name":"Updated Test Partner"}')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Update partner" "PASS" "Updated successfully"
        else
            print_result "Update partner" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 6
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 6: DELETE /api/admin/partners/$NEW_ID"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/partners/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete partner" "PASS" "Deleted successfully"
        else
            print_result "Delete partner" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi
fi

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
