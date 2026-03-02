#!/bin/bash

BASE_URL="http://localhost:3000/api"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

echo "=========================================="
echo "Program Highlight Complete Test"
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

# Get all programs
echo "2. Getting all programs..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

PROGRAM_ID_1=$(echo $PROGRAMS | jq -r '.data[0].id')
PROGRAM_ID_2=$(echo $PROGRAMS | jq -r '.data[1].id')
PROGRAM_ID_3=$(echo $PROGRAMS | jq -r '.data[2].id')

echo "Using Program IDs: $PROGRAM_ID_1, $PROGRAM_ID_2, $PROGRAM_ID_3"
echo ""

# TEST 1: Create new program with highlight
echo "=========================================="
echo "TEST 1: Create Program with Highlight"
echo "=========================================="
echo ""

echo "3. Creating new program with is_highlighted: true..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/programs" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Highlighted Program",
    "description": "This program should be highlighted",
    "is_highlighted": true,
    "is_active": true
  }')

NEW_PROGRAM_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
echo "Created Program ID: $NEW_PROGRAM_ID"
echo ""

echo "4. Checking all programs..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
echo "Highlighted program ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$NEW_PROGRAM_ID" ]; then
  echo "✅ TEST 1 PASSED: Only new program is highlighted"
else
  echo "❌ TEST 1 FAILED: Expected only new program to be highlighted"
fi
echo ""

# TEST 2: Update another program to be highlighted
echo "=========================================="
echo "TEST 2: Update Program to Highlight"
echo "=========================================="
echo ""

echo "5. Highlighting Program $PROGRAM_ID_1..."
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID_1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_highlighted": true}')

echo ""

echo "6. Checking all programs..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
echo "Highlighted program ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$PROGRAM_ID_1" ]; then
  echo "✅ TEST 2 PASSED: Only Program $PROGRAM_ID_1 is highlighted"
else
  echo "❌ TEST 2 FAILED: Expected only Program $PROGRAM_ID_1 to be highlighted"
fi
echo ""

# TEST 3: Delete highlighted program (should assign to random)
echo "=========================================="
echo "TEST 3: Delete Highlighted Program"
echo "=========================================="
echo ""

echo "7. Deleting highlighted Program $PROGRAM_ID_1..."
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/admin/programs/$PROGRAM_ID_1" \
  -H "Authorization: Bearer $TOKEN")

echo $DELETE_RESPONSE | jq '.'
echo ""

echo "8. Checking all programs after deletion..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
if [ "$HIGHLIGHTED_COUNT" -gt 0 ]; then
  echo "Highlighted program ID: $HIGHLIGHTED_ID"
fi

if [ "$HIGHLIGHTED_COUNT" -eq 1 ]; then
  echo "✅ TEST 3 PASSED: A random program was assigned highlight after deletion"
else
  echo "❌ TEST 3 FAILED: Expected 1 program to be highlighted after deletion"
fi
echo ""

# TEST 4: Delete non-highlighted program (should not affect highlight)
echo "=========================================="
echo "TEST 4: Delete Non-Highlighted Program"
echo "=========================================="
echo ""

CURRENT_HIGHLIGHTED_ID=$HIGHLIGHTED_ID

echo "9. Deleting non-highlighted Program $NEW_PROGRAM_ID..."
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/admin/programs/$NEW_PROGRAM_ID" \
  -H "Authorization: Bearer $TOKEN")

echo ""

echo "10. Checking all programs after deletion..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
echo "Highlighted program ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$CURRENT_HIGHLIGHTED_ID" ]; then
  echo "✅ TEST 4 PASSED: Highlight unchanged after deleting non-highlighted program"
else
  echo "❌ TEST 4 FAILED: Highlight should remain unchanged"
fi
echo ""

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "All tests completed. Check results above."
