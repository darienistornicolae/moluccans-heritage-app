#!/bin/bash

# Script to run tests with coverage and generate HTML reports

set -e

echo "🧪 Running Flutter tests with coverage..."
flutter test --coverage

echo "📊 Generating HTML coverage report..."

# Check if lcov is installed
if ! command -v genhtml &> /dev/null; then
    echo "⚠️  genhtml not found. Installing lcov..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew not found. Please install lcov manually:"
            echo "   brew install lcov"
            exit 1
        fi
        brew install lcov
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get update && sudo apt-get install -y lcov
    else
        echo "❌ Please install lcov manually for your OS"
        exit 1
    fi
fi

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html --no-function-coverage --no-branch-coverage

echo "✅ Coverage report generated at: coverage/html/index.html"
echo "📂 Open it in your browser:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage/html/index.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open coverage/html/index.html 2>/dev/null || echo "   file://$(pwd)/coverage/html/index.html"
else
    echo "   file://$(pwd)/coverage/html/index.html"
fi
