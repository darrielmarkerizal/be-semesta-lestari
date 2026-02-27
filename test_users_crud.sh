#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:3000"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Admin credentials
ADMIN_EMAIL="admin@semestalestari.com"
ADMIN_PASSWORD="admin123"

# Function to print test result
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ $2${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to check JSON field
check_field() {
    local json=$1
    local field=$2
    echo "$json" | jq -e "$field" > /dev/null 2>&1
    return $?
}

echo -e "${YELLOW}=== User Management CRUD Test Suite ===${NC}\n"

# Login to get token
echo "Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get authentication token${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully logged in${NC}\n"

# ============================================
# CREATE TESTS
# ============================================
echo -e "${YELLOW}--- CREATE Tests ---${NC}"

# Test 1: Create new user
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser1",
        "email": "testuser1@example.com",
        "password": "testpass123",
        "role": "admin"
    }')
check_field "$CREATE_RESPONSE" '.success' && \
[ "$(echo $CREATE_RESPONSE | jq -r '.data.username')" = "testuser1" ]
print_result $? "POST /api/admin/users creates new user"

USER1_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')

# Test 2: Create user with minimal fields
CREATE_RESPONSE2=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser2",
        "email": "testuser2@example.com",
        "password": "testpass123"
    }')
check_field "$CREATE_RESPONSE2" '.success'
print_result $? "POST /api/admin/users creates user with minimal fields"

USER2_ID=$(echo $CREATE_RESPONSE2 | jq -r '.data.id')

# Test 3: Create user with editor role
CREATE_RESPONSE3=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "editoruser",
        "email": "editor@example.com",
        "password": "editorpass123",
        "role": "editor"
    }')
check_field "$CREATE_RESPONSE3" '.success' && \
[ "$(echo $CREATE_RESPONSE3 | jq -r '.data.role')" = "editor" ]
print_result $? "POST /api/admin/users creates user with editor role"

EDITOR_ID=$(echo $CREATE_RESPONSE3 | jq -r '.data.id')

# Test 4: Duplicate username should fail
DUPLICATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser1",
        "email": "different@example.com",
        "password": "testpass123"
    }')
[ "$(echo $DUPLICATE_RESPONSE | jq -r '.success')" = "false" ]
print_result $? "POST /api/admin/users rejects duplicate username"

# Test 5: Duplicate email should fail
DUPLICATE_EMAIL=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "differentuser",
        "email": "testuser1@example.com",
        "password": "testpass123"
    }')
[ "$(echo $DUPLICATE_EMAIL | jq -r '.success')" = "false" ]
print_result $? "POST /api/admin/users rejects duplicate email"

# ============================================
# READ TESTS
# ============================================
echo -e "\n${YELLOW}--- READ Tests ---${NC}"

# Test 6: Get all users
ALL_USERS=$(curl -s -X GET "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer $TOKEN")
check_field "$ALL_USERS" '.success' && \
[ "$(echo $ALL_USERS | jq -r '.data | length')" -ge 3 ]
print_result $? "GET /api/admin/users returns all users"

# Test 7: Get users with pagination
PAGINATED=$(curl -s -X GET "$BASE_URL/api/admin/users?page=1&limit=2" \
    -H "Authorization: Bearer $TOKEN")
check_field "$PAGINATED" '.pagination' && \
[ "$(echo $PAGINATED | jq -r '.pagination.itemsPerPage')" = "2" ]
print_result $? "GET /api/admin/users supports pagination"

# Test 8: Get single user by ID
SINGLE_USER=$(curl -s -X GET "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN")
check_field "$SINGLE_USER" '.success' && \
[ "$(echo $SINGLE_USER | jq -r '.data.id')" = "$USER1_ID" ]
print_result $? "GET /api/admin/users/:id returns single user"

# Test 9: Get non-existent user
NOT_FOUND=$(curl -s -X GET "$BASE_URL/api/admin/users/99999" \
    -H "Authorization: Bearer $TOKEN")
[ "$(echo $NOT_FOUND | jq -r '.success')" = "false" ]
print_result $? "GET /api/admin/users/:id returns 404 for non-existent user"

# Test 10: Verify user data structure
check_field "$SINGLE_USER" '.data.id' && \
check_field "$SINGLE_USER" '.data.username' && \
check_field "$SINGLE_USER" '.data.email' && \
check_field "$SINGLE_USER" '.data.role' && \
check_field "$SINGLE_USER" '.data.status'
print_result $? "User object has all required fields"

# ============================================
# UPDATE TESTS
# ============================================
echo -e "\n${YELLOW}--- UPDATE Tests ---${NC}"

# Test 11: Update username
UPDATE_USERNAME=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username": "updateduser1"}')
check_field "$UPDATE_USERNAME" '.success' && \
[ "$(echo $UPDATE_USERNAME | jq -r '.data.username')" = "updateduser1" ]
print_result $? "PUT /api/admin/users/:id updates username"

# Test 12: Update email
UPDATE_EMAIL=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"email": "updated1@example.com"}')
check_field "$UPDATE_EMAIL" '.success' && \
[ "$(echo $UPDATE_EMAIL | jq -r '.data.email')" = "updated1@example.com" ]
print_result $? "PUT /api/admin/users/:id updates email"

# Test 13: Update role
UPDATE_ROLE=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER2_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"role": "editor"}')
check_field "$UPDATE_ROLE" '.success' && \
[ "$(echo $UPDATE_ROLE | jq -r '.data.role')" = "editor" ]
print_result $? "PUT /api/admin/users/:id updates role"

# Test 14: Update status
UPDATE_STATUS=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER2_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"status": "inactive"}')
check_field "$UPDATE_STATUS" '.success' && \
[ "$(echo $UPDATE_STATUS | jq -r '.data.status')" = "inactive" ]
print_result $? "PUT /api/admin/users/:id updates status"

# Test 15: Update password
UPDATE_PASSWORD=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER2_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"password": "newpassword123"}')
check_field "$UPDATE_PASSWORD" '.success'
print_result $? "PUT /api/admin/users/:id updates password"

# Test 16: Update multiple fields at once
UPDATE_MULTIPLE=$(curl -s -X PUT "$BASE_URL/api/admin/users/$EDITOR_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "updatededitor",
        "email": "updated.editor@example.com",
        "role": "admin"
    }')
check_field "$UPDATE_MULTIPLE" '.success' && \
[ "$(echo $UPDATE_MULTIPLE | jq -r '.data.username')" = "updatededitor" ] && \
[ "$(echo $UPDATE_MULTIPLE | jq -r '.data.email')" = "updated.editor@example.com" ] && \
[ "$(echo $UPDATE_MULTIPLE | jq -r '.data.role')" = "admin" ]
print_result $? "PUT /api/admin/users/:id updates multiple fields"

# Test 17: Partial update preserves other fields
CURRENT_USER=$(curl -s -X GET "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN")
CURRENT_ROLE=$(echo $CURRENT_USER | jq -r '.data.role')

PARTIAL_UPDATE=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username": "partialupdate"}')
NEW_ROLE=$(echo $PARTIAL_UPDATE | jq -r '.data.role')

[ "$CURRENT_ROLE" = "$NEW_ROLE" ]
print_result $? "PUT /api/admin/users/:id partial update preserves other fields"

# Test 18: Update non-existent user
UPDATE_NOT_FOUND=$(curl -s -X PUT "$BASE_URL/api/admin/users/99999" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username": "test"}')
[ "$(echo $UPDATE_NOT_FOUND | jq -r '.success')" = "false" ]
print_result $? "PUT /api/admin/users/:id returns 404 for non-existent user"

# ============================================
# DELETE TESTS
# ============================================
echo -e "\n${YELLOW}--- DELETE Tests ---${NC}"

# Test 19: Delete user
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/admin/users/$USER2_ID" \
    -H "Authorization: Bearer $TOKEN")
check_field "$DELETE_RESPONSE" '.success'
print_result $? "DELETE /api/admin/users/:id deletes user"

# Test 20: Verify user is deleted
VERIFY_DELETED=$(curl -s -X GET "$BASE_URL/api/admin/users/$USER2_ID" \
    -H "Authorization: Bearer $TOKEN")
[ "$(echo $VERIFY_DELETED | jq -r '.success')" = "false" ]
print_result $? "Deleted user cannot be retrieved"

# Test 21: Delete non-existent user
DELETE_NOT_FOUND=$(curl -s -X DELETE "$BASE_URL/api/admin/users/99999" \
    -H "Authorization: Bearer $TOKEN")
[ "$(echo $DELETE_NOT_FOUND | jq -r '.success')" = "false" ]
print_result $? "DELETE /api/admin/users/:id returns 404 for non-existent user"

# Test 22: Cannot delete own account
ADMIN_USER=$(curl -s -X GET "$BASE_URL/api/admin/auth/me" \
    -H "Authorization: Bearer $TOKEN")
ADMIN_ID=$(echo $ADMIN_USER | jq -r '.data.id')

DELETE_SELF=$(curl -s -X DELETE "$BASE_URL/api/admin/users/$ADMIN_ID" \
    -H "Authorization: Bearer $TOKEN")
[ "$(echo $DELETE_SELF | jq -r '.success')" = "false" ]
print_result $? "DELETE /api/admin/users/:id prevents deleting own account"

# ============================================
# AUTHORIZATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Authorization Tests ---${NC}"

# Test 23: Endpoints require authentication
NO_AUTH_GET=$(curl -s -X GET "$BASE_URL/api/admin/users")
[ "$(echo $NO_AUTH_GET | jq -r '.success')" = "false" ]
print_result $? "GET /api/admin/users requires authentication"

# Test 24: POST requires authentication
NO_AUTH_POST=$(curl -s -X POST "$BASE_URL/api/admin/users" \
    -H "Content-Type: application/json" \
    -d '{"username":"test","email":"test@test.com","password":"test123"}')
[ "$(echo $NO_AUTH_POST | jq -r '.success')" = "false" ]
print_result $? "POST /api/admin/users requires authentication"

# Test 25: PUT requires authentication
NO_AUTH_PUT=$(curl -s -X PUT "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Content-Type: application/json" \
    -d '{"username":"test"}')
[ "$(echo $NO_AUTH_PUT | jq -r '.success')" = "false" ]
print_result $? "PUT /api/admin/users/:id requires authentication"

# Test 26: DELETE requires authentication
NO_AUTH_DELETE=$(curl -s -X DELETE "$BASE_URL/api/admin/users/$USER1_ID")
[ "$(echo $NO_AUTH_DELETE | jq -r '.success')" = "false" ]
print_result $? "DELETE /api/admin/users/:id requires authentication"

# Test 27: Invalid token rejected
INVALID_TOKEN=$(curl -s -X GET "$BASE_URL/api/admin/users" \
    -H "Authorization: Bearer invalid_token_12345")
[ "$(echo $INVALID_TOKEN | jq -r '.success')" = "false" ]
print_result $? "Invalid token is rejected"

# ============================================
# DATA VALIDATION TESTS
# ============================================
echo -e "\n${YELLOW}--- Data Validation Tests ---${NC}"

# Test 28: Response structure validation
RESPONSE_STRUCTURE=$(curl -s -X GET "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN")
check_field "$RESPONSE_STRUCTURE" '.success' && \
check_field "$RESPONSE_STRUCTURE" '.message' && \
check_field "$RESPONSE_STRUCTURE" '.data'
print_result $? "Response has correct structure (success, message, data)"

# Test 29: User object structure
check_field "$RESPONSE_STRUCTURE" '.data.id' && \
check_field "$RESPONSE_STRUCTURE" '.data.username' && \
check_field "$RESPONSE_STRUCTURE" '.data.email' && \
check_field "$RESPONSE_STRUCTURE" '.data.role' && \
check_field "$RESPONSE_STRUCTURE" '.data.status' && \
check_field "$RESPONSE_STRUCTURE" '.data.created_at' && \
check_field "$RESPONSE_STRUCTURE" '.data.updated_at'
print_result $? "User object has all required fields"

# Test 30: Password not exposed in response
PASSWORD_CHECK=$(echo $RESPONSE_STRUCTURE | jq 'has("password")')
[ "$PASSWORD_CHECK" = "false" ]
print_result $? "Password field not exposed in API response"

# ============================================
# CLEANUP
# ============================================
echo -e "\n${YELLOW}--- Cleanup ---${NC}"

# Delete remaining test users
curl -s -X DELETE "$BASE_URL/api/admin/users/$USER1_ID" \
    -H "Authorization: Bearer $TOKEN" > /dev/null
curl -s -X DELETE "$BASE_URL/api/admin/users/$EDITOR_ID" \
    -H "Authorization: Bearer $TOKEN" > /dev/null

echo "Test users cleaned up"

# ============================================
# SUMMARY
# ============================================
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    SUCCESS_RATE=100
else
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "\n${YELLOW}Success Rate: ${SUCCESS_RATE}%${NC}"
fi

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
    exit 0
else
    exit 1
fi
