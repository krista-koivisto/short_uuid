import 'package:short_uuid/short_uuid.dart';
import 'package:test/test.dart';

void main() {
  test('generates a random value', () {
    final short = ShortUuid();
    final translator = ShortUuid.init();
    expect(short.generate().length, greaterThan(0));
    expect(translator.generate().length, greaterThan(0));
    expect(translator.generate().length, greaterThan(0));
  });
  test('translates to shortened format', () {
    final translator = ShortUuid.init();
    expect(translator.toUUID('mhvXdrZT4jP5T8vBxuvm75'), 'a44521d0-0fb8-4ade-8002-3385545c3318');
  });
  test('translates from shortened format', () {
    final translator = ShortUuid.init();
    expect(translator.fromUUID('a44521d0-0fb8-4ade-8002-3385545c3318'), 'mhvXdrZT4jP5T8vBxuvm75');
  });
}
