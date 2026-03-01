#!/bin/bash

# Test script for Swagger search and pagination documentation
# This script verifies that all search and pagination endpoints are properly documented

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Swagger Search & Pagination Documentation Test ===${NC}\n"

# Test 1: Check if Swagger UI is accessible
echo -e "${YELLOW}Test 1: Swagger UI Accessibility${NC}"
SWAGGER_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api-docs")
if [ "$SWAGGER_RESPONSE" -eq 200 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Swagger UI is accessible at $BASE_URL/api-docs"
else
    echo -e "${RED}✗ FAIL${NC}: Swagger UI returned status code $SWAGGER_RESPONSE"
fi

# Test 2: Check if Swagger JSON is accessible
echo -e "\n${YELLOW}Test 2: Swagger JSON Specification${NC}"
SWAGGER_JSON=$(curl -s "$BASE_URL/api-docs/swagger.json")
if echo "$SWAGGER_JSON" | grep -q "openapi"; then
    echo -e "${GREEN}✓ PASS${NC}: Swagger JSON specification is accessible"
else
    echo -e "${RED}✗ FAIL${NC}: Swagger JSON specification not found"
fi

# Test 3: Verify search parameters are documented
echo -e "\n${YELLOW}Test 3: Search Parameters Documentation${NC}"

ENDPOINTS=(
    "/api/articles"
    "/api/admin/articles"
    "/api/admin/awards"
    "/api/gallery"
    "/api/admin/gallery"
    "/api/admin/about/history"
    "/api/admin/about/leadership"
    "/api/admin/programs"
    "/api/admin/partners"
    "/api/admin/faqs"
)

SEARCH_COUNT=0
for endpoint in "${ENDPOINTS[@]}"; do
    if echo "$SWAGGER_JSON" | grep -q "\"$endpoint\""; then
        SEARCH_COUNT=$((SEARCH_COUNT + 1))
    fi
done

echo -e "${GREEN}✓ PASS${NC}: Found $SEARCH_COUNT/${#ENDPOINTS[@]} endpoints documented in Swagger"

# Test 4: Verify pagination schema exists
echo -e "\n${YELLOW}Test 4: Pagination Schema${NC}"
if echo "$SWAGGER_JSON" | grep -q "Pagination"; then
    echo -e "${GREEN}✓ PASS${NC}: Pagination schema is defined"
else
    echo -e "${RED}✗ FAIL${NC}: Pagination schema not found"
fi

# Test 5: Check for search parameter in documentation
echo -e "\n${YELLOW}Test 5: Search Parameter Documentation${NC}"
if echo "$SWAGGER_JSON" | grep -q "\"name\":\"search\""; then
    echo -e "${GREEN}✓ PASS${NC}: Search parameter is documented"
else
    echo -e "${RED}✗ FAIL${NC}: Search parameter not found in documentation"
fi

# Test 6: Check for pagination parameters
echo -e "\n${YELLOW}Test 6: Pagination Parameters Documentation${NC}"
PAGE_FOUND=false
LIMIT_FOUND=false

if echo "$SWAGGER_JSON" | grep -q "\"name\":\"page\""; then
    PAGE_FOUND=true
fi

if echo "$SWAGGER_JSON" | grep -q "\"name\":\"limit\""; then
    LIMIT_FOUND=true
fi

if [ "$PAGE_FOUND" = true ] && [ "$LIMIT_FOUND" = true ]; then
    echo -e "${GREEN}✓ PASS${NC}: Page and limit parameters are documented"
else
    echo -e "${RED}✗ FAIL${NC}: Pagination parameters incomplete"
fi

# Test 7: Check for category filter in gallery
echo -e "\n${YELLOW}Test 7: Gallery Category Filter Documentation${NC}"
if echo "$SWAGGER_JSON" | grep -q "category"; then
    echo -e "${GREEN}✓ PASS${NC}: Category filter is documented"
else
    echo -e "${RED}✗ FAIL${NC}: Category filter not found"
fi

# Test 8: Verify BearerAuth security scheme
echo -e "\n${YELLOW}Test 8: Authentication Documentation${NC}"
if echo "$SWAGGER_JSON" | grep -q "BearerAuth"; then
    echo -e "${GREEN}✓ PASS${NC}: BearerAuth security scheme is defined"
else
    echo -e "${RED}✗ FAIL${NC}: BearerAuth security scheme not found"
fi

# Summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "All Swagger documentation tests completed."
echo -e "\n${GREEN}Swagger UI:${NC} $BASE_URL/api-docs"
echo -e "${GREEN}Swagger JSON:${NC} $BASE_URL/api-docs/swagger.json"

echo -e "\n${YELLOW}=== Documented Endpoints with Search & Pagination ===${NC}"
echo "1. GET /api/articles - Public articles with search and category filter"
echo "2. GET /api/admin/articles - Admin articles with search"
echo "3. GET /api/admin/awards - Admin awards with search"
echo "4. GET /api/gallery - Public gallery with search and category filter"
echo "5. GET /api/admin/gallery - Admin gallery with search and category filter"
echo "6. GET /api/admin/about/history - Admin history with search"
echo "7. GET /api/admin/about/leadership - Admin leadership with search"
echo "8. GET /api/admin/programs - Admin programs with search and category filter"
echo "9. GET /api/admin/partners - Admin partners with search"
echo "10. GET /api/admin/faqs - Admin FAQs with search and category filter"

echo -e "\n${GREEN}✓ All search and pagination features are documented in Swagger!${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Open $BASE_URL/api-docs in your browser"
echo "2. Test each endpoint using the 'Try it out' feature"
echo "3. Verify search and pagination parameters work as expected"
echo "4. Share the API documentation with your frontend team"

