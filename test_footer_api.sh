#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Footer API Endpoint${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: Get footer data
echo -e "${BLUE}Test 1: GET /api/footer${NC}"
RESPONSE=$(curl -s -X GET "$BASE_URL/footer")
echo "$RESPONSE" | jq '.'

# Check if response contains expected fields
if echo "$RESPONSE" | jq -e '.success == true' > /dev/null && \
   echo "$RESPONSE" | jq -e '.data.contact' > /dev/null && \
   echo "$RESPONSE" | jq -e '.data.social_media' > /dev/null && \
   echo "$RESPONSE" | jq -e '.data.program_categories' > /dev/null; then
    echo -e "${GREEN}✓ Footer data retrieved successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to retrieve footer data${NC}\n"
fi

# Test 2: Verify contact information
echo -e "${BLUE}Test 2: Verify contact information${NC}"
EMAIL=$(echo "$RESPONSE" | jq -r '.data.contact.email')
PHONES=$(echo "$RESPONSE" | jq -r '.data.contact.phones | length')
ADDRESS=$(echo "$RESPONSE" | jq -r '.data.contact.address')
WORK_HOURS=$(echo "$RESPONSE" | jq -r '.data.contact.work_hours')

echo "Email: $EMAIL"
echo "Number of phones: $PHONES"
echo "Address: $ADDRESS"
echo "Work hours: $WORK_HOURS"

if [ ! -z "$EMAIL" ] && [ "$PHONES" -gt 0 ]; then
    echo -e "${GREEN}✓ Contact information is present${NC}\n"
else
    echo -e "${RED}✗ Contact information is incomplete${NC}\n"
fi

# Test 3: Verify social media links
echo -e "${BLUE}Test 3: Verify social media links${NC}"
FACEBOOK=$(echo "$RESPONSE" | jq -r '.data.social_media.facebook')
INSTAGRAM=$(echo "$RESPONSE" | jq -r '.data.social_media.instagram')
TWITTER=$(echo "$RESPONSE" | jq -r '.data.social_media.twitter')
YOUTUBE=$(echo "$RESPONSE" | jq -r '.data.social_media.youtube')
LINKEDIN=$(echo "$RESPONSE" | jq -r '.data.social_media.linkedin')
TIKTOK=$(echo "$RESPONSE" | jq -r '.data.social_media.tiktok')

echo "Facebook: $FACEBOOK"
echo "Instagram: $INSTAGRAM"
echo "Twitter: $TWITTER"
echo "YouTube: $YOUTUBE"
echo "LinkedIn: $LINKEDIN"
echo "TikTok: $TIKTOK"

if [ ! -z "$FACEBOOK" ] && [ ! -z "$INSTAGRAM" ]; then
    echo -e "${GREEN}✓ Social media links are present${NC}\n"
else
    echo -e "${RED}✗ Social media links are incomplete${NC}\n"
fi

# Test 4: Verify program categories
echo -e "${BLUE}Test 4: Verify program categories${NC}"
CATEGORIES_COUNT=$(echo "$RESPONSE" | jq -r '.data.program_categories | length')
echo "Number of program categories: $CATEGORIES_COUNT"

if [ "$CATEGORIES_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Program categories are present${NC}"
    echo -e "\n${BLUE}Program Categories:${NC}"
    echo "$RESPONSE" | jq -r '.data.program_categories[] | "- \(.name) (\(.slug)): \(.description)"'
else
    echo -e "${RED}✗ No program categories found${NC}\n"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Footer API Tests Completed${NC}"
echo -e "${BLUE}========================================${NC}"
