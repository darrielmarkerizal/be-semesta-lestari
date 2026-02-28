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

echo -e "${YELLOW}=== Partners Search & Pagination Test ===${NC}\n"

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

# Step 2: Create test partners
echo -e "\n${YELLOW}Step 2: Creating test partners...${NC}"

# Create partner 1 (active)
PARTNER1=$(curl -s -X POST "$BASE_URL/admin/partners" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Green Earth Foundation",
        "description": "International environmental organization dedicated to conservation and sustainability initiatives worldwide.",
        "website": "https://greenearthfoundation.org",
        "order_position": 1,
        "is_active": true
    }')

PARTNER1_ID=$(echo $PARTNER1 | jq -r '.data.id')
if [ "$PARTNER1_ID" != "null" ]; then
    print_result 0 "Created test partner 1 (Green Earth Foundation)"
else
    print_result 1 "Failed to create partner 1"
fi

# Create partner 2 (active)
PARTNER2=$(curl -s -X POST "$BASE_URL/admin/partners" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Wildlife Conservation Society",
        "description": "Global organization protecting wildlife and wild places through science, conservation action, and education.",
        "website": "https://wildlifeconservation.org",
        "order_position": 2,
        "is_active": true
    }')

PARTNER2_ID=$(echo $PARTNER2 | jq -r '.data.id')
if [ "$PARTNER2_ID" != "null" ]; then
    print_result 0 "Created test partner 2 (Wildlife Conservation Society)"
else
    print_result 1 "Failed to create partner 2"
fi

# Create partner 3 (active)
PARTNER3=$(curl -s -X POST "$BASE_URL/admin/partners" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Ocean Protection Alliance",
        "description": "Marine conservation organization working to protect ocean ecosystems and marine biodiversity.",
        "website": "https://oceanprotection.org",
        "order_position": 3,
        "is_active": true
    }')

PARTNER3_ID=$(echo $PARTNER3 | jq -r '.data.id')
if [ "$PARTNER3_ID" != "null" ]; then
    print_result 0 "Created test partner 3 (Ocean Protection Alliance)"
else
    print_result 1 "Failed to create partner 3"
fi

# Create partner 4 (inactive)
PARTNER4=$(curl -s -X POST "$BASE_URL/admin/partners" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "Sustainable Future Network",
        "description": "Network of organizations promoting sustainable development and environmental stewardship.",
        "website": "https://sustainablefuture.net",
        "order_position": 4,
        "is_active": false
    }')

PARTNER4_ID=$(echo $PARTNER4 | jq -r '.data.id')
if [ "$PARTNER4_ID" != "null" ]; then
    print_result 0 "Created test partner 4 (Sustainable Future Network - inactive)"
else
    print_result 1 "Failed to create partner 4"
fi

# Step 3: Test pagination
echo -e "\n${YELLOW}Step 3: Testing pagination...${NC}"

PAGINATED=$(curl -s -X GET "$BASE_URL/admin/partners?page=1&limit=2" \
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

SEARCH_NAME=$(curl -s -X GET "$BASE_URL/admin/partners?search=Foundation" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_NAME | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by name working"
else
    print_result 1 "Admin API search by name not working" "No results found"
fi

# Step 5: Test search by description
echo -e "\n${YELLOW}Step 5: Testing search by description...${NC}"

SEARCH_DESC=$(curl -s -X GET "$BASE_URL/admin/partners?search=wildlife" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_DESC | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by description working"
else
    print_result 1 "Admin API search by description not working" "No results found"
fi

# Step 6: Test search by website
echo -e "\n${YELLOW}Step 6: Testing search by website...${NC}"

SEARCH_WEBSITE=$(curl -s -X GET "$BASE_URL/admin/partners?search=.org" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_WEBSITE | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by website working"
else
    print_result 1 "Admin API search by website not working" "No results found"
fi

# Step 7: Test search with pagination
echo -e "\n${YELLOW}Step 7: Testing search with pagination...${NC}"

SEARCH_PAGINATED=$(curl -s -X GET "$BASE_URL/admin/partners?search=conservation&page=1&limit=5" \
    -H "Authorization: Bearer $TOKEN")

SUCCESS=$(echo $SEARCH_PAGINATED | jq -r '.success')
HAS_PAGINATION=$(echo $SEARCH_PAGINATED | jq -r '.pagination')

if [ "$SUCCESS" == "true" ] && [ "$HAS_PAGINATION" != "null" ]; then
    print_result 0 "Admin API search with pagination working"
else
    print_result 1 "Admin API search with pagination not working"
fi

# Step 8: Test that admin API includes inactive items
echo -e "\n${YELLOW}Step 8: Testing admin API includes inactive items...${NC}"

ALL_ITEMS=$(curl -s -X GET "$BASE_URL/admin/partners?page=1&limit=20" \
    -H "Authorization: Bearer $TOKEN")

TOTAL_ITEMS=$(echo $ALL_ITEMS | jq -r '.pagination.totalItems')

if [ "$TOTAL_ITEMS" -ge 4 ]; then
    print_result 0 "Admin API includes inactive items"
else
    print_result 1 "Admin API does not include inactive items" "Expected at least 4 items, got $TOTAL_ITEMS"
fi

# Step 9: Test pagination metadata
echo -e "\n${YELLOW}Step 9: Testing pagination metadata...${NC}"

METADATA=$(curl -s -X GET "$BASE_URL/admin/partners?page=1&limit=2" \
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

# Step 10: Test case insensitive search
echo -e "\n${YELLOW}Step 10: Testing case insensitive search...${NC}"

SEARCH_UPPER=$(curl -s -X GET "$BASE_URL/admin/partners?search=OCEAN" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_UPPER | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Case insensitive search working"
else
    print_result 1 "Case insensitive search not working" "No results found with uppercase search"
fi

# Step 11: Test partial word search
echo -e "\n${YELLOW}Step 11: Testing partial word search...${NC}"

SEARCH_PARTIAL=$(curl -s -X GET "$BASE_URL/admin/partners?search=Conserv" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_PARTIAL | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Partial word search working"
else
    print_result 1 "Partial word search not working" "No results found with partial search"
fi

# Step 12: Test order by order_position
echo -e "\n${YELLOW}Step 12: Testing order by order_position...${NC}"

ORDERED=$(curl -s -X GET "$BASE_URL/admin/partners?page=1&limit=10" \
    -H "Authorization: Bearer $TOKEN")

FIRST_ORDER=$(echo $ORDERED | jq -r '.data[0].order_position')
SECOND_ORDER=$(echo $ORDERED | jq -r '.data[1].order_position')

if [ "$FIRST_ORDER" -le "$SECOND_ORDER" ]; then
    print_result 0 "Order by order_position working"
else
    print_result 1 "Order by order_position not working" "Expected ascending order"
fi

# Step 13: Test search in multiple fields
echo -e "\n${YELLOW}Step 13: Testing search in multiple fields...${NC}"

SEARCH_MULTI=$(curl -s -X GET "$BASE_URL/admin/partners?search=organization" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_MULTI | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Multi-field search working"
else
    print_result 1 "Multi-field search not working"
fi

# Cleanup: Delete test partners
echo -e "\n${YELLOW}Cleanup: Deleting test partners...${NC}"

if [ "$PARTNER1_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/partners/$PARTNER1_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted partner 1"
fi

if [ "$PARTNER2_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/partners/$PARTNER2_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted partner 2"
fi

if [ "$PARTNER3_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/partners/$PARTNER3_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted partner 3"
fi

if [ "$PARTNER4_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/partners/$PARTNER4_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted partner 4"
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
