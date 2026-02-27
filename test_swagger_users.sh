#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"
PASSED=0
FAILED=0

echo "=== Swagger User Management Documentation Test ==="
echo ""

# Test 1: Check if Swagger UI is accessible
echo -e "${YELLOW}Test 1: Swagger UI Accessibility${NC}"
SWAGGER_UI=$(curl -s -L -o /dev/null -w "%{http_code}" "$BASE_URL/api-docs")
if [ "$SWAGGER_UI" = "200" ]; then
  echo -e "${GREEN}✓${NC} Swagger UI is accessible at /api-docs"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} Swagger UI is not accessible (HTTP $SWAGGER_UI)"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 2: Check if Swagger JSON is accessible
echo -e "${YELLOW}Test 2: Swagger JSON Accessibility${NC}"
SWAGGER_JSON=$(curl -s "$BASE_URL/api-docs.json")
if echo "$SWAGGER_JSON" | jq -e '.openapi' > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Swagger JSON is accessible and valid"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} Swagger JSON is not accessible or invalid"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Check if User Management endpoints are documented
echo -e "${YELLOW}Test 3: User Management Endpoints Documentation${NC}"

# Check GET /api/admin/users
GET_USERS=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} GET /api/admin/users is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} GET /api/admin/users is not documented"
  FAILED=$((FAILED + 1))
fi

# Check POST /api/admin/users
POST_USERS=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".post')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} POST /api/admin/users is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} POST /api/admin/users is not documented"
  FAILED=$((FAILED + 1))
fi

# Check GET /api/admin/users/{id}
GET_USER=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".get')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} GET /api/admin/users/{id} is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} GET /api/admin/users/{id} is not documented"
  FAILED=$((FAILED + 1))
fi

# Check PUT /api/admin/users/{id}
PUT_USER=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".put')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} PUT /api/admin/users/{id} is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} PUT /api/admin/users/{id} is not documented"
  FAILED=$((FAILED + 1))
fi

# Check DELETE /api/admin/users/{id}
DELETE_USER=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".delete')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} DELETE /api/admin/users/{id} is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} DELETE /api/admin/users/{id} is not documented"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 4: Check pagination parameters
echo -e "${YELLOW}Test 4: Pagination Parameters${NC}"
PAGE_PARAM=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get.parameters[] | select(.name == "page")')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} 'page' parameter is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} 'page' parameter is not documented"
  FAILED=$((FAILED + 1))
fi

LIMIT_PARAM=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get.parameters[] | select(.name == "limit")')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} 'limit' parameter is documented"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} 'limit' parameter is not documented"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 5: Check request body schemas
echo -e "${YELLOW}Test 5: Request Body Schemas${NC}"

# POST request body
POST_SCHEMA=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".post.requestBody.content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} POST /api/admin/users has request body schema"
  PASSED=$((PASSED + 1))
  
  # Check required fields
  REQUIRED_FIELDS=$(echo "$POST_SCHEMA" | jq -r '.required[]' 2>/dev/null)
  if echo "$REQUIRED_FIELDS" | grep -q "username" && \
     echo "$REQUIRED_FIELDS" | grep -q "email" && \
     echo "$REQUIRED_FIELDS" | grep -q "password"; then
    echo -e "${GREEN}✓${NC} Required fields (username, email, password) are documented"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}✗${NC} Required fields are not properly documented"
    FAILED=$((FAILED + 1))
  fi
else
  echo -e "${RED}✗${NC} POST /api/admin/users missing request body schema"
  FAILED=$((FAILED + 2))
fi

# PUT request body
PUT_SCHEMA=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".put.requestBody.content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} PUT /api/admin/users/{id} has request body schema"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} PUT /api/admin/users/{id} missing request body schema"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 6: Check response schemas
echo -e "${YELLOW}Test 6: Response Schemas${NC}"

# GET response
GET_RESPONSE=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get.responses."200".content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} GET /api/admin/users has 200 response schema"
  PASSED=$((PASSED + 1))
  
  # Check for pagination in response
  HAS_PAGINATION=$(echo "$GET_RESPONSE" | jq -e '.properties.pagination')
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Response includes pagination schema"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}✗${NC} Response missing pagination schema"
    FAILED=$((FAILED + 1))
  fi
else
  echo -e "${RED}✗${NC} GET /api/admin/users missing 200 response schema"
  FAILED=$((FAILED + 2))
fi

# POST response
POST_RESPONSE=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".post.responses."201".content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} POST /api/admin/users has 201 response schema"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} POST /api/admin/users missing 201 response schema"
  FAILED=$((FAILED + 1))
fi

# PUT response
PUT_RESPONSE=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".put.responses."200".content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} PUT /api/admin/users/{id} has 200 response schema"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} PUT /api/admin/users/{id} missing 200 response schema"
  FAILED=$((FAILED + 1))
fi

# DELETE response
DELETE_RESPONSE=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".delete.responses."200".content."application/json".schema')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} DELETE /api/admin/users/{id} has 200 response schema"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} DELETE /api/admin/users/{id} missing 200 response schema"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 7: Check security requirements
echo -e "${YELLOW}Test 7: Security Requirements${NC}"

GET_SECURITY=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get.security')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} GET /api/admin/users has security requirements"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} GET /api/admin/users missing security requirements"
  FAILED=$((FAILED + 1))
fi

POST_SECURITY=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".post.security')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} POST /api/admin/users has security requirements"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} POST /api/admin/users missing security requirements"
  FAILED=$((FAILED + 1))
fi

PUT_SECURITY=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".put.security')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} PUT /api/admin/users/{id} has security requirements"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} PUT /api/admin/users/{id} missing security requirements"
  FAILED=$((FAILED + 1))
fi

DELETE_SECURITY=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".delete.security')
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} DELETE /api/admin/users/{id} has security requirements"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} DELETE /api/admin/users/{id} missing security requirements"
  FAILED=$((FAILED + 1))
fi
echo ""

# Test 8: Check tags
echo -e "${YELLOW}Test 8: Endpoint Tags${NC}"

GET_TAG=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".get.tags[] | select(. == "Admin - Users")')
POST_TAG=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users".post.tags[] | select(. == "Admin - Users")')
PUT_TAG=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".put.tags[] | select(. == "Admin - Users")')
DELETE_TAG=$(echo "$SWAGGER_JSON" | jq -e '.paths."/api/admin/users/{id}".delete.tags[] | select(. == "Admin - Users")')

if [ $? -eq 0 ] && [ -n "$GET_TAG" ] && [ -n "$POST_TAG" ] && [ -n "$PUT_TAG" ] && [ -n "$DELETE_TAG" ]; then
  echo -e "${GREEN}✓${NC} All endpoints are tagged with 'Admin - Users'"
  PASSED=$((PASSED + 1))
else
  echo -e "${RED}✗${NC} Some endpoints are missing 'Admin - Users' tag"
  FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $FAILED${NC}"
  echo ""
  echo "Swagger documentation needs improvement."
  exit 1
else
  echo -e "${RED}Failed: $FAILED${NC}"
  echo ""
  echo -e "${GREEN}✓ All Swagger documentation tests passed!${NC}"
  echo ""
  echo "View the documentation at: $BASE_URL/api-docs"
fi
