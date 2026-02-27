#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Impact Section API${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Get token
echo -e "${BLUE}Getting authentication token...${NC}"
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo -e "${RED}✗ Failed to get token${NC}\n"
    exit 1
fi
echo -e "${GREEN}✓ Token obtained${NC}\n"

# Test 1: Get public impact endpoint
echo -e "${BLUE}Test 1: GET /api/impact (Public)${NC}"
RESPONSE=$(curl -s http://localhost:3000/api/impact)
HAS_SECTION=$(echo "$RESPONSE" | jq -e '.data.section != null')
HAS_ITEMS=$(echo "$RESPONSE" | jq -e '.data.items | length > 0')

if [ "$HAS_SECTION" == "true" ] && [ "$HAS_ITEMS" == "true" ]; then
    echo -e "${GREEN}✓ Impact endpoint returns section and items${NC}"
    echo "  Section title: $(echo "$RESPONSE" | jq -r '.data.section.title')"
    echo "  Items count: $(echo "$RESPONSE" | jq -r '.data.items | length')"
else
    echo -e "${RED}✗ Impact endpoint structure incorrect${NC}"
fi
echo ""

# Test 2: Get impact section settings (admin)
echo -e "${BLUE}Test 2: GET /api/admin/homepage/impact-section${NC}"
SECTION=$(curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/homepage/impact-section)
SECTION_TITLE=$(echo "$SECTION" | jq -r '.data.title')

if [ ! -z "$SECTION_TITLE" ] && [ "$SECTION_TITLE" != "null" ]; then
    echo -e "${GREEN}✓ Section settings retrieved${NC}"
    echo "  Title: $SECTION_TITLE"
    echo "  Subtitle: $(echo "$SECTION" | jq -r '.data.subtitle')"
else
    echo -e "${RED}✗ Failed to get section settings${NC}"
fi
echo ""

# Test 3: Get impact items (admin)
echo -e "${BLUE}Test 3: GET /api/admin/homepage/impact${NC}"
ITEMS=$(curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/homepage/impact)
ITEMS_COUNT=$(echo "$ITEMS" | jq -r '.data | length')

if [ "$ITEMS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Impact items retrieved${NC}"
    echo "  Items count: $ITEMS_COUNT"
else
    echo -e "${RED}✗ No impact items found${NC}"
fi
echo ""

# Test 4: Update section settings
echo -e "${BLUE}Test 4: PUT /api/admin/homepage/impact-section${NC}"
UPDATE=$(curl -s -X PUT http://localhost:3000/api/admin/homepage/impact-section \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Impact Title","subtitle":"Test subtitle"}')
UPDATED_TITLE=$(echo "$UPDATE" | jq -r '.data.title')

if [ "$UPDATED_TITLE" == "Test Impact Title" ]; then
    echo -e "${GREEN}✓ Section settings updated${NC}"
    echo "  New title: $UPDATED_TITLE"
else
    echo -e "${RED}✗ Failed to update section settings${NC}"
fi
echo ""

# Test 5: Verify public endpoint reflects changes
echo -e "${BLUE}Test 5: Verify changes in public endpoint${NC}"
PUBLIC=$(curl -s http://localhost:3000/api/impact)
PUBLIC_TITLE=$(echo "$PUBLIC" | jq -r '.data.section.title')

if [ "$PUBLIC_TITLE" == "Test Impact Title" ]; then
    echo -e "${GREEN}✓ Changes reflected in public endpoint${NC}"
else
    echo -e "${RED}✗ Changes not reflected${NC}"
fi
echo ""

# Restore original title
curl -s -X PUT http://localhost:3000/api/admin/homepage/impact-section \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Our Amazing Impact","subtitle":"Making a real difference in the world"}' > /dev/null

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Impact Section Tests Completed${NC}"
echo -e "${BLUE}========================================${NC}"
