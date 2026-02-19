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
echo "  CONTACT API UNIT TEST"
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

echo "=== CONTACT INFO TESTS (PUBLIC) ==="
echo ""

# Test 1: Get contact info
echo "Test 1: GET /api/contact/info (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/contact/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
HAS_EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('email' in data.get('data', {}))" 2>/dev/null)
HAS_PHONES=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('phones' in data.get('data', {}))" 2>/dev/null)
HAS_ADDRESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('address' in data.get('data', {}))" 2>/dev/null)
HAS_WORK_HOURS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('work_hours' in data.get('data', {}))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$HAS_EMAIL" = "True" ] && [ "$HAS_PHONES" = "True" ] && [ "$HAS_ADDRESS" = "True" ] && [ "$HAS_WORK_HOURS" = "True" ]; then
    print_result "Get contact info" "PASS" "All fields present"
else
    print_result "Get contact info" "FAIL" "Success: $SUCCESS, Fields: email=$HAS_EMAIL, phones=$HAS_PHONES, address=$HAS_ADDRESS, work_hours=$HAS_WORK_HOURS"
fi
echo ""

# Test 2: Verify phones is an array
echo "Test 2: Verify phones field is an array"
RESPONSE=$(curl -s "$BASE_URL/api/contact/info")
PHONES_IS_ARRAY=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); phones = data.get('data', {}).get('phones', []); print(isinstance(phones, list))" 2>/dev/null)
PHONES_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('phones', [])))" 2>/dev/null)

if [ "$PHONES_IS_ARRAY" = "True" ] && [ "$PHONES_COUNT" -ge 1 ]; then
    print_result "Phones is array" "PASS" "Found $PHONES_COUNT phone numbers"
else
    print_result "Phones is array" "FAIL" "Is array: $PHONES_IS_ARRAY, Count: $PHONES_COUNT"
fi
echo ""

# Test 3: Verify email format
echo "Test 3: Verify email format"
RESPONSE=$(curl -s "$BASE_URL/api/contact/info")
EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('email', ''))" 2>/dev/null)

if [[ "$EMAIL" == *"@"* ]]; then
    print_result "Email format valid" "PASS" "Email: $EMAIL"
else
    print_result "Email format valid" "FAIL" "Email: $EMAIL"
fi
echo ""

echo "=== CONTACT MESSAGE TESTS (PUBLIC) ==="
echo ""

# Test 4: Send contact message
echo "Test 4: POST /api/contact/send-message (Valid)"
SEND_RESPONSE=$(curl -s -X POST "$BASE_URL/api/contact/send-message" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+62 812 3456 7890",
    "subject": "Test Subject",
    "message": "This is a test message for unit testing."
  }')

SUCCESS=$(echo "$SEND_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
MESSAGE_ID=$(echo "$SEND_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$MESSAGE_ID" ]; then
    print_result "Send contact message" "PASS" "Message ID: $MESSAGE_ID"
else
    print_result "Send contact message" "FAIL" "Success: $SUCCESS, ID: $MESSAGE_ID"
fi
echo ""

# Test 5: Send message without optional fields
echo "Test 5: POST /api/contact/send-message (Without optional fields)"
SEND_RESPONSE=$(curl -s -X POST "$BASE_URL/api/contact/send-message" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Minimal User",
    "email": "minimal@example.com",
    "message": "Message without phone and subject."
  }')

SUCCESS=$(echo "$SEND_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

if [ "$SUCCESS" = "True" ]; then
    print_result "Send message (minimal fields)" "PASS" "Message sent successfully"
else
    print_result "Send message (minimal fields)" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 6: Send message with missing required field
echo "Test 6: POST /api/contact/send-message (Missing required field)"
SEND_RESPONSE=$(curl -s -X POST "$BASE_URL/api/contact/send-message" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com"
  }')

SUCCESS=$(echo "$SEND_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

if [ "$SUCCESS" = "False" ]; then
    print_result "Validation for required fields" "PASS" "Properly rejects missing message"
else
    print_result "Validation for required fields" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Get authentication token for admin tests
echo "Getting authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}')

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo -e "${YELLOW}⚠ Warning: Could not get authentication token${NC}"
    echo "Skipping admin tests..."
    echo ""
else
    echo -e "${GREEN}✓ Token obtained${NC}"
    echo ""

    echo "=== ADMIN CONTACT INFO TESTS ==="
    echo ""

    # Test 7: Admin get contact info
    echo "Test 7: GET /api/admin/contact/info (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/info" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    HAS_EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('email' in data.get('data', {}))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$HAS_EMAIL" = "True" ]; then
        print_result "Admin get contact info" "PASS" "Contact info retrieved"
    else
        print_result "Admin get contact info" "FAIL" "Success: $SUCCESS, Has email: $HAS_EMAIL"
    fi
    echo ""

    # Test 8: Update contact info (partial update)
    echo "Test 8: PUT /api/admin/contact/info (Partial update)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/contact/info" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "updated@semestalestari.org"
      }')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    UPDATED_EMAIL=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('email', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_EMAIL" == *"updated"* ]]; then
        print_result "Update contact info (partial)" "PASS" "Email updated to: $UPDATED_EMAIL"
    else
        print_result "Update contact info (partial)" "FAIL" "Success: $SUCCESS, Email: $UPDATED_EMAIL"
    fi
    echo ""

    # Test 9: Update phones array
    echo "Test 9: PUT /api/admin/contact/info (Update phones)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/contact/info" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "phones": ["(+62) 21-9999-8888", "(+62) 811-2222-3333", "(+62) 812-4444-5555"]
      }')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    PHONES_COUNT=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('phones', [])))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$PHONES_COUNT" = "3" ]; then
        print_result "Update phones array" "PASS" "Updated to $PHONES_COUNT phones"
    else
        print_result "Update phones array" "FAIL" "Success: $SUCCESS, Count: $PHONES_COUNT"
    fi
    echo ""

    # Test 10: Update work hours
    echo "Test 10: PUT /api/admin/contact/info (Update work hours)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/contact/info" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "work_hours": "Monday - Sunday: 24/7"
      }')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    WORK_HOURS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('work_hours', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [[ "$WORK_HOURS" == *"24/7"* ]]; then
        print_result "Update work hours" "PASS" "Work hours updated"
    else
        print_result "Update work hours" "FAIL" "Success: $SUCCESS, Hours: $WORK_HOURS"
    fi
    echo ""

    # Restore original contact info
    echo "Restoring original contact info..."
    curl -s -X PUT "$BASE_URL/api/admin/contact/info" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "info@semestalestari.org",
        "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
        "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
      }' > /dev/null
    echo -e "${GREEN}✓ Contact info restored${NC}"
    echo ""

    echo "=== ADMIN CONTACT MESSAGES TESTS ==="
    echo ""

    # Test 11: Get all messages
    echo "Test 11: GET /api/admin/contact/show-messages (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/show-messages" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
    HAS_PAGINATION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('pagination' in data)" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$HAS_PAGINATION" = "True" ] && [ "$COUNT" -ge 2 ]; then
        print_result "Get all messages" "PASS" "Found $COUNT messages with pagination"
    else
        print_result "Get all messages" "FAIL" "Success: $SUCCESS, Count: $COUNT, Pagination: $HAS_PAGINATION"
    fi
    echo ""

    # Test 11b: Admin create message (CRUD - Create)
    echo "Test 11b: POST /api/admin/contact/show-messages (Admin Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/contact/show-messages" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Admin Test User",
        "email": "admintest@example.com",
        "phone": "+62 999 8888 7777",
        "subject": "Admin Created Message",
        "message": "This message was created by admin for testing CRUD operations"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    ADMIN_MESSAGE_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$ADMIN_MESSAGE_ID" ]; then
        print_result "Admin create message" "PASS" "Created with ID: $ADMIN_MESSAGE_ID"
    else
        print_result "Admin create message" "FAIL" "Success: $SUCCESS, ID: $ADMIN_MESSAGE_ID"
    fi
    echo ""

    # Test 12: Get single message
    if [ ! -z "$MESSAGE_ID" ]; then
        echo "Test 12: GET /api/admin/contact/show-messages/$MESSAGE_ID (Single message)"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/show-messages/$MESSAGE_ID" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        MESSAGE_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [ ! -z "$MESSAGE_NAME" ]; then
            print_result "Get single message" "PASS" "Message from: $MESSAGE_NAME"
        else
            print_result "Get single message" "FAIL" "Success: $SUCCESS, Name: $MESSAGE_NAME"
        fi
        echo ""
    fi

    # Test 12b: Update message (CRUD - Update)
    if [ ! -z "$ADMIN_MESSAGE_ID" ]; then
        echo "Test 12b: PUT /api/admin/contact/show-messages/$ADMIN_MESSAGE_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/contact/show-messages/$ADMIN_MESSAGE_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "subject": "Updated Admin Message",
            "is_replied": true
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        UPDATED_SUBJECT=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('subject', ''))" 2>/dev/null)
        IS_REPLIED=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('is_replied', 0))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_SUBJECT" == *"Updated"* ]] && [ "$IS_REPLIED" = "1" ]; then
            print_result "Update message" "PASS" "Subject updated and marked as replied"
        else
            print_result "Update message" "FAIL" "Success: $SUCCESS, Subject: $UPDATED_SUBJECT, Replied: $IS_REPLIED"
        fi
        echo ""
    fi

    # Test 13: Verify message fields
    if [ ! -z "$MESSAGE_ID" ]; then
        echo "Test 13: Verify message required fields"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/show-messages/$MESSAGE_ID" -H "Authorization: Bearer $TOKEN")
        HAS_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('name' in data.get('data', {}))" 2>/dev/null)
        HAS_EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('email' in data.get('data', {}))" 2>/dev/null)
        HAS_MESSAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('message' in data.get('data', {}))" 2>/dev/null)
        HAS_IS_READ=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('is_read' in data.get('data', {}))" 2>/dev/null)

        if [ "$HAS_NAME" = "True" ] && [ "$HAS_EMAIL" = "True" ] && [ "$HAS_MESSAGE" = "True" ] && [ "$HAS_IS_READ" = "True" ]; then
            print_result "Message required fields" "PASS" "All fields present"
        else
            print_result "Message required fields" "FAIL" "Missing fields"
        fi
        echo ""
    fi

    # Test 14: Mark message as read
    if [ ! -z "$MESSAGE_ID" ]; then
        echo "Test 14: PUT /api/admin/contact/show-messages/$MESSAGE_ID/read (Mark as read)"
        RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/contact/show-messages/$MESSAGE_ID/read" \
          -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        IS_READ=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('is_read', 0))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [ "$IS_READ" = "1" ]; then
            print_result "Mark message as read" "PASS" "Message marked as read"
        else
            print_result "Mark message as read" "FAIL" "Success: $SUCCESS, Is read: $IS_READ"
        fi
        echo ""
    fi

    # Test 15: Pagination
    echo "Test 15: GET /api/admin/contact/show-messages?page=1&limit=1 (Pagination)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/show-messages?page=1&limit=1" -H "Authorization: Bearer $TOKEN")
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
    CURRENT_PAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('pagination', {}).get('currentPage', 0))" 2>/dev/null)
    ITEMS_PER_PAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('pagination', {}).get('itemsPerPage', 0))" 2>/dev/null)

    if [ "$COUNT" = "1" ] && [ "$CURRENT_PAGE" = "1" ] && [ "$ITEMS_PER_PAGE" = "1" ]; then
        print_result "Pagination working" "PASS" "Returned 1 item per page"
    else
        print_result "Pagination working" "FAIL" "Count: $COUNT, Page: $CURRENT_PAGE, Limit: $ITEMS_PER_PAGE"
    fi
    echo ""

    # Test 16: Non-existent message
    echo "Test 16: GET /api/admin/contact/show-messages/9999 (Non-existent)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/show-messages/9999" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Non-existent message" "PASS" "Returns 404 correctly"
    else
        print_result "Non-existent message" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 17: Delete message
    if [ ! -z "$MESSAGE_ID" ]; then
        echo "Test 17: DELETE /api/admin/contact/show-messages/$MESSAGE_ID (Delete)"
        RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/contact/show-messages/$MESSAGE_ID" \
          -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete message" "PASS" "Message deleted successfully"
        else
            print_result "Delete message" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 17b: Delete admin created message (CRUD - Delete)
    if [ ! -z "$ADMIN_MESSAGE_ID" ]; then
        echo "Test 17b: DELETE /api/admin/contact/show-messages/$ADMIN_MESSAGE_ID (Delete admin message)"
        RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/contact/show-messages/$ADMIN_MESSAGE_ID" \
          -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete admin message" "PASS" "Admin message deleted successfully"
        else
            print_result "Delete admin message" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 18: Authentication required for admin endpoints
    echo "Test 18: Admin endpoint without token"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/contact/info")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Authentication required" "PASS" "Properly requires token"
    else
        print_result "Authentication required" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 19: Verify public endpoint still works after updates
    echo "Test 19: Verify public contact info after admin updates"
    RESPONSE=$(curl -s "$BASE_URL/api/contact/info")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('email', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$EMAIL" = "info@semestalestari.org" ]; then
        print_result "Public endpoint consistency" "PASS" "Contact info restored correctly"
    else
        print_result "Public endpoint consistency" "FAIL" "Success: $SUCCESS, Email: $EMAIL"
    fi
    echo ""
fi

# Test 20: Verify contact info structure
echo "Test 20: Verify complete contact info structure"
RESPONSE=$(curl -s "$BASE_URL/api/contact/info")
EMAIL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('email', ''))" 2>/dev/null)
PHONES=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('phones', []))" 2>/dev/null)
ADDRESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('address', ''))" 2>/dev/null)
WORK_HOURS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('work_hours', ''))" 2>/dev/null)

if [ ! -z "$EMAIL" ] && [[ "$PHONES" == *"62"* ]] && [ ! -z "$ADDRESS" ] && [ ! -z "$WORK_HOURS" ]; then
    print_result "Complete contact info structure" "PASS" "All fields populated"
else
    print_result "Complete contact info structure" "FAIL" "Some fields empty"
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
