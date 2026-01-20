#!/bin/bash

# Script to run tests and display a formatted summary

set -e

echo "🧪 Running Flutter tests..."
echo ""

# Run tests with expanded reporter for better test name visibility
TEST_OUTPUT=$(flutter test --reporter expanded 2>&1)
TEST_EXIT_CODE=$?

# Extract test results - Flutter test output can have different formats
# Try multiple patterns to catch different output formats
# Common formats:
# - "00:01 +2: All tests passed!"
# - "+2: All tests passed!"
# - "2 passed"
# - "All 2 tests passed"

# Extract passed tests - try multiple patterns
PASSED=""
if echo "$TEST_OUTPUT" | grep -qE '\+[0-9]+:'; then
    PASSED=$(echo "$TEST_OUTPUT" | grep -oE '\+[0-9]+:' | grep -oE '[0-9]+' | tail -1)
fi
if [ -z "$PASSED" ]; then
    PASSED=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+\s+passed' | grep -oE '[0-9]+' | head -1)
fi
if [ -z "$PASSED" ]; then
    PASSED=$(echo "$TEST_OUTPUT" | grep -oE 'All\s+[0-9]+\s+test' | grep -oE '[0-9]+' | head -1)
fi
PASSED=${PASSED:-0}

# Extract failed tests
FAILED=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+\s+failed' | grep -oE '[0-9]+' | head -1)
FAILED=${FAILED:-0}

# Extract skipped tests
SKIPPED=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+\s+skipped' | grep -oE '[0-9]+' | head -1)
SKIPPED=${SKIPPED:-0}

# Calculate total tests (ensure numeric values)
PASSED=$((PASSED + 0))
FAILED=$((FAILED + 0))
SKIPPED=$((SKIPPED + 0))
TOTAL=$((PASSED + FAILED + SKIPPED))

# Display summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 TEST SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

printf "✅ Passed:   %d\n" "$PASSED"
printf "❌ Failed:   %d\n" "$FAILED"
printf "⏭️  Skipped:  %d\n" "$SKIPPED"
printf "📈 Total:     %d\n" "$TOTAL"
echo ""

# Extract test names from Flutter test output
# Flutter outputs test names in various formats:
# - "+1: test name" (compact mode)
# - "✓ test name" (expanded mode)
# - "test('description', ...)" (in source)
# - Group names: "group('GroupName', ...)"

# Extract passed test names (look for ✓ or +N: patterns)
PASSED_TEST_NAMES=$(echo "$TEST_OUTPUT" | grep -E '^\s*\+[0-9]+:|^\s*✓' | \
    sed -E 's/^\s*\+[0-9]+:\s*//' | \
    sed -E 's/^\s*✓\s*//' | \
    sed -E 's/\s*$//' | \
    grep -v '^$' || true)

# Extract failed test names (look for ✗ or FAILED: patterns)
FAILED_TEST_NAMES=$(echo "$TEST_OUTPUT" | grep -E '^\s*✗|^\s*×|FAILED:' | \
    sed -E 's/^\s*[✗×]\s*//' | \
    sed -E 's/FAILED:\s*//' | \
    sed -E 's/\s*$//' | \
    grep -v '^$' || true)

# Extract test descriptions from test files if we can't get them from output
# This is a fallback that looks for test('description', ...) patterns
if [ -z "$PASSED_TEST_NAMES" ] && [ "$PASSED" -gt 0 ]; then
    PASSED_TEST_NAMES=$(find test -name "*_test.dart" -exec grep -h "test(" {} \; | \
        sed -E "s/.*test\(['\"]([^'\"]+)['\"].*/\1/" | \
        head -n "$PASSED" || true)
fi

# Display test names
if [ "$PASSED" -gt 0 ] && [ -n "$PASSED_TEST_NAMES" ]; then
    echo "✅ Passed Tests:"
    echo "$PASSED_TEST_NAMES" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "   ✓ $line"
        fi
    done
    echo ""
fi

if [ "$FAILED" -gt 0 ] && [ -n "$FAILED_TEST_NAMES" ]; then
    echo "❌ Failed Tests:"
    echo "$FAILED_TEST_NAMES" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "   ✗ $line"
        fi
    done
    echo ""
fi

# If we have tests but couldn't extract names, show a message
if [ "$TOTAL" -gt 0 ] && [ -z "$PASSED_TEST_NAMES" ] && [ -z "$FAILED_TEST_NAMES" ]; then
    echo "ℹ️  Test names not available in output format"
    echo "   Run 'flutter test' directly to see individual test names"
    echo ""
fi

# Determine status message
if [ "$TOTAL" -eq 0 ]; then
    echo "⚠️  No tests found or tests didn't run properly."
    echo "   Check the output above for errors."
elif [ "$FAILED" -gt 0 ]; then
    echo "⚠️  Some tests failed. Check the output above for details."
elif [ "$TEST_EXIT_CODE" -eq 0 ]; then
    echo "🎉 All tests passed!"
else
    echo "⚠️  Tests completed with warnings. Check the output above."
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit $TEST_EXIT_CODE
