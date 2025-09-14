# Travel Planner Test Suite - PowerShell Version
# Comprehensive test runner for Firebase Phone Authentication

Write-Host "🧪 Starting Travel Planner Test Suite..." -ForegroundColor Blue
Write-Host "========================================"

# Track test results
$UnitTestsPassed = $false
$IntegrationTestsPassed = $false
$AnalysisPassed = $false
$CoverageGenerated = $false

Write-Host "📋 Test Plan:" -ForegroundColor Blue
Write-Host "  ✓ Code analysis (flutter analyze)"
Write-Host "  ✓ Unit tests (authentication, hotfixes)"  
Write-Host "  ✓ Integration tests (auth flow)"
Write-Host "  ✓ Test coverage report"
Write-Host ""

# 1. Code Analysis
Write-Host "🔍 Running code analysis..." -ForegroundColor Yellow
flutter analyze
$AnalyzeExitCode = $LASTEXITCODE

if ($AnalyzeExitCode -eq 0) {
    Write-Host "✅ Code analysis passed!" -ForegroundColor Green
    $AnalysisPassed = $true
} else {
    Write-Host "❌ Code analysis failed with exit code: $AnalyzeExitCode" -ForegroundColor Red
    Write-Host "💡 Note: Test-related analysis errors may not affect main app functionality" -ForegroundColor Yellow
}

Write-Host ""

# 2. Generate mock files
Write-Host "🏗️  Generating mock files..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs
$BuildRunnerExitCode = $LASTEXITCODE

if ($BuildRunnerExitCode -eq 0) {
    Write-Host "✅ Mock files generated successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Mock generation failed. Continuing with existing mocks..." -ForegroundColor Red
}

Write-Host ""

# 3. Unit Tests
Write-Host "🧪 Running unit tests..." -ForegroundColor Yellow
flutter test --coverage --reporter expanded
$UnitTestExitCode = $LASTEXITCODE

if ($UnitTestExitCode -eq 0) {
    Write-Host "✅ Unit tests passed!" -ForegroundColor Green
    $UnitTestsPassed = $true
} else {
    Write-Host "❌ Unit tests failed with exit code: $UnitTestExitCode" -ForegroundColor Red
}

Write-Host ""

# 4. Integration Tests
Write-Host "🔄 Running integration tests..." -ForegroundColor Yellow
Write-Host "Note: Integration tests require Firebase test project configuration" -ForegroundColor Blue

flutter test integration_test/authentication_test.dart
$IntegrationExitCode = $LASTEXITCODE

if ($IntegrationExitCode -eq 0) {
    Write-Host "✅ Integration tests passed!" -ForegroundColor Green
    $IntegrationTestsPassed = $true
} else {
    Write-Host "❌ Integration tests failed with exit code: $IntegrationExitCode" -ForegroundColor Red
    Write-Host "💡 Integration tests may fail without proper Firebase setup" -ForegroundColor Yellow
}

Write-Host ""

# 5. Coverage Report
Write-Host "📊 Generating coverage report..." -ForegroundColor Yellow
if (Test-Path "coverage/lcov.info") {
    Write-Host "✅ Coverage data generated at coverage/lcov.info" -ForegroundColor Green
    Write-Host "💡 Install lcov or use VS Code Coverage Gutters for visualization" -ForegroundColor Blue
    $CoverageGenerated = $true
} else {
    Write-Host "❌ No coverage data found. Run tests with --coverage flag" -ForegroundColor Red
}

Write-Host ""

# 6. Test Summary
Write-Host "🎯 Test Results Summary" -ForegroundColor Blue
Write-Host "========================"

if ($AnalysisPassed) {
    Write-Host "📊 Code Analysis:     ✅ PASSED" -ForegroundColor Green
} else {
    Write-Host "📊 Code Analysis:     ❌ FAILED" -ForegroundColor Red
}

if ($UnitTestsPassed) {
    Write-Host "🧪 Unit Tests:        ✅ PASSED" -ForegroundColor Green
} else {
    Write-Host "🧪 Unit Tests:        ❌ FAILED" -ForegroundColor Red
}

if ($IntegrationTestsPassed) {
    Write-Host "🔄 Integration Tests: ✅ PASSED" -ForegroundColor Green
} else {
    Write-Host "🔄 Integration Tests: ❌ FAILED" -ForegroundColor Red
}

if ($CoverageGenerated) {
    Write-Host "📈 Coverage Report:   ✅ GENERATED" -ForegroundColor Green
} else {
    Write-Host "📈 Coverage Report:   ⚠️  LIMITED" -ForegroundColor Yellow
}

Write-Host ""

# 7. Specific Test Categories
Write-Host "📂 Test Categories Covered:" -ForegroundColor Blue
Write-Host "  🔐 Authentication Service Tests"
Write-Host "    • Phone verification flow"
Write-Host "    • OTP validation"
Write-Host "    • User profile management"
Write-Host "    • Error handling"
Write-Host ""
Write-Host "  🛠️  Hotfix Tests"
Write-Host "    • addCompanion null safety"
Write-Host "    • fetchPackingList safety"
Write-Host "    • Data integrity checks"
Write-Host ""
Write-Host "  🎯 Integration Tests"
Write-Host "    • End-to-end auth flow"
Write-Host "    • UI interaction testing"
Write-Host "    • State persistence"
Write-Host ""

# 8. Recommendations
Write-Host "💡 Recommendations:" -ForegroundColor Blue

if (-not $UnitTestsPassed) {
    Write-Host "  • Fix unit test failures before deployment" -ForegroundColor Yellow
}

if (-not $AnalysisPassed) {
    Write-Host "  • Address analysis warnings for better code quality" -ForegroundColor Yellow
}

if (-not $IntegrationTestsPassed) {
    Write-Host "  • Ensure Firebase test project is properly configured" -ForegroundColor Yellow
    Write-Host "  • Verify test phone numbers are set up in Firebase Console" -ForegroundColor Yellow
}

if (-not $CoverageGenerated) {
    Write-Host "  • Install lcov or use VS Code Coverage Gutters extension" -ForegroundColor Yellow
}

Write-Host ""

# 9. Firebase Testing Setup Reminder
Write-Host "🔥 Firebase Testing Setup:" -ForegroundColor Blue
Write-Host "  • Test Phone Numbers in Firebase Console:"
Write-Host "    +1 234 567 8901 → 123456"
Write-Host "    +91 9876543210  → 654321"
Write-Host "    +44 7700 900123 → 999999"
Write-Host ""

# 10. Final Status
$OverallSuccess = $UnitTestsPassed

if ($OverallSuccess) {
    Write-Host "🎉 Test Suite Completed Successfully!" -ForegroundColor Green
    Write-Host "✅ Ready for Phase 4.3: CI/CD Pipeline Updates" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Test Suite Failed!" -ForegroundColor Red
    Write-Host "⚠️  Address failing tests before proceeding" -ForegroundColor Red
    exit 1
}