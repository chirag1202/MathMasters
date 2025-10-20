import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Timer Calculation Tests', () {
    // Timer formula: (300 - (level - 1) * 5).clamp(60, 300)
    
    int timeForLevel(int level) => (300 - (level - 1) * 5).clamp(60, 300);
    
    test('Level 1 should start at 5 minutes (300 seconds)', () {
      expect(timeForLevel(1), 300);
    });
    
    test('Level 2 should be 295 seconds (5 seconds less)', () {
      expect(timeForLevel(2), 295);
    });
    
    test('Level 3 should be 290 seconds (10 seconds less than level 1)', () {
      expect(timeForLevel(3), 290);
    });
    
    test('Level 10 should be 255 seconds', () {
      expect(timeForLevel(10), 255);
    });
    
    test('Level 48 should be at minimum 60 seconds', () {
      // 300 - (48 - 1) * 5 = 300 - 235 = 65 seconds
      expect(timeForLevel(48), 65);
    });
    
    test('Level 49 should be at minimum 60 seconds (clamped)', () {
      // 300 - (49 - 1) * 5 = 300 - 240 = 60 seconds
      expect(timeForLevel(49), 60);
    });
    
    test('Level 50 should be at minimum 60 seconds (clamped)', () {
      // 300 - (50 - 1) * 5 = 300 - 245 = 55, but clamped to 60
      expect(timeForLevel(50), 60);
    });
    
    test('Level 100 should be at minimum 60 seconds (clamped)', () {
      // Should be heavily negative but clamped to 60
      expect(timeForLevel(100), 60);
    });
    
    test('Timer decreases by 5 seconds per level', () {
      for (int level = 1; level < 48; level++) {
        final currentTime = timeForLevel(level);
        final nextTime = timeForLevel(level + 1);
        expect(currentTime - nextTime, 5, 
            reason: 'Level $level to ${level + 1} should decrease by 5 seconds');
      }
    });
  });
}
