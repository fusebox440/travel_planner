# Contributing to Travel Planner

We love your input! We want to make contributing to Travel Planner as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## 🎯 Our Philosophy

Travel Planner is designed to be **accessible, engaging, and professional** - suitable for users of all ages and abilities. All contributions should align with these core values:

- **Accessibility First**: WCAG 2.1 AA compliance is mandatory
- **Child-Friendly Design**: Simple, intuitive, and delightfully animated
- **Performance Conscious**: Smooth 60fps animations and efficient memory usage
- **Professional Quality**: Enterprise-level code quality and documentation

## 🚀 Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### 1. Fork & Clone
```bash
git clone https://github.com/your-username/travel_planner.git
cd travel_planner
```

### 2. Set Up Development Environment
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Create a Branch
```bash
git checkout -b feature/amazing-new-feature
```

## 📝 Pull Request Process

1. **Branch Naming**: Use descriptive names
   - `feature/add-trip-sharing`
   - `fix/accessibility-contrast-issue`
   - `docs/update-setup-instructions`

2. **Code Standards**: Follow our coding standards
   - Dart/Flutter best practices
   - Accessibility guidelines
   - Performance optimizations
   - Comprehensive documentation

3. **Testing**: Ensure all tests pass
   ```bash
   flutter test
   flutter test integration_test/
   ```

4. **Accessibility**: Test with screen readers and high contrast mode

5. **Performance**: Verify 60fps animations and memory usage

6. **Documentation**: Update relevant documentation

## 🎨 UI/UX Guidelines

### Design System
- **Material Design 3**: Follow Material Design principles
- **5 Theme Support**: Ensure compatibility with all theme modes
- **Animation Guidelines**: Use our animation utilities for consistency
- **Touch Targets**: Minimum 48px touch targets for accessibility

### Accessibility Requirements
- **Screen Reader Support**: Proper semantic labeling
- **Keyboard Navigation**: All interactive elements must be keyboard accessible  
- **Color Contrast**: Minimum 4.5:1 ratio for normal text, 3:1 for large text
- **Motion Sensitivity**: Respect `prefers-reduced-motion` settings
- **Text Scaling**: Support 80%-200% text scaling

### Performance Standards
- **60fps Animations**: All animations must maintain 60fps
- **Memory Efficiency**: No memory leaks, efficient image caching
- **Loading Times**: Skeleton screens for loading states
- **Lazy Loading**: Large lists must use lazy loading

## 🔧 Code Style Guide

### Dart/Flutter Best Practices
```dart
// ✅ Good: Clear naming and documentation
/// Calculates the trip duration in days with accessibility announcement
int calculateTripDuration(DateTime start, DateTime end) {
  return end.difference(start).inDays;
}

// ❌ Bad: No documentation or accessibility consideration
int calc(DateTime s, DateTime e) {
  return e.difference(s).inDays;
}
```

### Accessibility Code Standards
```dart
// ✅ Good: Proper accessibility labels
Semantics(
  label: 'Add new trip button',
  hint: 'Double tap to create a new trip',
  button: true,
  child: FloatingActionButton(
    onPressed: _addTrip,
    child: Icon(Icons.add),
  ),
)

// ❌ Bad: No accessibility information
FloatingActionButton(
  onPressed: _addTrip,
  child: Icon(Icons.add),
)
```

### Animation Standards
```dart
// ✅ Good: Using our animation utilities with reduced motion support
PlayfulTapContainer(
  onTap: () => navigateToTrip(),
  child: TripCard(trip: trip),
)

// ❌ Bad: Hard-coded animation without accessibility considerations
GestureDetector(
  onTap: () => navigateToTrip(),
  child: AnimatedScale(
    duration: Duration(milliseconds: 200),
    scale: _isPressed ? 0.95 : 1.0,
    child: TripCard(trip: trip),
  ),
)
```

## 🧪 Testing Guidelines

### Unit Tests
- Test business logic thoroughly
- Mock external dependencies
- Test accessibility features

### Widget Tests
- Test UI components
- Verify accessibility labels
- Test animations and interactions

### Integration Tests
- Test complete user flows
- Verify accessibility compliance
- Test performance benchmarks

## 🎮 Feature Development

### Gamification Features
When adding gamification elements:
- Ensure badges are meaningful and achievable
- Add celebration animations using our animation system
- Integrate with the existing points and level system
- Test with children to ensure engagement without overwhelm

### Accessibility Features
All new features must include:
- Screen reader support
- Keyboard navigation
- High contrast theme compatibility
- Proper focus management
- Voice input support (where applicable)

## 📚 Documentation Standards

### Code Documentation
```dart
/// Manages travel itinerary with accessibility and gamification integration.
/// 
/// Provides comprehensive itinerary management including:
/// - Day-by-day activity planning with screen reader support
/// - Gamification rewards for trip planning milestones
/// - Performance-optimized list rendering for large itineraries
/// 
/// Example usage:
/// ```dart
/// final itinerary = ItineraryService();
/// await itinerary.addActivity(activity, accessibilityLabel: 'Beach visit added');
/// ```
class ItineraryService {
  // Implementation...
}
```

### Commit Messages
Use conventional commits format:
```
feat(accessibility): add voice input support for trip creation

- Implemented voice-to-text for trip name and description
- Added proper accessibility announcements
- Integrated with existing keyboard navigation
- Added unit tests for voice input functionality

Closes #123
```

## 🐛 Bug Reports

Use our bug report template and include:

- **Device/Platform**: iOS/Android/Web version and device details
- **Steps to Reproduce**: Clear step-by-step instructions
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Accessibility Impact**: How does this affect users with disabilities
- **Screenshots/Videos**: Visual evidence of the issue
- **Theme Mode**: Which theme mode was active when the bug occurred

## 💡 Feature Requests

Use our feature request template and include:

- **User Story**: Clear description from user perspective
- **Accessibility Considerations**: How will this work with screen readers, etc.
- **Gamification Integration**: How could this integrate with the badge system
- **Performance Impact**: Potential performance considerations
- **Child-Friendliness**: How will this appeal to younger users
- **Technical Approach**: Suggested implementation approach

## 🎯 Priority Areas

We're particularly interested in contributions for:

### High Priority
- **Accessibility Improvements**: WCAG 2.1 AAA features
- **Performance Optimizations**: Memory usage, animation performance
- **Gamification Enhancements**: New badges, level system improvements
- **Child Safety Features**: Age-appropriate content and interactions

### Medium Priority
- **New Travel Features**: Trip sharing, collaboration tools
- **Enhanced Animations**: More delightful micro-interactions
- **Platform Improvements**: Better web/desktop experiences
- **Internationalization**: Multi-language support

### Low Priority
- **Advanced Features**: AI integration, advanced analytics
- **Experimental UI**: New design patterns and components
- **Developer Tools**: Enhanced debugging and development tools

## 📞 Communication

### Getting Help
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: For security issues and sensitive topics

### Community Guidelines
- Be respectful and inclusive
- Focus on accessibility and user needs
- Provide constructive feedback
- Help others learn and grow

## 🏆 Recognition

Contributors will be:
- Listed in our README.md contributors section
- Featured in release notes for significant contributions
- Invited to join our core team for outstanding contributions
- Recognized for accessibility and performance improvements

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🌟 Thank You

Thank you for contributing to Travel Planner! Together, we're building a travel app that's accessible, engaging, and helpful for travelers of all ages and abilities.

---

**Remember**: Every contribution, no matter how small, makes Travel Planner better for everyone. Whether it's fixing a typo, improving accessibility, or adding a new feature, your work matters! 🚀
