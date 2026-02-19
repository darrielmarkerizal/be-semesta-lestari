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
echo "  PROGRAMS API UNIT TEST"
echo "=========================================="
echo ""

# Login first to get token (before any tests)
echo "Logging in to get authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}')

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}✗ Failed to get authentication token${NC}"
    echo "Please wait 15 minutes for rate limit to reset, or restart the server"
    echo "Continuing with public tests only..."
    echo ""
else
    echo -e "${GREEN}✓ Authentication successful${NC}"
    echo ""
fi

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

echo "=== PUBLIC PROGRAMS TESTS ==="
echo ""

# Test 1: Get all programs
echo "Test 1: GET /api/programs (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/programs")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$COUNT" -ge 1 ]; then
    print_result "Get all programs" "PASS" "Found $COUNT programs"
else
    print_result "Get all programs" "FAIL" "Success: $SUCCESS, Count: $COUNT"
fi
echo ""

# Test 2: Get single program
echo "Test 2: GET /api/programs/19 (Public)"
RESPONSE=$(curl -s "$BASE_URL/api/programs/19")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
PROGRAM_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$PROGRAM_NAME" ]; then
    print_result "Get single program" "PASS" "Program: $PROGRAM_NAME"
else
    print_result "Get single program" "FAIL" "Success: $SUCCESS, Name: $PROGRAM_NAME"
fi
echo ""

# Test 3: Verify program fields
echo "Test 3: Verify program required fields"
RESPONSE=$(curl -s "$BASE_URL/api/programs/19")
HAS_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('name' in data.get('data', {}))" 2>/dev/null)
HAS_DESCRIPTION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('description' in data.get('data', {}))" 2>/dev/null)
HAS_IS_HIGHLIGHTED=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('is_highlighted' in data.get('data', {}))" 2>/dev/null)
HAS_IS_ACTIVE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('is_active' in data.get('data', {}))" 2>/dev/null)

if [ "$HAS_NAME" = "True" ] && [ "$HAS_DESCRIPTION" = "True" ] && [ "$HAS_IS_HIGHLIGHTED" = "True" ] && [ "$HAS_IS_ACTIVE" = "True" ]; then
    print_result "Program required fields" "PASS" "All fields present"
else
    print_result "Program required fields" "FAIL" "Missing fields"
fi
echo ""

# Test 4: Non-existent program
echo "Test 4: GET /api/programs/9999 (Non-existent)"
RESPONSE=$(curl -s "$BASE_URL/api/programs/9999")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

if [ "$SUCCESS" = "False" ]; then
    print_result "Non-existent program" "PASS" "Returns 404 correctly"
else
    print_result "Non-existent program" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 5: Verify highlighted program exists
echo "Test 5: Verify highlighted program"
RESPONSE=$(curl -s "$BASE_URL/api/programs")
HIGHLIGHTED_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); programs = data.get('data', []); print(len([p for p in programs if p.get('is_highlighted')]))" 2>/dev/null)

if [ "$HIGHLIGHTED_COUNT" -ge 1 ]; then
    print_result "Highlighted program exists" "PASS" "Found $HIGHLIGHTED_COUNT highlighted program(s)"
else
    print_result "Highlighted program exists" "FAIL" "No highlighted programs found"
fi
echo ""

# Test 6: Verify programs in home endpoint
echo "Test 6: GET /api/home (Programs section)"
RESPONSE=$(curl -s "$BASE_URL/api/home")
HAS_PROGRAMS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('programs' in data.get('data', {}))" 2>/dev/null)
PROGRAMS_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('programs', {}).get('items', [])))" 2>/dev/null)
HAS_SECTION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('section' in data.get('data', {}).get('programs', {}))" 2>/dev/null)
HAS_HIGHLIGHTED=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('highlighted' in data.get('data', {}).get('programs', {}))" 2>/dev/null)

if [ "$HAS_PROGRAMS" = "True" ] && [ "$PROGRAMS_COUNT" -ge 1 ] && [ "$HAS_SECTION" = "True" ] && [ "$HAS_HIGHLIGHTED" = "True" ]; then
    print_result "Programs in home endpoint" "PASS" "Found $PROGRAMS_COUNT programs with section and highlighted"
else
    print_result "Programs in home endpoint" "FAIL" "Has programs: $HAS_PROGRAMS, Count: $PROGRAMS_COUNT"
fi
echo ""

# Test 7: Verify data consistency between endpoints
echo "Test 7: Data consistency between /api/programs and /api/home"
PROGRAMS_RESPONSE=$(curl -s "$BASE_URL/api/programs")
HOME_RESPONSE=$(curl -s "$BASE_URL/api/home")
PROGRAMS_FIRST_ID=$(echo "$PROGRAMS_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); programs = data.get('data', []); print(programs[0].get('id') if programs else '')" 2>/dev/null)
HOME_FIRST_ID=$(echo "$HOME_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); programs = data.get('data', {}).get('programs', {}).get('items', []); print(programs[0].get('id') if programs else '')" 2>/dev/null)

if [ "$PROGRAMS_FIRST_ID" = "$HOME_FIRST_ID" ] && [ ! -z "$PROGRAMS_FIRST_ID" ]; then
    print_result "Data consistency" "PASS" "Both endpoints return same program (ID: $PROGRAMS_FIRST_ID)"
else
    print_result "Data consistency" "FAIL" "Programs ID: $PROGRAMS_FIRST_ID, Home ID: $HOME_FIRST_ID"
fi
echo ""

# Get authentication token for admin tests
if [ -z "$TOKEN" ]; then
    echo "Getting authentication token..."
    TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"email":"admin@semestalestari.com","password":"admin123"}')

    TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('accessToken', ''))" 2>/dev/null)
fi

if [ -z "$TOKEN" ]; then
    echo -e "${YELLOW}⚠ Warning: Could not get authentication token${NC}"
    echo "Skipping admin tests..."
    echo ""
else
    echo -e "${GREEN}✓ Token ready for admin tests${NC}"
    echo ""

    echo "=== ADMIN PROGRAMS TESTS ==="
    echo ""

    # Test 8: Admin get all programs
    echo "Test 8: GET /api/admin/programs (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/programs" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
    HAS_PAGINATION=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('pagination' in data)" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ "$HAS_PAGINATION" = "True" ] && [ "$COUNT" -ge 1 ]; then
        print_result "Admin get all programs" "PASS" "Found $COUNT programs with pagination"
    else
        print_result "Admin get all programs" "FAIL" "Success: $SUCCESS, Count: $COUNT, Pagination: $HAS_PAGINATION"
    fi
    echo ""

    # Test 9: Admin create program
    echo "Test 9: POST /api/admin/programs (Create)"
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/programs" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Test Program for Unit Testing",
        "description": "This is a test program created during unit testing",
        "image_url": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09",
        "is_highlighted": false,
        "order_position": 100,
        "is_active": true
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    NEW_PROGRAM_ID=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('id', ''))" 2>/dev/null)

    if [ "$SUCCESS" = "True" ] && [ ! -z "$NEW_PROGRAM_ID" ]; then
        print_result "Create program" "PASS" "Created with ID: $NEW_PROGRAM_ID"
    else
        print_result "Create program" "FAIL" "Success: $SUCCESS, ID: $NEW_PROGRAM_ID"
    fi
    echo ""

    # Test 10: Admin get single program
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 10: GET /api/admin/programs/$NEW_PROGRAM_ID (Single)"
        RESPONSE=$(curl -s "$BASE_URL/api/admin/programs/$NEW_PROGRAM_ID" -H "Authorization: Bearer $TOKEN")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        PROGRAM_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$PROGRAM_NAME" == *"Test Program"* ]]; then
            print_result "Get single program (admin)" "PASS" "Retrieved: $PROGRAM_NAME"
        else
            print_result "Get single program (admin)" "FAIL" "Success: $SUCCESS, Name: $PROGRAM_NAME"
        fi
        echo ""
    fi

    # Test 11: Admin update program
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 11: PUT /api/admin/programs/$NEW_PROGRAM_ID (Update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/programs/$NEW_PROGRAM_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "name": "Updated Test Program",
            "is_highlighted": true
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        UPDATED_NAME=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)
        IS_HIGHLIGHTED=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('is_highlighted', 0))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [[ "$UPDATED_NAME" == *"Updated"* ]] && [ "$IS_HIGHLIGHTED" = "1" ]; then
            print_result "Update program" "PASS" "Updated name and highlighted status"
        else
            print_result "Update program" "FAIL" "Success: $SUCCESS, Name: $UPDATED_NAME, Highlighted: $IS_HIGHLIGHTED"
        fi
        echo ""
    fi

    # Test 12: Verify update reflects in public endpoint
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 12: Verify update in public endpoint"
        RESPONSE=$(curl -s "$BASE_URL/api/programs/$NEW_PROGRAM_ID")
        PROGRAM_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('name', ''))" 2>/dev/null)

        if [[ "$PROGRAM_NAME" == *"Updated"* ]]; then
            print_result "Update reflects in public" "PASS" "Public endpoint shows updated data"
        else
            print_result "Update reflects in public" "FAIL" "Name: $PROGRAM_NAME"
        fi
        echo ""
    fi

    # Test 13: Pagination
    echo "Test 13: GET /api/admin/programs?page=1&limit=5 (Pagination)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/programs?page=1&limit=5" -H "Authorization: Bearer $TOKEN")
    COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
    CURRENT_PAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('pagination', {}).get('currentPage', 0))" 2>/dev/null)
    ITEMS_PER_PAGE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('pagination', {}).get('itemsPerPage', 0))" 2>/dev/null)

    if [ "$COUNT" -le 5 ] && [ "$CURRENT_PAGE" = "1" ] && [ "$ITEMS_PER_PAGE" = "5" ]; then
        print_result "Pagination working" "PASS" "Returned $COUNT items, page 1, limit 5"
    else
        print_result "Pagination working" "FAIL" "Count: $COUNT, Page: $CURRENT_PAGE, Limit: $ITEMS_PER_PAGE"
    fi
    echo ""

    # Test 14: Partial update
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 14: PUT /api/admin/programs/$NEW_PROGRAM_ID (Partial update)"
        UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/programs/$NEW_PROGRAM_ID" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d '{
            "order_position": 999
          }')

        SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
        ORDER_POSITION=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('order_position', 0))" 2>/dev/null)
        NAME_UNCHANGED=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('Updated' in data.get('data', {}).get('name', ''))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ] && [ "$ORDER_POSITION" = "999" ] && [ "$NAME_UNCHANGED" = "True" ]; then
            print_result "Partial update" "PASS" "Only order_position updated, name unchanged"
        else
            print_result "Partial update" "FAIL" "Success: $SUCCESS, Order: $ORDER_POSITION"
        fi
        echo ""
    fi

    # Test 15: Delete program
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 15: DELETE /api/admin/programs/$NEW_PROGRAM_ID (Delete)"
        DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/programs/$NEW_PROGRAM_ID" \
          -H "Authorization: Bearer $TOKEN")

        SUCCESS=$(echo "$DELETE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

        if [ "$SUCCESS" = "True" ]; then
            print_result "Delete program" "PASS" "Program deleted successfully"
        else
            print_result "Delete program" "FAIL" "Success: $SUCCESS"
        fi
        echo ""
    fi

    # Test 16: Verify deletion
    if [ ! -z "$NEW_PROGRAM_ID" ]; then
        echo "Test 16: Verify program deleted"
        RESPONSE=$(curl -s "$BASE_URL/api/programs/$NEW_PROGRAM_ID")
        SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

        if [ "$SUCCESS" = "False" ]; then
            print_result "Verify deletion" "PASS" "Program no longer accessible"
        else
            print_result "Verify deletion" "FAIL" "Program still exists"
        fi
        echo ""
    fi

    # Test 17: Authentication required
    echo "Test 17: Admin endpoint without token"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/programs")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', True))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Authentication required" "PASS" "Properly requires token"
    else
        print_result "Authentication required" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 18: Verify highlighted program in home
    echo "Test 18: Verify highlighted program in /api/home"
    RESPONSE=$(curl -s "$BASE_URL/api/home")
    HIGHLIGHTED=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); highlighted = data.get('data', {}).get('programs', {}).get('highlighted'); print(highlighted.get('name', '') if highlighted else '')" 2>/dev/null)

    if [ ! -z "$HIGHLIGHTED" ]; then
        print_result "Highlighted in home" "PASS" "Found highlighted program: $HIGHLIGHTED"
    else
        print_result "Highlighted in home" "FAIL" "No highlighted program"
    fi
    echo ""
fi

# Test 19: Verify active programs only in public
echo "Test 19: Verify only active programs in public endpoint"
RESPONSE=$(curl -s "$BASE_URL/api/programs")
ALL_ACTIVE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); programs = data.get('data', []); print(all(p.get('is_active') for p in programs))" 2>/dev/null)

if [ "$ALL_ACTIVE" = "True" ]; then
    print_result "Only active programs public" "PASS" "All programs are active"
else
    print_result "Only active programs public" "FAIL" "Some inactive programs found"
fi
echo ""

# Test 20: Verify program count consistency
echo "Test 20: Verify program count consistency"
PROGRAMS_COUNT=$(curl -s "$BASE_URL/api/programs" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', [])))" 2>/dev/null)
HOME_COUNT=$(curl -s "$BASE_URL/api/home" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {}).get('programs', {}).get('items', [])))" 2>/dev/null)

if [ "$PROGRAMS_COUNT" = "$HOME_COUNT" ]; then
    print_result "Program count consistency" "PASS" "Both endpoints return $PROGRAMS_COUNT programs"
else
    print_result "Program count consistency" "FAIL" "Programs: $PROGRAMS_COUNT, Home: $HOME_COUNT"
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
