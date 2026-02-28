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

echo -e "${YELLOW}=== FAQs Search & Pagination Test ===${NC}\n"

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

# Step 2: Create test FAQs
echo -e "\n${YELLOW}Step 2: Creating test FAQs...${NC}"

# Create FAQ 1 (active)
FAQ1=$(curl -s -X POST "$BASE_URL/admin/faqs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "question": "How can I make a donation?",
        "answer": "You can make a donation through our website by clicking the Donate button, or by contacting us directly for bank transfer details.",
        "category": "Donations",
        "order_position": 1,
        "is_active": true
    }')

FAQ1_ID=$(echo $FAQ1 | jq -r '.data.id')
if [ "$FAQ1_ID" != "null" ]; then
    print_result 0 "Created test FAQ 1 (Donation question)"
else
    print_result 1 "Failed to create FAQ 1"
fi

# Create FAQ 2 (active)
FAQ2=$(curl -s -X POST "$BASE_URL/admin/faqs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "question": "What programs do you offer?",
        "answer": "We offer various environmental conservation programs including reforestation, wildlife protection, and community education initiatives.",
        "category": "Programs",
        "order_position": 2,
        "is_active": true
    }')

FAQ2_ID=$(echo $FAQ2 | jq -r '.data.id')
if [ "$FAQ2_ID" != "null" ]; then
    print_result 0 "Created test FAQ 2 (Programs question)"
else
    print_result 1 "Failed to create FAQ 2"
fi

# Create FAQ 3 (active)
FAQ3=$(curl -s -X POST "$BASE_URL/admin/faqs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "question": "How can I volunteer?",
        "answer": "We welcome volunteers! Please fill out our volunteer application form on the website or contact our volunteer coordinator.",
        "category": "Volunteering",
        "order_position": 3,
        "is_active": true
    }')

FAQ3_ID=$(echo $FAQ3 | jq -r '.data.id')
if [ "$FAQ3_ID" != "null" ]; then
    print_result 0 "Created test FAQ 3 (Volunteer question)"
else
    print_result 1 "Failed to create FAQ 3"
fi

# Create FAQ 4 (inactive)
FAQ4=$(curl -s -X POST "$BASE_URL/admin/faqs" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "question": "What is your mission?",
        "answer": "Our mission is to protect and preserve the environment through sustainable conservation practices and community engagement.",
        "category": "General",
        "order_position": 4,
        "is_active": false
    }')

FAQ4_ID=$(echo $FAQ4 | jq -r '.data.id')
if [ "$FAQ4_ID" != "null" ]; then
    print_result 0 "Created test FAQ 4 (Mission question - inactive)"
else
    print_result 1 "Failed to create FAQ 4"
fi

# Step 3: Test pagination
echo -e "\n${YELLOW}Step 3: Testing pagination...${NC}"

PAGINATED=$(curl -s -X GET "$BASE_URL/admin/faqs?page=1&limit=2" \
    -H "Authorization: Bearer $TOKEN")

ITEM_COUNT=$(echo $PAGINATED | jq '.data | length')
CURRENT_PAGE=$(echo $PAGINATED | jq -r '.pagination.currentPage')
ITEMS_PER_PAGE=$(echo $PAGINATED | jq -r '.pagination.itemsPerPage')

if [ "$ITEM_COUNT" -eq 2 ] && [ "$CURRENT_PAGE" -eq 1 ] && [ "$ITEMS_PER_PAGE" -eq 2 ]; then
    print_result 0 "Admin API pagination working (page 1, limit 2)"
else
    print_result 1 "Admin API pagination not working correctly" "Expected 2 items, got $ITEM_COUNT"
fi

# Step 4: Test search by question
echo -e "\n${YELLOW}Step 4: Testing search by question...${NC}"

SEARCH_QUESTION=$(curl -s -X GET "$BASE_URL/admin/faqs?search=donation" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_QUESTION | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by question working"
else
    print_result 1 "Admin API search by question not working" "No results found"
fi

# Step 5: Test search by answer
echo -e "\n${YELLOW}Step 5: Testing search by answer...${NC}"

SEARCH_ANSWER=$(curl -s -X GET "$BASE_URL/admin/faqs?search=reforestation" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_ANSWER | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by answer working"
else
    print_result 1 "Admin API search by answer not working" "No results found"
fi

# Step 6: Test search by category
echo -e "\n${YELLOW}Step 6: Testing search by category...${NC}"

SEARCH_CATEGORY=$(curl -s -X GET "$BASE_URL/admin/faqs?search=Volunteering" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_CATEGORY | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Admin API search by category working"
else
    print_result 1 "Admin API search by category not working" "No results found"
fi

# Step 7: Test filter by category
echo -e "\n${YELLOW}Step 7: Testing filter by category...${NC}"

FILTER_CATEGORY=$(curl -s -X GET "$BASE_URL/admin/faqs?category=Programs" \
    -H "Authorization: Bearer $TOKEN")

FILTER_COUNT=$(echo $FILTER_CATEGORY | jq '.data | length')

if [ "$FILTER_COUNT" -ge 1 ]; then
    print_result 0 "Admin API filter by category working"
else
    print_result 1 "Admin API filter by category not working" "No results found"
fi

# Step 8: Test search with pagination
echo -e "\n${YELLOW}Step 8: Testing search with pagination...${NC}"

SEARCH_PAGINATED=$(curl -s -X GET "$BASE_URL/admin/faqs?search=environmental&page=1&limit=5" \
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

ALL_ITEMS=$(curl -s -X GET "$BASE_URL/admin/faqs?page=1&limit=20" \
    -H "Authorization: Bearer $TOKEN")

TOTAL_ITEMS=$(echo $ALL_ITEMS | jq -r '.pagination.totalItems')

if [ "$TOTAL_ITEMS" -ge 4 ]; then
    print_result 0 "Admin API includes inactive items"
else
    print_result 1 "Admin API does not include inactive items" "Expected at least 4 items, got $TOTAL_ITEMS"
fi

# Step 10: Test pagination metadata
echo -e "\n${YELLOW}Step 10: Testing pagination metadata...${NC}"

METADATA=$(curl -s -X GET "$BASE_URL/admin/faqs?page=1&limit=2" \
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

SEARCH_UPPER=$(curl -s -X GET "$BASE_URL/admin/faqs?search=VOLUNTEER" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_UPPER | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Case insensitive search working"
else
    print_result 1 "Case insensitive search not working" "No results found with uppercase search"
fi

# Step 12: Test partial word search
echo -e "\n${YELLOW}Step 12: Testing partial word search...${NC}"

SEARCH_PARTIAL=$(curl -s -X GET "$BASE_URL/admin/faqs?search=conserv" \
    -H "Authorization: Bearer $TOKEN")

SEARCH_COUNT=$(echo $SEARCH_PARTIAL | jq '.data | length')

if [ "$SEARCH_COUNT" -ge 1 ]; then
    print_result 0 "Partial word search working"
else
    print_result 1 "Partial word search not working" "No results found with partial search"
fi

# Step 13: Test order by order_position
echo -e "\n${YELLOW}Step 13: Testing order by order_position...${NC}"

ORDERED=$(curl -s -X GET "$BASE_URL/admin/faqs?page=1&limit=10" \
    -H "Authorization: Bearer $TOKEN")

FIRST_ORDER=$(echo $ORDERED | jq -r '.data[0].order_position')
SECOND_ORDER=$(echo $ORDERED | jq -r '.data[1].order_position')

if [ "$FIRST_ORDER" -le "$SECOND_ORDER" ]; then
    print_result 0 "Order by order_position working"
else
    print_result 1 "Order by order_position not working" "Expected ascending order"
fi

# Step 14: Test combined search and category filter
echo -e "\n${YELLOW}Step 14: Testing combined search and category filter...${NC}"

COMBINED=$(curl -s -X GET "$BASE_URL/admin/faqs?search=programs&category=Programs" \
    -H "Authorization: Bearer $TOKEN")

COMBINED_COUNT=$(echo $COMBINED | jq '.data | length')

if [ "$COMBINED_COUNT" -ge 1 ]; then
    print_result 0 "Combined search and category filter working"
else
    print_result 1 "Combined search and category filter not working"
fi

# Step 15: Test all=true parameter (no pagination)
echo -e "\n${YELLOW}Step 15: Testing all=true parameter...${NC}"

ALL_RESPONSE=$(curl -s -X GET "$BASE_URL/admin/faqs?all=true" \
    -H "Authorization: Bearer $TOKEN")

HAS_PAGINATION=$(echo $ALL_RESPONSE | jq -r '.pagination')

if [ "$HAS_PAGINATION" == "null" ]; then
    print_result 0 "all=true parameter working (no pagination)"
else
    print_result 1 "all=true parameter not working" "Pagination should be null"
fi

# Cleanup: Delete test FAQs
echo -e "\n${YELLOW}Cleanup: Deleting test FAQs...${NC}"

if [ "$FAQ1_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/faqs/$FAQ1_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted FAQ 1"
fi

if [ "$FAQ2_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/faqs/$FAQ2_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted FAQ 2"
fi

if [ "$FAQ3_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/faqs/$FAQ3_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted FAQ 3"
fi

if [ "$FAQ4_ID" != "null" ]; then
    curl -s -X DELETE "$BASE_URL/admin/faqs/$FAQ4_ID" \
        -H "Authorization: Bearer $TOKEN" > /dev/null
    echo "Deleted FAQ 4"
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
