#!/bin/bash

BASE_URL="http://localhost:3000/api"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

echo "=========================================="
echo "Leadership Highlight Complete Test"
echo "=========================================="
echo ""

# Login
echo "1. Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed"
  echo $LOGIN_RESPONSE | jq '.'
  exit 1
fi

echo "✅ Login successful"
echo ""

# Get all leadership members
echo "2. Getting all leadership members..."
LEADERSHIP=$(curl -s -X GET "$BASE_URL/admin/leadership?limit=100" \
  -H "Authorization: Bearer $TOKEN")

MEMBER_ID_1=$(echo $LEADERSHIP | jq -r '.data[0].id')
MEMBER_ID_2=$(echo $LEADERSHIP | jq -r '.data[1].id')
MEMBER_ID_3=$(echo $LEADERSHIP | jq -r '.data[2].id')

echo "Using Leadership IDs: $MEMBER_ID_1, $MEMBER_ID_2, $MEMBER_ID_3"
echo ""

# TEST 1: Create new leadership member with highlight
echo "=========================================="
echo "TEST 1: Create Leadership with Highlight"
echo "=========================================="
echo ""

echo "3. Creating new leadership member with is_highlighted: true..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/leadership" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Highlighted Leader",
    "position": "Test Position",
    "bio": "This leader should be highlighted",
    "is_highlighted": true,
    "is_active": true
  }')

NEW_MEMBER_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
echo "Created Leadership ID: $NEW_MEMBER_ID"
echo ""

echo "4. Checking all leadership members..."
LEADERSHIP=$(curl -s -X GET "$BASE_URL/admin/leadership?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $LEADERSHIP | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $LEADERSHIP | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted leadership count: $HIGHLIGHTED_COUNT"
echo "Highlighted leadership ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$NEW_MEMBER_ID" ]; then
  echo "✅ TEST 1 PASSED: Only new leadership member is highlighted"
else
  echo "❌ TEST 1 FAILED: Expected only new leadership member to be highlighted"
fi
echo ""

# TEST 2: Update another leadership member to be highlighted
echo "=========================================="
echo "TEST 2: Update Leadership to Highlight"
echo "=========================================="
echo ""

echo "5. Highlighting Leadership $MEMBER_ID_1..."
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/leadership/$MEMBER_ID_1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_highlighted": true}')

echo ""

echo "6. Checking all leadership members..."
LEADERSHIP=$(curl -s -X GET "$BASE_URL/admin/leadership?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $LEADERSHIP | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $LEADERSHIP | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted leadership count: $HIGHLIGHTED_COUNT"
echo "Highlighted leadership ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$MEMBER_ID_1" ]; then
  echo "✅ TEST 2 PASSED: Only Leadership $MEMBER_ID_1 is highlighted"
else
  echo "❌ TEST 2 FAILED: Expected only Leadership $MEMBER_ID_1 to be highlighted"
fi
echo ""

# TEST 3: Delete highlighted leadership member (should assign to random)
echo "=========================================="
echo "TEST 3: Delete Highlighted Leadership"
echo "=========================================="
echo ""

echo "7. Deleting highlighted Leadership $MEMBER_ID_1..."
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/admin/leadership/$MEMBER_ID_1" \
  -H "Authorization: Bearer $TOKEN")

echo $DELETE_RESPONSE | jq '.'
echo ""

echo "8. Checking all leadership members after deletion..."
LEADERSHIP=$(curl -s -X GET "$BASE_URL/admin/leadership?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $LEADERSHIP | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $LEADERSHIP | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted leadership count: $HIGHLIGHTED_COUNT"
if [ "$HIGHLIGHTED_COUNT" -gt 0 ]; then
  echo "Highlighted leadership ID: $HIGHLIGHTED_ID"
fi

if [ "$HIGHLIGHTED_COUNT" -eq 1 ]; then
  echo "✅ TEST 3 PASSED: A random leadership member was assigned highlight after deletion"
else
  echo "❌ TEST 3 FAILED: Expected 1 leadership member to be highlighted after deletion"
fi
echo ""

# TEST 4: Delete non-highlighted leadership member (should not affect highlight)
echo "=========================================="
echo "TEST 4: Delete Non-Highlighted Leadership"
echo "=========================================="
echo ""

CURRENT_HIGHLIGHTED_ID=$HIGHLIGHTED_ID

echo "9. Deleting non-highlighted Leadership $NEW_MEMBER_ID..."
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/admin/leadership/$NEW_MEMBER_ID" \
  -H "Authorization: Bearer $TOKEN")

echo ""

echo "10. Checking all leadership members after deletion..."
LEADERSHIP=$(curl -s -X GET "$BASE_URL/admin/leadership?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $LEADERSHIP | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $LEADERSHIP | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted leadership count: $HIGHLIGHTED_COUNT"
echo "Highlighted leadership ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$CURRENT_HIGHLIGHTED_ID" ]; then
  echo "✅ TEST 4 PASSED: Highlight unchanged after deleting non-highlighted leadership member"
else
  echo "❌ TEST 4 FAILED: Highlight should remain unchanged"
fi
echo ""

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "All tests completed. Check results above."
