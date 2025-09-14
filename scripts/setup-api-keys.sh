#!/bin/bash

# API Keys Setup Script for Travel Planner
# This script helps you set up API keys securely

echo "🔐 Travel Planner API Keys Setup"
echo "================================="
echo ""

# Check if api_keys.dart already exists
if [ -f "lib/core/config/api_keys.dart" ]; then
    echo "⚠️  api_keys.dart already exists!"
    read -p "Do you want to overwrite it? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 0
    fi
fi

# Copy template
echo "📋 Copying API keys template..."
cp lib/core/config/api_keys_template.dart lib/core/config/api_keys.dart

if [ $? -eq 0 ]; then
    echo "✅ Template copied successfully!"
else
    echo "❌ Failed to copy template. Make sure you're in the project root directory."
    exit 1
fi

echo ""
echo "📝 Next steps:"
echo "1. Edit lib/core/config/api_keys.dart"
echo "2. Replace all placeholder values with your actual API keys"
echo "3. See docs/api-keys-setup.md for detailed instructions"
echo ""
echo "📚 Required API keys:"
echo "   • OpenWeatherMap API (weather data)"
echo "   • Google Maps API (maps and places)"
echo "   • Transit API (public transport - optional)"
echo "   • Translation API (multi-language - optional)"
echo ""
echo "🛡️  Security reminder:"
echo "   • Never commit api_keys.dart to git"
echo "   • It's already in .gitignore for safety"
echo ""
echo "🚀 Run 'flutter run' after adding your API keys!"