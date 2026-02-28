#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:3000/api"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test result
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓ PASS${NC}: $2"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗ FAIL${NC}: $2"
        if [ ! -z "$3" ]; then
            echo -e "${RED}  Error: $3${NC}"
        fi
    fi
}

# Function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed. Please install jq to run this test.${NC}"
        echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
}

echo -e "${YELLOW}=== Leadership Search & Pagination Test ===${NC}\n"

# Check dependencies
check_jq

# Step 1: Login as admin
echo -e "${YELLOW}Step 1: Logging in as admin...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "admin@semestalestari.com",
        "password": "admin123"
    }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken')

if [ "$TOKEN" != "null" ] && [ ! -z "$TOKEN" ]; then
    print_result 0 "Admin login successful"
else
    print_result 1 "Admin login failed" "$(echo $LOGIN_RESPONSE | jq -r '.message')"
    exit 1
fi

# Step 2: Create test leadership members
echo -e "\n${YELLOW}Step 2: Creating test leadership members...${NC}"

# Create leadership member 1 (active)
LEADER1=$(curl -s -X POST "$BASE_URL/admin/about/leadership" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "John Director",
        "position": "Executive Director",
        "bio": "Leading environmental conservation efforts with 20 years of experience in sustainable development.",
        "email": "john.director@test.com",
        "phone": "+62123456789",
        "is_highlighted": true,
        "order_position": 1,
        "is_active": true
    }')

LEADER1_ID=$(echo $LEADER1 | jq -r '.data.id')
if [ "$LEADER1_ID" != "null" ]; then
    print_result 0 "Created test leadership member 1 (John Director)"
else
    print_result 1 "Failed to create leadership member 1"
fi

# Create leadership member 2 (active)
LEADER2=$(curl -s -X POST "$BASE_URL/admin/about/leadership" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Sarah Manager",
        "position": "Program Manager",
        "bio": "Managing community outreach programs and environmental education initiatives.",
        "email": "sarah.manager@test.com",
        "order_position": 2,
        "is_active": true
    }')

LEADER2_ID=$(echo $LEADER2 | jq -r '.data.id')
if [ "$LEADER2_ID" != "null" ]; then
    print_result 0 "Created test leadership member 2 (Sarah Manager)"
else
    print_result 1 "Failed to create leadership member 2"
fi

# Create leadership member 3 (active)
LEADER3=$(curl -s -X POST "$BASE_URL/admin/about/leadership" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Michael Coordinator",
        "position": "Field Coordinator",
        "bio": "Coordinating field operations and conservation projects across multiple regions.",
        "email": "michael.coordinator@test.com",
        "order_position": 3,
        "is_active": true
    }')

LEADER3_ID=$(echo $LEADER3 | jq -r '.data.id')
if [ "$LEADER3_ID" != "null" ]; then
    print_result 0 "Created test leadership member 3 (Michael Coordinator)"
else
    print_result 1 "Failed to create leadership member 3"
fi

# Create leadership member 4 (inactive)
LEADER4=$(curl -s -X POST "$BASE_URL/admin/about/leadership" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Emily Advisor",
        "position": "Environmental Advisor",
        "bio": "Providing strategic advice on environmental policy and sustainability practices.",
        "email": "emily.advisor@test.com",
        "order_position": 4,
        "is_active": false
    }')

LEADER4_ID=$(echo $LEADER4 | jq -r '.data.id')
if [ "$LEADER4_ID" != "null" ]; then
    print_result 0 "Created test leadership member 4 (Emily Advisor - inactive)"
else
    print_result 1 "Failed to create leadership member 4"
fi

# Step 3: Test pagination
echo -e "\n${YELLOW}Step 3: Testing pagination...${NC}"

PAGINATED=$(curl -s -X GET "$BASE_URL/admin/about/leadership?page=1&limit=2" \
    -H "Authorization: Bearer $TOKEN")

ITEM_COUNT=$(echo $PAGINATED | jq '.data | length')
CURRENT_PAGE=$(echo $PAGINATED | jq -r '.pagination.currentPage')
ITEMS_PER_PAGE=$(echo $PAGINATED | jq -r '.pagination.itemsPerPage')

if [ "$ITEM_COUNT" -eq 2 ] && [ "$CURRENT_PAGE" -eq 1 ] && [ "$ITEMS_PER_PAGE" -eq 2 ]; then
    print_result 0 "Admin API pagination working (page 1, limit 2)"
else
    print_result 1 "Admin API pagination not working correctly" "Expected 2 items, got $ITEM_COUNT"
fi

# Step 4: Test search by name
echo -e "\n${YELLOW}Step 4: Testing search by name...${NC}"

SEARCH_NAME=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=John%20Director" \
    -H "Authorization: Bearer $TOKEN")

FOUND_JOHN=$(echo $SEARCH_NAME | jq -r '.data[] | select(.name == "John Director") | .name')

if [ "$FOUND_JOHN" == "John Director" ]; then
    print_result 0 "Admin API search by name working"
else
    print_result 1 "Admin API search by name not working" "Could not find 'John Director' in results"
fi

# Step 5: Test search by position
echo -e "\n${YELLOW}Step 5: Testing search by position...${NC}"

SEARCH_POSITION=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=Program%20Manager" \
    -H "Authorization: Bearer $TOKEN")

FOUND_SARAH=$(echo $SEARCH_POSITION | jq -r '.data[] | select(.name == "Sarah Manager") | .name')

if [ "$FOUND_SARAH" == "Sarah Manager" ]; then
    print_result 0 "Admin API search by position working"
else
    print_result 1 "Admin API search by position not working" "Could not find 'Sarah Manager' in results"
fi

# Step 6: Test search by bio
echo -e "\n${YELLOW}Step 6: Testing search by bio...${NC}"

SEARCH_BIO=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=conservation" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_BIO | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by bio working"
else
    print_result 1 "Admin API search by bio not working"
fi

# Step 7: Test search by email
echo -e "\n${YELLOW}Step 7: Testing search by email...${NC}"

SEARCH_EMAIL=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=michael.coordinator" \
    -H "Authorization: Bearer $TOKEN")

FOUND_MICHAEL=$(echo $SEARCH_EMAIL | jq -r '.data[] | select(.name == "Michael Coordinator") | .email')

if [[ "$FOUND_MICHAEL" == *"michael.coordinator"* ]]; then
    print_result 0 "Admin API search by email working"
else
    print_result 1 "Admin API search by email not working" "Could not find Michael's email in results"
fi

# Step 8: Test search with pagination
echo -e "\n${YELLOW}Step 8: Testing search with pagination...${NC}"

SEARCH_PAGINATED=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=environmental&page=1&limit=5" \
    -H "Authorization: Bearer $TOKEN")

SUCCESS=$(echo $SEARCH_PAGINATED | jq -r '.success')
HAS_PAGINATION=$(echo $SEARCH_PAGINATED | jq -r '.pagination')

if [ "$SUCCESS" == "true" ] && [ "$HAS_PAGINATION" != "null" ]; then
    print_result 0 "Admin API search with pagination working"
else
    print_result 1 "Admin API search with pagination not working"
fi

# Step 9: Test that admin API includes inactive items
echo -e "\n${YELLOW}Step 9: Testing admin API includes inactive items...${NC}"

ALL_ITEMS=$(curl -s -X GET "$BASE_URL/admin/about/leadership?page=1&limit=10" \
    -H "Authorization: Bearer $TOKEN")

TOTAL_ITEMS=$(echo $ALL_ITEMS | jq -r '.pagination.totalItems')

if [ "$TOTAL_ITEMS" -ge 4 ]; then
    print_result 0 "Admin API includes inactive items"
else
    print_result 1 "Admin API does not include inactive items" "Expected at least 4 items, got $TOTAL_ITEMS"
fi

# Step 10: Test pagination metadata
echo -e "\n${YELLOW}Step 10: Testing pagination metadata...${NC}"

METADATA=$(curl -s -X GET "$BASE_URL/admin/about/leadership?page=1&limit=2" \
    -H "Authorization: Bearer $TOKEN")

HAS_CURRENT_PAGE=$(echo $METADATA | jq -r '.pagination.currentPage')
HAS_TOTAL_PAGES=$(echo $METADATA | jq -r '.pagination.totalPages')
HAS_TOTAL_ITEMS=$(echo $METADATA | jq -r '.pagination.totalItems')
HAS_ITEMS_PER_PAGE=$(echo $METADATA | jq -r '.pagination.itemsPerPage')
HAS_NEXT_PAGE=$(echo $METADATA | jq -r '.pagination.hasNextPage')
HAS_PREV_PAGE=$(echo $METADATA | jq -r '.pagination.hasPrevPage')

if [ "$HAS_CURRENT_PAGE" != "null" ] && [ "$HAS_TOTAL_PAGES" != "null" ] && [ "$HAS_TOTAL_ITEMS" != "null" ] && [ "$HAS_ITEMS_PER_PAGE" != "null" ] && [ "$HAS_NEXT_PAGE" != "null" ] && [ "$HAS_PREV_PAGE" != "null" ]; then
    print_result 0 "Pagination metadata correct"
else
    print_result 1 "Pagination metadata incomplete"
fi

# Step 11: Test case insensitive search
echo -e "\n${YELLOW}Step 11: Testing case insensitive search...${NC}"

SEARCH_UPPER=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=DIRECTOR" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_UPPER | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Case insensitive search working"
else
    print_result 1 "Case insensitive search not working"
fi

# Step 12: Test partial word search
echo -e "\n${YELLOW}Step 12: Testing partial word search...${NC}"

SEARCH_PARTIAL=$(curl -s -X GET "$BASE_URL/admin/about/leadership?search=Field%20Coord" \
    -H "Authorization: Bearer $TOKEN")

FOUND_MICHAEL=$(echo $SEARCH_PARTIAL | jq -r '.data[] | select(.name == "Michael Coordinator") | .name')

if [ "$FOUND_MICHAEL" == "Michael Coordinator" ]; then
    print_result 0 "Partial word search working"
else
    print_result 1 "Partial word search not working" "Could not find 'Michael Coordinator' with partial search"
fi

# Step 13: Test order by order_position
echo -e "\n${YELLOW}Step 13: Testing order by order_position...${NC}"

ORDERED=$(curl -s -X GET "$BASE_URL/admin/about/leadership?page=1&limit=10" \
    -H "Authorization: Bearer $TOKEN")

FIRST_ORDER=$(echo $ORDERED | jq -r '.data[0].order_position')
SECOND_ORDER=$(echo $ORDERED | jq -r '.data[1].order_position')

if [ "$FIRST_ORDER" -le "$SECOND_ORDER" ]; then
    print_result 0 "Order by order_position working"
else
    print_result 1 "Order by order_position not working" "Expected ascending order"
fi

# Cleanup: Delete test leadership members
echo -e "\n${YELLOW}Cleanup: Deleting test leadership members...${NC}"

if [ "$LEADER1_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/about/leadership/$LEADER1_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted leadership member 1"
fi

if [ "$LEADER2_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/about/leadership/$LEADER2_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted leadership member 2"
fi

if [ "$LEADER3_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/about/leadership/$LEADER3_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted leadership member 3"
fi

if [ "$LEADER4_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/about/leadership/$LEADER4_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted leadership member 4"
fi

# Print summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi
