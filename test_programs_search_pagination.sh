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

echo -e "${YELLOW}=== Programs Search & Pagination Test ===${NC}\n"

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

# Step 2: Get or create a program category for testing
echo -e "\n${YELLOW}Step 2: Setting up test category...${NC}"

# Try to get existing categories
CATEGORIES=$(curl -s -X GET "$BASE_URL/admin/program-categories?page=1&limit=1" \
    -H "Authorization: Bearer $TOKEN")

CATEGORY_ID=$(echo $CATEGORIES | jq -r '.data[0].id')

if [ "$CATEGORY_ID" == "null" ] || [ -z "$CATEGORY_ID" ]; then
    # Create a test category
    CATEGORY=$(curl -s -X POST "$BASE_URL/admin/program-categories" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{
            "name": "Test Category",
            "slug": "test-category-programs",
            "description": "Test category for programs",
            "is_active": true
        }')
    CATEGORY_ID=$(echo $CATEGORY | jq -r '.data.id')
    CREATED_CATEGORY=true
    echo "Created test category with ID: $CATEGORY_ID"
else
    CREATED_CATEGORY=false
    echo "Using existing category with ID: $CATEGORY_ID"
fi

# Step 3: Create test programs
echo -e "\n${YELLOW}Step 3: Creating test programs...${NC}"

# Create program 1 (active)
PROGRAM1=$(curl -s -X POST "$BASE_URL/admin/programs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
        \"name\": \"Environmental Education Program\",
        \"description\": \"Comprehensive environmental education initiative for schools and communities focusing on conservation.\",
        \"category_id\": $CATEGORY_ID,
        \"is_highlighted\": true,
        \"order_position\": 1,
        \"is_active\": true
    }")

PROGRAM1_ID=$(echo $PROGRAM1 | jq -r '.data.id')
if [ "$PROGRAM1_ID" != "null" ]; then
    print_result 0 "Created test program 1 (Environmental Education)"
else
    print_result 1 "Failed to create program 1"
fi

# Create program 2 (active)
PROGRAM2=$(curl -s -X POST "$BASE_URL/admin/programs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
        \"name\": \"Community Reforestation\",
        \"description\": \"Large-scale tree planting and forest restoration program involving local communities.\",
        \"category_id\": $CATEGORY_ID,
        \"order_position\": 2,
        \"is_active\": true
    }")

PROGRAM2_ID=$(echo $PROGRAM2 | jq -r '.data.id')
if [ "$PROGRAM2_ID" != "null" ]; then
    print_result 0 "Created test program 2 (Community Reforestation)"
else
    print_result 1 "Failed to create program 2"
fi

# Create program 3 (active)
PROGRAM3=$(curl -s -X POST "$BASE_URL/admin/programs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
        \"name\": \"Wildlife Conservation Initiative\",
        \"description\": \"Protecting endangered species and their habitats through research and community engagement.\",
        \"category_id\": $CATEGORY_ID,
        \"order_position\": 3,
        \"is_active\": true
    }")

PROGRAM3_ID=$(echo $PROGRAM3 | jq -r '.data.id')
if [ "$PROGRAM3_ID" != "null" ]; then
    print_result 0 "Created test program 3 (Wildlife Conservation)"
else
    print_result 1 "Failed to create program 3"
fi

# Create program 4 (inactive)
PROGRAM4=$(curl -s -X POST "$BASE_URL/admin/programs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
        \"name\": \"Sustainable Agriculture Training\",
        \"description\": \"Training farmers in sustainable agricultural practices and organic farming methods.\",
        \"category_id\": $CATEGORY_ID,
        \"order_position\": 4,
        \"is_active\": false
    }")

PROGRAM4_ID=$(echo $PROGRAM4 | jq -r '.data.id')
if [ "$PROGRAM4_ID" != "null" ]; then
    print_result 0 "Created test program 4 (Sustainable Agriculture - inactive)"
else
    print_result 1 "Failed to create program 4"
fi

# Step 4: Test pagination
echo -e "\n${YELLOW}Step 4: Testing pagination...${NC}"

PAGINATED=$(curl -s -X GET "$BASE_URL/admin/programs?page=1&limit=2" \
    -H "Authorization: Bearer $TOKEN")

ITEM_COUNT=$(echo $PAGINATED | jq '.data | length')
CURRENT_PAGE=$(echo $PAGINATED | jq -r '.pagination.currentPage')
ITEMS_PER_PAGE=$(echo $PAGINATED | jq -r '.pagination.itemsPerPage')

if [ "$ITEM_COUNT" -eq 2 ] && [ "$CURRENT_PAGE" -eq 1 ] && [ "$ITEMS_PER_PAGE" -eq 2 ]; then
    print_result 0 "Admin API pagination working (page 1, limit 2)"
else
    print_result 1 "Admin API pagination not working correctly" "Expected 2 items, got $ITEM_COUNT"
fi

# Step 5: Test search by name
echo -e "\n${YELLOW}Step 5: Testing search by name...${NC}"

SEARCH_NAME=$(curl -s -X GET "$BASE_URL/admin/programs?search=Environmental%20Education" \
    -H "Authorization: Bearer $TOKEN")

FOUND_PROGRAM=$(echo $SEARCH_NAME | jq -r '.data[] | select(.name == "Environmental Education Program") | .name')

if [ "$FOUND_PROGRAM" == "Environmental Education Program" ]; then
    print_result 0 "Admin API search by name working"
else
    print_result 1 "Admin API search by name not working" "Could not find 'Environmental Education Program'"
fi

# Step 6: Test search by description
echo -e "\n${YELLOW}Step 6: Testing search by description...${NC}"

SEARCH_DESC=$(curl -s -X GET "$BASE_URL/admin/programs?search=communities" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_DESC | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by description working"
else
    print_result 1 "Admin API search by description not working" "No results found"
fi

# Step 7: Test search by category name
echo -e "\n${YELLOW}Step 7: Testing search by category name...${NC}"

SEARCH_CATEGORY=$(curl -s -X GET "$BASE_URL/admin/programs?search=Test%20Category" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_CATEGORY | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by category name working"
else
    print_result 1 "Admin API search by category name not working"
fi

# Step 8: Test filter by category_id
echo -e "\n${YELLOW}Step 8: Testing filter by category_id...${NC}"

FILTER_CATEGORY=$(curl -s -X GET "$BASE_URL/admin/programs?category_id=$CATEGORY_ID" \
    -H "Authorization: Bearer $TOKEN")

FILTER_COUNT=$(echo $FILTER_CATEGORY | jq '.data | length')

if [ "$FILTER_COUNT" -ge 4 ]; then
    print_result 0 "Admin API filter by category_id working"
else
    print_result 1 "Admin API filter by category_id not working" "Expected at least 4 items, got $FILTER_COUNT"
fi

# Step 9: Test search with pagination
echo -e "\n${YELLOW}Step 9: Testing search with pagination...${NC}"

SEARCH_PAGINATED=$(curl -s -X GET "$BASE_URL/admin/programs?search=conservation&page=1&limit=5" \
    -H "Authorization: Bearer $TOKEN")

SUCCESS=$(echo $SEARCH_PAGINATED | jq -r '.success')
HAS_PAGINATION=$(echo $SEARCH_PAGINATED | jq -r '.pagination')

if [ "$SUCCESS" == "true" ] && [ "$HAS_PAGINATION" != "null" ]; then
    print_result 0 "Admin API search with pagination working"
else
    print_result 1 "Admin API search with pagination not working"
fi

# Step 10: Test that admin API includes inactive items
echo -e "\n${YELLOW}Step 10: Testing admin API includes inactive items...${NC}"

ALL_ITEMS=$(curl -s -X GET "$BASE_URL/admin/programs?page=1&limit=20" \
    -H "Authorization: Bearer $TOKEN")

TOTAL_ITEMS=$(echo $ALL_ITEMS | jq -r '.pagination.totalItems')

if [ "$TOTAL_ITEMS" -ge 4 ]; then
    print_result 0 "Admin API includes inactive items"
else
    print_result 1 "Admin API does not include inactive items" "Expected at least 4 items, got $TOTAL_ITEMS"
fi

# Step 11: Test pagination metadata
echo -e "\n${YELLOW}Step 11: Testing pagination metadata...${NC}"

METADATA=$(curl -s -X GET "$BASE_URL/admin/programs?page=1&limit=2" \
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

# Step 12: Test case insensitive search
echo -e "\n${YELLOW}Step 12: Testing case insensitive search...${NC}"

SEARCH_UPPER=$(curl -s -X GET "$BASE_URL/admin/programs?search=EDUCATION" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_UPPER | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Case insensitive search working"
else
    print_result 1 "Case insensitive search not working" "No results found with uppercase search"
fi

# Step 13: Test partial word search
echo -e "\n${YELLOW}Step 13: Testing partial word search...${NC}"

SEARCH_PARTIAL=$(curl -s -X GET "$BASE_URL/admin/programs?search=Educat" \
    -H "Authorization: Bearer $TOKEN")

FOUND_PROGRAM=$(echo $SEARCH_PARTIAL | jq -r '.data[] | select(.name == "Environmental Education Program") | .name')

if [ "$FOUND_PROGRAM" == "Environmental Education Program" ]; then
    print_result 0 "Partial word search working"
else
    print_result 1 "Partial word search not working"
fi

# Step 14: Test order by order_position
echo -e "\n${YELLOW}Step 14: Testing order by order_position...${NC}"

ORDERED=$(curl -s -X GET "$BASE_URL/admin/programs?page=1&limit=10" \
    -H "Authorization: Bearer $TOKEN")

FIRST_ORDER=$(echo $ORDERED | jq -r '.data[0].order_position')
SECOND_ORDER=$(echo $ORDERED | jq -r '.data[1].order_position')

if [ "$FIRST_ORDER" -le "$SECOND_ORDER" ]; then
    print_result 0 "Order by order_position working"
else
    print_result 1 "Order by order_position not working" "Expected ascending order"
fi

# Step 15: Test combined search and category filter
echo -e "\n${YELLOW}Step 15: Testing combined search and category filter...${NC}"

COMBINED=$(curl -s -X GET "$BASE_URL/admin/programs?search=conservation&category_id=$CATEGORY_ID" \
    -H "Authorization: Bearer $TOKEN")

COMBINED_COUNT=$(echo $COMBINED | jq '.data | length')

if [ "$COMBINED_COUNT" -ge 1 ]; then
    print_result 0 "Combined search and category filter working"
else
    print_result 1 "Combined search and category filter not working"
fi

# Cleanup: Delete test programs
echo -e "\n${YELLOW}Cleanup: Deleting test programs...${NC}"

if [ "$PROGRAM1_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/programs/$PROGRAM1_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted program 1"
fi

if [ "$PROGRAM2_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/programs/$PROGRAM2_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted program 2"
fi

if [ "$PROGRAM3_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/programs/$PROGRAM3_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted program 3"
fi

if [ "$PROGRAM4_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/programs/$PROGRAM4_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted program 4"
fi

# Delete test category if we created it
if [ "$CREATED_CATEGORY" == "true" ] && [ "$CATEGORY_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/program-categories/$CATEGORY_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted test category"
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
