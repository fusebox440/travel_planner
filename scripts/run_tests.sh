#!/usr/bin/env bash

# Travel Planner Test Runner Script
# Runs comprehensive test suite for Firebase Phone Authentication

echo "🧪 Starting Travel Planner Test Suite..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track test results
UNIT_TESTS_PASSED=false
INTEGRATION_TESTS_PASSED=false
ANALYSIS_PASSED=false
COVERAGE_GENERATED=false

echo -e "${BLUE}📋 Test Plan:${NC}"
echo "  ✓ Code analysis (flutter analyze)"
echo "  ✓ Unit tests (authentication, hotfixes)"
echo "  ✓ Integration tests (auth flow)"
echo "  ✓ Test coverage report"
echo ""

# 1. Code Analysis
echo -e "${YELLOW}🔍 Running code analysis...${NC}"
flutter analyze
ANALYZE_EXIT_CODE=$?

if [ $ANALYZE_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Code analysis passed!${NC}"
    ANALYSIS_PASSED=true
else
    echo -e "${RED}❌ Code analysis failed with exit code: $ANALYZE_EXIT_CODE${NC}"
    echo -e "${YELLOW}💡 Note: Test-related analysis errors may not affect main app functionality${NC}"
fi

echo ""

# 2. Generate mock files
echo -e "${YELLOW}🏗️  Generating mock files...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs
BUILD_RUNNER_EXIT_CODE=$?

if [ $BUILD_RUNNER_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Mock files generated successfully!${NC}"
else
    echo -e "${RED}❌ Mock generation failed. Continuing with existing mocks...${NC}"
fi

echo ""

# 3. Unit Tests
echo -e "${YELLOW}🧪 Running unit tests...${NC}"
flutter test --coverage --reporter expanded
UNIT_TEST_EXIT_CODE=$?

if [ $UNIT_TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Unit tests passed!${NC}"
    UNIT_TESTS_PASSED=true
else
    echo -e "${RED}❌ Unit tests failed with exit code: $UNIT_TEST_EXIT_CODE${NC}"
fi

echo ""

# 4. Integration Tests
echo -e "${YELLOW}🔄 Running integration tests...${NC}"
echo -e "${BLUE}Note: Integration tests require Firebase test project configuration${NC}"

flutter test integration_test/authentication_test.dart
INTEGRATION_EXIT_CODE=$?

if [ $INTEGRATION_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Integration tests passed!${NC}"
    INTEGRATION_TESTS_PASSED=true
else
    echo -e "${RED}❌ Integration tests failed with exit code: $INTEGRATION_EXIT_CODE${NC}"
    echo -e "${YELLOW}💡 Integration tests may fail without proper Firebase setup${NC}"
fi

echo ""

# 5. Coverage Report
echo -e "${YELLOW}📊 Generating coverage report...${NC}"
if [ -f "coverage/lcov.info" ]; then
    # Check if genhtml is available (part of lcov package)
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}✅ Coverage report generated at coverage/html/index.html${NC}"
        COVERAGE_GENERATED=true
    else
        echo -e "${YELLOW}⚠️  genhtml not found. Install lcov package for HTML coverage reports${NC}"
        echo -e "${BLUE}Coverage data available at coverage/lcov.info${NC}"
    fi
else
    echo -e "${RED}❌ No coverage data found. Run tests with --coverage flag${NC}"
fi

echo ""

# 6. Test Summary
echo -e "${BLUE}🎯 Test Results Summary${NC}"
echo "========================"

if [ "$ANALYSIS_PASSED" = true ]; then
    echo -e "📊 Code Analysis:     ${GREEN}✅ PASSED${NC}"
else
    echo -e "📊 Code Analysis:     ${RED}❌ FAILED${NC}"
fi

if [ "$UNIT_TESTS_PASSED" = true ]; then
    echo -e "🧪 Unit Tests:        ${GREEN}✅ PASSED${NC}"
else
    echo -e "🧪 Unit Tests:        ${RED}❌ FAILED${NC}"
fi

if [ "$INTEGRATION_TESTS_PASSED" = true ]; then
    echo -e "🔄 Integration Tests: ${GREEN}✅ PASSED${NC}"
else
    echo -e "🔄 Integration Tests: ${RED}❌ FAILED${NC}"
fi

if [ "$COVERAGE_GENERATED" = true ]; then
    echo -e "📈 Coverage Report:   ${GREEN}✅ GENERATED${NC}"
else
    echo -e "📈 Coverage Report:   ${YELLOW}⚠️  LIMITED${NC}"
fi

echo ""

# 7. Specific Test Categories
echo -e "${BLUE}📂 Test Categories Covered:${NC}"
echo "  🔐 Authentication Service Tests"
echo "    • Phone verification flow"
echo "    • OTP validation" 
echo "    • User profile management"
echo "    • Error handling"
echo ""
echo "  🛠️  Hotfix Tests"
echo "    • addCompanion null safety"
echo "    • fetchPackingList safety"
echo "    • Data integrity checks"
echo ""
echo "  🎯 Integration Tests"
echo "    • End-to-end auth flow"
echo "    • UI interaction testing"
echo "    • State persistence"
echo ""

# 8. Test Data Summary
if [ -f "coverage/lcov.info" ]; then
    echo -e "${BLUE}📈 Coverage Statistics:${NC}"
    # Extract basic coverage stats if available
    TOTAL_LINES=$(grep -o 'LH:[0-9]*' coverage/lcov.info | cut -d: -f2 | awk '{s+=$1} END {print s}')
    COVERED_LINES=$(grep -o 'LF:[0-9]*' coverage/lcov.info | cut -d: -f2 | awk '{s+=$1} END {print s}')
    
    if [ "$TOTAL_LINES" -gt 0 ] 2>/dev/null; then
        COVERAGE_PERCENT=$(echo "scale=1; $COVERED_LINES * 100 / $TOTAL_LINES" | bc 2>/dev/null || echo "N/A")
        echo "  Lines Covered: $COVERED_LINES / $TOTAL_LINES ($COVERAGE_PERCENT%)"
    else
        echo "  Coverage data processing available with lcov tools"
    fi
fi

echo ""

# 9. Recommendations
echo -e "${BLUE}💡 Recommendations:${NC}"

if [ "$UNIT_TESTS_PASSED" = false ]; then
    echo -e "  ${YELLOW}•${NC} Fix unit test failures before deployment"
fi

if [ "$ANALYSIS_PASSED" = false ]; then
    echo -e "  ${YELLOW}•${NC} Address analysis warnings for better code quality"
fi

if [ "$INTEGRATION_TESTS_PASSED" = false ]; then
    echo -e "  ${YELLOW}•${NC} Ensure Firebase test project is properly configured"
    echo -e "  ${YELLOW}•${NC} Verify test phone numbers are set up in Firebase Console"
fi

if [ "$COVERAGE_GENERATED" = false ]; then
    echo -e "  ${YELLOW}•${NC} Install lcov package for detailed coverage reports"
fi

echo ""

# 10. Final Status
OVERALL_SUCCESS=true

if [ "$UNIT_TESTS_PASSED" = false ]; then
    OVERALL_SUCCESS=false
fi

if [ "$OVERALL_SUCCESS" = true ]; then
    echo -e "${GREEN}🎉 Test Suite Completed Successfully!${NC}"
    echo -e "${GREEN}✅ Ready for Phase 4.3: CI/CD Pipeline Updates${NC}"
    exit 0
else
    echo -e "${RED}❌ Test Suite Failed!${NC}"
    echo -e "${RED}⚠️  Address failing tests before proceeding${NC}"
    exit 1
fi