#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing Swagger Documentation${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: Swagger UI is accessible
echo -e "${BLUE}Test 1: Swagger UI Accessibility${NC}"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api-docs/")
if [ "$STATUS" == "200" ]; then
    echo -e "${GREEN}✓ Swagger UI accessible at /api-docs/${NC}"
else
    echo -e "${RED}✗ Swagger UI not accessible (Status: $STATUS)${NC}"
fi
echo ""

# Test 2: Check Swagger spec has new tags
echo -e "${BLUE}Test 2: Swagger Tags${NC}"
node -e "
const spec = require('./src/utils/swagger.js');
const tags = spec.tags.map(t => t.name);
const requiredTags = ['Footer', 'Admin - Program Categories', 'Admin - Statistics', 'Admin - Image Upload'];
let allFound = true;
requiredTags.forEach(tag => {
  if (tags.includes(tag)) {
    console.log('\x1b[32m✓\x1b[0m Tag found:', tag);
  } else {
    console.log('\x1b[31m✗\x1b[0m Tag missing:', tag);
    allFound = false;
  }
});
process.exit(allFound ? 0 : 1);
"
echo ""

# Test 3: Check Swagger spec has new schemas
echo -e "${BLUE}Test 3: Swagger Schemas${NC}"
node -e "
const spec = require('./src/utils/swagger.js');
const schemas = Object.keys(spec.components.schemas);
const requiredSchemas = ['ProgramCategory', 'FooterData'];
let allFound = true;
requiredSchemas.forEach(schema => {
  if (schemas.includes(schema)) {
    console.log('\x1b[32m✓\x1b[0m Schema found:', schema);
  } else {
    console.log('\x1b[31m✗\x1b[0m Schema missing:', schema);
    allFound = false;
  }
});
process.exit(allFound ? 0 : 1);
"
echo ""

# Test 4: Verify FooterData schema structure
echo -e "${BLUE}Test 4: FooterData Schema Structure${NC}"
node -e "
const spec = require('./src/utils/swagger.js');
const footerSchema = spec.components.schemas.FooterData;
const requiredProps = ['contact', 'social_media', 'program_categories'];
let allFound = true;
requiredProps.forEach(prop => {
  if (footerSchema.properties[prop]) {
    console.log('\x1b[32m✓\x1b[0m Property found:', prop);
  } else {
    console.log('\x1b[31m✗\x1b[0m Property missing:', prop);
    allFound = false;
  }
});
process.exit(allFound ? 0 : 1);
"
echo ""

# Test 5: Verify ProgramCategory schema structure
echo -e "${BLUE}Test 5: ProgramCategory Schema Structure${NC}"
node -e "
const spec = require('./src/utils/swagger.js');
const categorySchema = spec.components.schemas.ProgramCategory;
const requiredProps = ['id', 'name', 'slug', 'description', 'icon', 'order_position', 'is_active'];
let allFound = true;
requiredProps.forEach(prop => {
  if (categorySchema.properties[prop]) {
    console.log('\x1b[32m✓\x1b[0m Property found:', prop);
  } else {
    console.log('\x1b[31m✗\x1b[0m Property missing:', prop);
    allFound = false;
  }
});
process.exit(allFound ? 0 : 1);
"
echo ""

# Test 6: Check JSDoc in controllers
echo -e "${BLUE}Test 6: JSDoc Documentation in Controllers${NC}"

# Check footerController
if grep -q "@swagger" src/controllers/footerController.js; then
    echo -e "${GREEN}✓ footerController.js has Swagger documentation${NC}"
else
    echo -e "${RED}✗ footerController.js missing Swagger documentation${NC}"
fi

# Check programCategoryController
if grep -q "@swagger" src/controllers/programCategoryController.js; then
    echo -e "${GREEN}✓ programCategoryController.js has Swagger documentation${NC}"
else
    echo -e "${RED}✗ programCategoryController.js missing Swagger documentation${NC}"
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Swagger Documentation Tests Completed${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "\n${GREEN}Access Swagger UI at: http://localhost:3000/api-docs/${NC}"
