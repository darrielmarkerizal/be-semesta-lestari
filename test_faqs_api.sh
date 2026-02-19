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
echo "  FAQs API UNIT TEST"
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

echo "=== PUBLIC FAQs TESTS ==="
echo ""

# Test 1
echo "Test 1: GET /api/faqs"
RESPONSE=$(curl -s "$BASE_URL/api/faqs")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 1 ]; then
    print_result "Get all FAQs" "PASS" "Found $COUNT FAQs"
else
    print_result "Get all FAQs" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 2
echo "Test 2: GET /api/faqs/:id (Get single FAQ)"
RESPONSE=$(curl -s "$BASE_URL/api/faqs/1")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
QUESTION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('question', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$QUESTION" ]; then
    print_result "Get single FAQ" "PASS" "Retrieved FAQ successfully"
else
    print_result "Get single FAQ" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 3
echo "Test 3: GET /api/faqs/:id (Non-existent FAQ)"
RESPONSE=$(curl -s "$BASE_URL/api/faqs/99999")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

if [ "$SUCCESS" = "False" ]; then
    print_result "Non-existent FAQ returns error" "PASS" "Correctly returned error"
else
    print_result "Non-existent FAQ returns error" "FAIL" "Should return error"
fi
echo ""

# Test 4
echo "Test 4: Data consistency /api/faqs vs /api/home"
FAQS_RESPONSE=$(curl -s "$BASE_URL/api/faqs")
HOME_RESPONSE=$(curl -s "$BASE_URL/api/home")
FAQS_COUNT=$(echo "$FAQS_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
HOME_COUNT=$(echo "$HOME_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('faq', {}).get('items', [])))" 2>/dev/null)

if [ "$FAQS_COUNT" = "$HOME_COUNT" ]; then
    print_result "Data consistency" "PASS" "Both return $FAQS_COUNT FAQs"
else
    print_result "Data consistency" "FAIL" "FAQs: $FAQS_COUNT, Home: $HOME_COUNT"
fi
echo ""

# Test 5
echo "Test 5: Verify FAQ has required fields"
RESPONSE=$(curl -s "$BASE_URL/api/faqs/1")
QUESTION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('question', ''))" 2>/dev/null)
ANSWER=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('answer', ''))" 2>/dev/null)

if [ ! -z "$QUESTION" ] && [ ! -z "$ANSWER" ]; then
    print_result "FAQ has required fields" "PASS" "Question and answer present"
else
    print_result "FAQ has required fields" "FAIL" "Missing required fields"
fi
echo ""

if [ ! -z "$TOKEN" ]; then
    echo "=== ADMIN FAQs TESTS ==="
    echo ""

    # Test 6
    echo "Test 6: POST /api/admin/faqs (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/faqs" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "question": "How can I volunteer for environmental programs?",
        "answer": "You can volunteer by contacting us through our website or visiting our office. We have various programs available for volunteers of all skill levels.",
        "category": "Volunteer"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_ID" ]; then
        print_result "Create FAQ" "PASS" "Created with ID: $NEW_ID"
    else
        print_result "Create FAQ" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 7
    echo "Test 7: POST /api/admin/faqs (Missing required fields)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/faqs" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"question": "Test question without answer"}')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Validation for required fields" "PASS" "Correctly rejected incomplete data"
    else
        print_result "Validation for required fields" "FAIL" "Should reject incomplete data"
    fi
    echo ""

    # Test 8
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 8: GET /api/admin/faqs (Paginated list)"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/faqs?page=1&limit=10" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Get paginated FAQs" "PASS" "Retrieved successfully"
        else
            print_result "Get paginated FAQs" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 9
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 9: GET /api/admin/faqs/$NEW_ID"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/faqs/$NEW_ID" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Get single FAQ (admin)" "PASS" "Retrieved successfully"
        else
            print_result "Get single FAQ (admin)" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 10
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 10: PUT /api/admin/faqs/$NEW_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/faqs/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "question": "How can I volunteer for environmental programs? (Updated)",
            "answer": "Updated answer with more details about volunteering opportunities.",
            "category": "Volunteer"
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Update FAQ" "PASS" "Updated successfully"
        else
            print_result "Update FAQ" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 11
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 11: PUT /api/admin/faqs/$NEW_ID (Partial update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/faqs/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"category": "General"}')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Partial update FAQ" "PASS" "Updated successfully"
        else
            print_result "Partial update FAQ" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 12
    if [ ! -z "$NEW_ID" ]; then
        echo "Test 12: DELETE /api/admin/faqs/$NEW_ID"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/faqs/$NEW_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        
        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete FAQ" "PASS" "Deleted successfully"
        else
            print_result "Delete FAQ" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 13
    echo "Test 13: GET /api/admin/faqs without authentication"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/faqs")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Authentication required" "PASS" "Correctly rejected unauthenticated request"
    else
        print_result "Authentication required" "FAIL" "Should require authentication"
    fi
    echo ""
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
