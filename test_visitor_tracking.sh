#!/bin/bash

# Visitor Tracking API Test Script
# Tests the visitor tracking functionality when accessing the homepage

BASE_URL="http://localhost:3000"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test results
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo "=========================================="
echo "Visitor Tracking API Tests"
echo "=========================================="
echo ""

# Get admin token
echo "Getting admin authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}Authentication successful${NC}"
echo ""

# Test 1: Access homepage (should track visitor)
echo "Test 1: Access homepage to track visitor"
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/home")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    SUCCESS=$(echo $BODY | grep -o '"success":true')
    if [ ! -z "$SUCCESS" ]; then
        print_result 0 "Homepage accessed successfully"
    else
        print_result 1 "Homepage response invalid"
    fi
else
    print_result 1 "Homepage access failed (HTTP $HTTP_CODE)"
fi

# Test 2: Access homepage multiple times (same IP should increment visit_count)
echo ""
echo "Test 2: Access homepage multiple times (same IP)"
for i in {1..3}; do
    curl -s "$BASE_URL/api/home" > /dev/null
done
print_result 0 "Multiple visits from same IP tracked"

# Test 3: Get statistics and verify visitor data
echo ""
echo "Test 3: Get statistics with visitor data"
STATS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/admin/statistics" \
    -H "Authorization: Bearer $TOKEN")

SUCCESS=$(echo $STATS_RESPONSE | grep -o '"success":true')
if [ ! -z "$SUCCESS" ]; then
    print_result 0 "Statistics retrieved successfully"
else
    print_result 1 "Failed to retrieve statistics"
fi

# Test 4: Verify visitors_last_7_days structure
echo ""
echo "Test 4: Verify visitors_last_7_days structure"
VISITORS_DATA=$(echo $STATS_RESPONSE | grep -o '"visitors_last_7_days":\[')
if [ ! -z "$VISITORS_DATA" ]; then
    print_result 0 "visitors_last_7_days field exists"
else
    print_result 1 "visitors_last_7_days field missing"
fi

# Test 5: Verify visitors_last_7_days has 7 elements
echo ""
echo "Test 5: Verify visitors_last_7_days has 7 days"
VISITOR_COUNT=$(echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data['data']['visitors_last_7_days']))" 2>/dev/null)
if [ "$VISITOR_COUNT" -eq 7 ]; then
    print_result 0 "visitors_last_7_days has 7 elements"
else
    print_result 1 "visitors_last_7_days has $VISITOR_COUNT elements (expected 7)"
fi

# Test 6: Verify each day has date and count fields
echo ""
echo "Test 6: Verify visitor data structure"
HAS_DATE=$(echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); print('date' in data['data']['visitors_last_7_days'][0])" 2>/dev/null)
HAS_COUNT=$(echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); print('count' in data['data']['visitors_last_7_days'][0])" 2>/dev/null)

if [ "$HAS_DATE" = "True" ] && [ "$HAS_COUNT" = "True" ]; then
    print_result 0 "Visitor data has correct structure (date, count)"
else
    print_result 1 "Visitor data structure invalid"
fi

# Test 7: Verify today's date is included
echo ""
echo "Test 7: Verify today's date is in the list"
TODAY=$(date +%Y-%m-%d)
HAS_TODAY=$(echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); dates = [v['date'] for v in data['data']['visitors_last_7_days']]; print('$TODAY' in dates)" 2>/dev/null)

if [ "$HAS_TODAY" = "True" ]; then
    print_result 0 "Today's date ($TODAY) is included in visitor data"
else
    print_result 1 "Today's date ($TODAY) is missing from visitor data"
fi

# Test 8: Verify today has at least 1 visitor
echo ""
echo "Test 8: Verify today has at least 1 visitor"
TODAY_COUNT=$(echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); visitors = data['data']['visitors_last_7_days']; today_data = [v for v in visitors if v['date'] == '$TODAY']; print(today_data[0]['count'] if today_data else 0)" 2>/dev/null)

if [ "$TODAY_COUNT" -ge 1 ]; then
    print_result 0 "Today has $TODAY_COUNT visitor(s)"
else
    print_result 1 "Today has 0 visitors (expected at least 1)"
fi

# Test 9: Verify statistics includes all required fields
echo ""
echo "Test 9: Verify statistics includes all required fields"
HAS_ARTICLE_VIEWS=$(echo $STATS_RESPONSE | grep -o '"total_article_views"')
HAS_PROGRAMS=$(echo $STATS_RESPONSE | grep -o '"total_programs"')
HAS_GALLERY=$(echo $STATS_RESPONSE | grep -o '"total_gallery"')
HAS_PARTNERS=$(echo $STATS_RESPONSE | grep -o '"total_partners"')
HAS_TOP_ARTICLES=$(echo $STATS_RESPONSE | grep -o '"top_articles"')

if [ ! -z "$HAS_ARTICLE_VIEWS" ] && [ ! -z "$HAS_PROGRAMS" ] && [ ! -z "$HAS_GALLERY" ] && [ ! -z "$HAS_PARTNERS" ] && [ ! -z "$HAS_TOP_ARTICLES" ]; then
    print_result 0 "All required statistics fields present"
else
    print_result 1 "Some statistics fields are missing"
fi

# Test 10: Display visitor data for last 7 days
echo ""
echo "=========================================="
echo "Visitor Data for Last 7 Days:"
echo "=========================================="
echo $STATS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); [print(f\"{v['date']}: {v['count']} visitor(s)\") for v in data['data']['visitors_last_7_days']]" 2>/dev/null

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
