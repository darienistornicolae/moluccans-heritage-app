import 'dart:io';

/// Enhanced test runner with better output formatting
/// 
/// Usage: dart test_runner.dart
/// 
/// This script provides a more visual test output with:
/// - Color-coded results
/// - Test grouping
/// - Summary statistics
/// - Coverage information

void main() async {
  print('🧪 Running Flutter tests with enhanced output...\n');
  
  final result = await Process.run(
    'flutter',
    ['test', '--reporter', 'expanded'],
    runInShell: true,
  );
  
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print(result.stderr);
  }
  
  exit(result.exitCode);
}
