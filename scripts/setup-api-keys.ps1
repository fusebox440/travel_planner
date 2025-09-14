# API Keys Setup Script for Travel Planner
# This PowerShell script helps you set up API keys securely

Write-Host "🔐 Travel Planner API Keys Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if api_keys.dart already exists
if (Test-Path "lib/core/config/api_keys.dart") {
    Write-Host "⚠️  api_keys.dart already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
    if ($overwrite -notmatch '^[Yy]$') {
        Write-Host "❌ Setup cancelled." -ForegroundColor Red
        exit 0
    }
}

# Copy template
Write-Host "📋 Copying API keys template..." -ForegroundColor Blue
try {
    Copy-Item "lib/core/config/api_keys_template.dart" "lib/core/config/api_keys.dart"
    Write-Host "✅ Template copied successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to copy template. Make sure you're in the project root directory." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit lib/core/config/api_keys.dart"
Write-Host "2. Replace all placeholder values with your actual API keys"
Write-Host "3. See docs/api-keys-setup.md for detailed instructions"
Write-Host ""
Write-Host "📚 Required API keys:" -ForegroundColor Blue
Write-Host "   • OpenWeatherMap API (weather data)"
Write-Host "   • Google Maps API (maps and places)"
Write-Host "   • Transit API (public transport - optional)"
Write-Host "   • Translation API (multi-language - optional)"
Write-Host ""
Write-Host "🛡️  Security reminder:" -ForegroundColor Magenta
Write-Host "   • Never commit api_keys.dart to git"
Write-Host "   • It's already in .gitignore for safety"
Write-Host ""
Write-Host "🚀 Run 'flutter run' after adding your API keys!" -ForegroundColor Green