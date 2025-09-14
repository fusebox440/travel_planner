# Test Configuration for Travel Planner

## Overview
This document outlines the testing strategy and configuration for the Firebase Phone Authentication implementation in Travel Planner.

## Test Structure

### Unit Tests (`test/`)
- **`authentication_test.dart`** - Core authentication service tests
- **`hotfix_test.dart`** - Tests for addCompanion and fetchPackingList safety fixes
- **Mock Generation** - Using `mockito` and `build_runner`

### Integration Tests (`integration_test/`)
- **`authentication_test.dart`** - End-to-end authentication flow tests
- **UI Testing** - Complete user journey from entry to profile setup

## Test Categories

### 🔐 Authentication Service Tests
- Phone number validation
- OTP verification flow  
- User profile management
- Error handling scenarios
- Authentication state management

### 🛠️ Hotfix Tests (Critical Safety Fixes)
- `addCompanion` null safety and validation
- `fetchPackingList` data integrity
- Trip association validation
- Firestore error handling

### 🎯 Integration Tests
- Complete authentication flow
- UI interaction testing
- State persistence across app restarts
- Error scenario handling
- Test phone number validation

## Test Data

### Firebase Test Configuration
```yaml
Test Phone Numbers (configured in Firebase Console):
  +1 234 567 8901 → 123456
  +91 9876543210  → 654321  
  +44 7700 900123 → 999999
```

### Test Users
```yaml
New User Flow:
  - Phone: +1 234 567 8901
  - OTP: 123456
  - Profile: Complete setup required

Existing User Flow:
  - Phone: +91 9876543210
  - OTP: 654321
  - Profile: Skip setup, direct to app
```

## Running Tests

### Quick Test Run
```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Comprehensive Test Suite
```bash
# PowerShell (Windows)
.\scripts\run_tests.ps1

# Bash (Linux/Mac)
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Authentication tests only
flutter test test/authentication_test.dart

# Hotfix tests only
flutter test test/hotfix_test.dart

# Integration tests only
flutter test integration_test/authentication_test.dart
```

## Dependencies

### Test Dependencies (`pubspec.yaml`)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  mocktail: ^1.0.3
  build_runner: ^2.4.7
```

### Mock Generation
```bash
# Generate mocks for testing
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Test Coverage

### Coverage Goals
- **Authentication Service**: >90% coverage
- **Hotfix Functions**: 100% coverage (critical safety)
- **UI Components**: >70% coverage
- **Error Handling**: 100% coverage

### Generating Coverage Reports
```bash
# Generate coverage data
flutter test --coverage

# View in VS Code (with Coverage Gutters extension)
# Install: ext install ryanluker.vscode-coverage-gutters

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

### Pre-commit Hooks
```bash
# Run tests before each commit
flutter analyze && flutter test
```

## Test Environment Setup

### Firebase Configuration
1. **Test Project**: Use separate Firebase project for testing
2. **Test Phone Numbers**: Configure in Firebase Console
3. **Security Rules**: Permissive rules for testing environment
4. **Test Data**: Isolated from production data

### Local Development
```bash
# Set up test environment
export FLUTTER_TEST=true
export FIREBASE_PROJECT_ID=travel-planner-test

# Run tests with test config
flutter test --dart-define=FLUTTER_TEST=true
```

## Debugging Tests

### Common Issues
1. **Mock Generation Errors**
   - Solution: Run `flutter packages pub run build_runner clean`
   - Then: `flutter packages pub run build_runner build`

2. **Firebase Connection Timeouts**
   - Solution: Check internet connection
   - Verify Firebase project configuration

3. **Integration Test Failures**
   - Solution: Ensure test phone numbers are configured
   - Check Firebase Authentication is enabled

### Debug Mode
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test with debugging
flutter test test/authentication_test.dart --name "should successfully sign in"
```

## Test Data Management

### Test Data Cleanup
```dart
// Automatic cleanup in tearDown
tearDown(() async {
  // Clean up test users
  // Reset test state
});
```

### Test Isolation
- Each test creates its own mock data
- No shared state between tests
- Atomic test execution

## Performance Testing

### Load Testing
```dart
test('should handle multiple concurrent auth requests', () async {
  // Test concurrent authentication attempts
  final futures = List.generate(10, (index) => 
    authService.signInWithSmsCode(
      verificationId: 'test_$index',
      smsCode: '123456'
    )
  );
  
  final results = await Future.wait(futures);
  expect(results.length, equals(10));
});
```

### Memory Testing
```dart
test('should not leak memory during auth flow', () async {
  // Monitor memory usage during authentication
  // Verify proper cleanup
});
```

## Security Testing

### Input Validation
```dart
test('should reject malicious phone number inputs', () async {
  final maliciousInputs = [
    '"><script>alert("xss")</script>',
    'DROP TABLE users;',
    '../../../etc/passwd',
  ];
  
  for (final input in maliciousInputs) {
    expect(
      () => authService.sendPhoneVerification(phoneNumber: input),
      throwsA(isA<ArgumentError>())
    );
  }
});
```

### Authentication Security
```dart
test('should prevent authentication bypass', () async {
  // Test that invalid tokens are rejected
  // Verify proper session management
});
```

## Accessibility Testing

### Screen Reader Support
```dart
testWidgets('should provide proper accessibility labels', (tester) async {
  // Test semantic labels
  // Verify screen reader compatibility
});
```

### Keyboard Navigation
```dart
testWidgets('should support keyboard navigation', (tester) async {
  // Test tab navigation
  // Verify keyboard shortcuts
});
```

## Documentation Testing

### Code Examples
- All code examples in documentation are tested
- API examples verified for correctness
- Setup instructions validated

### Test Documentation
- Each test includes clear description
- Test data and expectations documented
- Failure scenarios documented

---

*Last Updated: Phase 4.2 - Testing Implementation*
*Next: Phase 4.3 - CI/CD Pipeline Updates*