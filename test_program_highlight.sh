#!/bin/bash

BASE_URL="http://localhost:3000/api"
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

echo "=========================================="
echo "Program Auto-Unhighlight Test"
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

echo $PROGRAMS | jq '.data[] | {id, name, is_highlighted}'
echo ""

# Get first 3 program IDs
PROGRAM_ID_1=$(echo $PROGRAMS | jq -r '.data[0].id')
PROGRAM_ID_2=$(echo $PROGRAMS | jq -r '.data[1].id')
PROGRAM_ID_3=$(echo $PROGRAMS | jq -r '.data[2].id')

if [ "$PROGRAM_ID_1" == "null" ] || [ "$PROGRAM_ID_2" == "null" ]; then
  echo "❌ Not enough programs found for testing"
  exit 1
fi

echo "Testing with Program IDs: $PROGRAM_ID_1, $PROGRAM_ID_2, $PROGRAM_ID_3"
echo ""

# Test 1: Highlight Program A
echo "3. Test 1: Highlighting Program $PROGRAM_ID_1..."
RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID_1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_highlighted": true}')

echo $RESPONSE | jq '.'
echo ""

# Check all programs
echo "4. Checking all programs after highlighting Program $PROGRAM_ID_1..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
echo "Highlighted program ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$PROGRAM_ID_1" ]; then
  echo "✅ Test 1 PASSED: Only Program $PROGRAM_ID_1 is highlighted"
else
  echo "❌ Test 1 FAILED: Expected only Program $PROGRAM_ID_1 to be highlighted"
fi
echo ""

# Test 2: Highlight Program B (should auto-unhighlight Program A)
echo "5. Test 2: Highlighting Program $PROGRAM_ID_2 (should auto-unhighlight Program $PROGRAM_ID_1)..."
RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID_2" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_highlighted": true}')

echo $RESPONSE | jq '.'
echo ""

# Check all programs
echo "6. Checking all programs after highlighting Program $PROGRAM_ID_2..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
echo "Highlighted program ID: $HIGHLIGHTED_ID"

if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$PROGRAM_ID_2" ]; then
  echo "✅ Test 2 PASSED: Only Program $PROGRAM_ID_2 is highlighted (Program $PROGRAM_ID_1 auto-unhighlighted)"
else
  echo "❌ Test 2 FAILED: Expected only Program $PROGRAM_ID_2 to be highlighted"
fi
echo ""

# Test 3: Highlight Program C
if [ "$PROGRAM_ID_3" != "null" ]; then
  echo "7. Test 3: Highlighting Program $PROGRAM_ID_3..."
  RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID_3" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"is_highlighted": true}')

  echo $RESPONSE | jq '.'
  echo ""

  # Check all programs
  echo "8. Checking all programs after highlighting Program $PROGRAM_ID_3..."
  PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
    -H "Authorization: Bearer $TOKEN")

  HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')
  HIGHLIGHTED_ID=$(echo $PROGRAMS | jq -r '[.data[] | select(.is_highlighted == 1)][0].id')

  echo "Highlighted programs count: $HIGHLIGHTED_COUNT"
  echo "Highlighted program ID: $HIGHLIGHTED_ID"

  if [ "$HIGHLIGHTED_COUNT" -eq 1 ] && [ "$HIGHLIGHTED_ID" == "$PROGRAM_ID_3" ]; then
    echo "✅ Test 3 PASSED: Only Program $PROGRAM_ID_3 is highlighted"
  else
    echo "❌ Test 3 FAILED: Expected only Program $PROGRAM_ID_3 to be highlighted"
  fi
  echo ""
fi

# Test 4: Unhighlight by setting to false
echo "9. Test 4: Unhighlighting Program $PROGRAM_ID_3 by setting is_highlighted to false..."
RESPONSE=$(curl -s -X PUT "$BASE_URL/admin/programs/$PROGRAM_ID_3" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_highlighted": false}')

echo $RESPONSE | jq '.'
echo ""

# Check all programs
echo "10. Checking all programs after unhighlighting..."
PROGRAMS=$(curl -s -X GET "$BASE_URL/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN")

HIGHLIGHTED_COUNT=$(echo $PROGRAMS | jq '[.data[] | select(.is_highlighted == 1)] | length')

echo "Highlighted programs count: $HIGHLIGHTED_COUNT"

if [ "$HIGHLIGHTED_COUNT" -eq 0 ]; then
  echo "✅ Test 4 PASSED: No programs are highlighted"
else
  echo "❌ Test 4 FAILED: Expected no programs to be highlighted"
fi
echo ""

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "All tests completed. Check results above."
