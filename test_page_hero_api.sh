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
echo "  PAGE HERO SETTINGS API UNIT TEST"
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

echo "=== PUBLIC PAGE HERO TESTS ==="
echo ""

# Test 1
echo "Test 1: GET /api/pages/articles/info"
RESPONSE=$(curl -s "$BASE_URL/api/pages/articles/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$TITLE" ]; then
    print_result "Get articles page hero" "PASS" "Title: $TITLE"
else
    print_result "Get articles page hero" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 2
echo "Test 2: Verify page hero has required fields (title, sub_title, image_url)"
RESPONSE=$(curl -s "$BASE_URL/api/pages/articles/info")
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
SUB_TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('sub_title', ''))" 2>/dev/null)
IMAGE_URL=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('image_url', ''))" 2>/dev/null)

if [ ! -z "$TITLE" ] && [ ! -z "$SUB_TITLE" ] && [ ! -z "$IMAGE_URL" ]; then
    print_result "Page hero has required fields" "PASS" "All fields present"
else
    print_result "Page hero has required fields" "FAIL" "Missing fields"
fi
echo ""

# Test 3
echo "Test 3: GET /api/pages/awards/info"
RESPONSE=$(curl -s "$BASE_URL/api/pages/awards/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$TITLE" ]; then
    print_result "Get awards page hero" "PASS" "Title: $TITLE"
else
    print_result "Get awards page hero" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 4
echo "Test 4: GET /api/pages/gallery/info"
RESPONSE=$(curl -s "$BASE_URL/api/pages/gallery/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$TITLE" ]; then
    print_result "Get gallery page hero" "PASS" "Title: $TITLE"
else
    print_result "Get gallery page hero" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 5
echo "Test 5: GET /api/pages/programs/info"
RESPONSE=$(curl -s "$BASE_URL/api/pages/programs/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ ! -z "$TITLE" ]; then
    print_result "Get programs page hero" "PASS" "Title: $TITLE"
else
    print_result "Get programs page hero" "FAIL" "Success: $SUCCESS"
fi
echo ""

# Test 6
echo "Test 6: GET /api/pages/nonexistent/info (Invalid slug)"
RESPONSE=$(curl -s "$BASE_URL/api/pages/nonexistent/info")
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
DATA=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('data', {})))" 2>/dev/null)

if [ "$SUCCESS" = "True" ] && [ "$DATA" = "0" ]; then
    print_result "Invalid slug returns empty data" "PASS" "Empty object returned"
else
    print_result "Invalid slug returns empty data" "FAIL" "Unexpected response"
fi
echo ""

# Test 7
echo "Test 7: Verify all static pages have hero settings"
PAGES=("articles" "awards" "merchandise" "gallery" "leadership" "contact" "history" "vision-mission")
ALL_EXIST=true

for page in "${PAGES[@]}"; do
    RESPONSE=$(curl -s "$BASE_URL/api/pages/$page/info")
    TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    if [ -z "$TITLE" ]; then
        ALL_EXIST=false
        break
    fi
done

if [ "$ALL_EXIST" = true ]; then
    print_result "All static pages have hero settings" "PASS" "All 8 pages configured"
else
    print_result "All static pages have hero settings" "FAIL" "Some pages missing"
fi
echo ""

if [ ! -z "$TOKEN" ]; then
    echo "=== ADMIN PAGE HERO TESTS ==="
    echo ""

    # Test 8
    echo "Test 8: GET /api/admin/pages/articles (Admin)"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/pages/articles" -H "Authorization: Bearer $TOKEN")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    
    if [ "$SUCCESS" = "True" ]; then
        print_result "Get page settings (admin)" "PASS" "Retrieved successfully"
    else
        print_result "Get page settings (admin)" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 9
    echo "Test 9: PUT /api/admin/pages/merchandise (Update hero)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/merchandise" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Test Merchandise Title",
        "sub_title": "Test Subtitle",
        "image_url": "https://images.unsplash.com/photo-test?w=1200"
      }')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    UPDATED_TITLE=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    
    if [ "$SUCCESS" = "True" ] && [ "$UPDATED_TITLE" = "Test Merchandise Title" ]; then
        print_result "Update page hero" "PASS" "Updated successfully"
    else
        print_result "Update page hero" "FAIL" "Success: $SUCCESS, Title: $UPDATED_TITLE"
    fi
    echo ""

    # Test 10
    echo "Test 10: Verify update reflected in public endpoint"
    RESPONSE=$(curl -s "$BASE_URL/api/pages/merchandise/info")
    TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    SUB_TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('sub_title', ''))" 2>/dev/null)
    
    if [ "$TITLE" = "Test Merchandise Title" ] && [ "$SUB_TITLE" = "Test Subtitle" ]; then
        print_result "Update reflected in public endpoint" "PASS" "Data synchronized"
    else
        print_result "Update reflected in public endpoint" "FAIL" "Data not synchronized"
    fi
    echo ""

    # Test 11
    echo "Test 11: PUT /api/admin/pages/merchandise (Partial update)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/merchandise" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"sub_title": "Updated Subtitle Only"}')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    TITLE=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    SUB_TITLE=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('sub_title', ''))" 2>/dev/null)
    
    if [ "$SUCCESS" = "True" ] && [ "$TITLE" = "Test Merchandise Title" ] && [ "$SUB_TITLE" = "Updated Subtitle Only" ]; then
        print_result "Partial update preserves other fields" "PASS" "Only subtitle changed"
    else
        print_result "Partial update preserves other fields" "FAIL" "Fields not preserved"
    fi
    echo ""

    # Test 12
    echo "Test 12: PUT /api/admin/pages/contact (Update existing page)"
    CREATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/contact" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Updated Contact Title",
        "sub_title": "Updated Contact Subtitle",
        "image_url": "https://images.unsplash.com/photo-updated?w=1200"
      }')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    TITLE=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    
    if [ "$SUCCESS" = "True" ] && [ "$TITLE" = "Updated Contact Title" ]; then
        print_result "Update existing page hero" "PASS" "Updated successfully"
    else
        print_result "Update existing page hero" "FAIL" "Success: $SUCCESS"
    fi
    echo ""

    # Test 13
    echo "Test 13: Verify contact page update reflected in public endpoint"
    RESPONSE=$(curl -s "$BASE_URL/api/pages/contact/info")
    TITLE=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('title', ''))" 2>/dev/null)
    
    if [ "$TITLE" = "Updated Contact Title" ]; then
        print_result "Contact page update accessible publicly" "PASS" "Update reflected"
    else
        print_result "Contact page update accessible publicly" "FAIL" "Update not reflected"
    fi
    echo ""

    # Test 14
    echo "Test 14: PUT /api/admin/pages/newpage (Attempt to create non-existent page)"
    CREATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/newpage" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"title":"New Page","sub_title":"Test"}')

    SUCCESS=$(echo "$CREATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    
    if [ "$SUCCESS" = "False" ]; then
        print_result "Cannot create non-static pages" "PASS" "Correctly rejected"
    else
        print_result "Cannot create non-static pages" "FAIL" "Should reject non-static pages"
    fi
    echo ""

    # Test 15
    echo "Test 15: PUT /api/admin/pages/articles (Update with all fields)"
    UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/admin/pages/articles" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Complete Update Title",
        "sub_title": "Complete Update Subtitle",
        "description": "Complete description",
        "image_url": "https://images.unsplash.com/photo-complete?w=1200",
        "meta_title": "Meta Title",
        "meta_description": "Meta Description"
      }')

    SUCCESS=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)
    META_TITLE=$(echo "$UPDATE_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('data', {}).get('meta_title', ''))" 2>/dev/null)
    
    if [ "$SUCCESS" = "True" ] && [ "$META_TITLE" = "Meta Title" ]; then
        print_result "Update with all fields" "PASS" "All fields updated"
    else
        print_result "Update with all fields" "FAIL" "Not all fields updated"
    fi
    echo ""

    # Test 16
    echo "Test 16: GET /api/admin/pages/articles without authentication"
    RESPONSE=$(curl -s "$BASE_URL/api/admin/pages/articles")
    SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('success', False))" 2>/dev/null)

    if [ "$SUCCESS" = "False" ]; then
        print_result "Authentication required for admin" "PASS" "Correctly rejected"
    else
        print_result "Authentication required for admin" "FAIL" "Should require authentication"
    fi
    echo ""

    # Cleanup - restore original data
    echo "Cleaning up test data..."
    curl -s -X PUT "$BASE_URL/api/admin/pages/merchandise" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Eco-Friendly Merchandise",
        "sub_title": "Support Our Mission",
        "image_url": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200"
      }' > /dev/null
    
    curl -s -X PUT "$BASE_URL/api/admin/pages/articles" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Articles & News",
        "sub_title": "Latest Updates and Stories",
        "image_url": "https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200"
      }' > /dev/null
    
    curl -s -X PUT "$BASE_URL/api/admin/pages/contact" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "title": "Contact Us",
        "sub_title": "Get in Touch",
        "image_url": "https://images.unsplash.com/photo-1423666639041-f56000c27a9a?w=1200"
      }' > /dev/null
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
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
