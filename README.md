# Short UUID

Generate short UUIDs or translate standard UUIDs into shorter formats
and back.

This is as direct a conversion as is possible in Dart from the node
package [short-uuid](https://github.com/oculus42/short-uuid).

## Examples

The API is very similar to the npm package with only some minor changes
required in Dart.

### Quick Start

```dart
const short = ShortUuid();

// Quick start with flickrBase58 format
short.generate(); // 73WakrfVbNJBaAmhQtEeDv
```

#### Detailed

Short UUID starts with RFC4122 v4-compliant UUIDs and translates them
into other, usually shorter formats. It also provides translators to
convert back and forth from RFC compliant UUIDs to the shorter formats.

Formats return consistent-length values unless specifically requested
otherwise. This is done by padding the start with the first ([0])
character in the alphabet. Previous versions can translate padded
formats back to UUID.

In short, it works exactly like its node counterpart.

```dart
// ShortUuid is better initiated through a call to `init` than by
// creating a new instance.
final translator = ShortUuid.init(); // Defaults to flickrBase58
final decimalTranslator = ShortUuid.init("0123456789"); // Provide a specific alphabet for translation
final cookieTranslator = ShortUuid.init(ShortUuid.constants.cookieBase90); // Use a constant for translation

// Generate a shortened v4 UUID
translator.generate(); // mhvXdrZT4jP5T8vBxuvm75

// Translate UUIDs to and from the shortened format
translator.toUUID(shortId); // a44521d0-0fb8-4ade-8002-3385545c3318
translator.fromUUID(regularUUID); // mhvXdrZT4jP5T8vBxuvm75

// Generate plain UUIDs
// - From the library without creating a translator
ShortUuid.uuid(); // fd5c084c-ff7c-4651-9a52-37096242d81c
// - Each translator provides the uuid.v4() function, too
translator.uuid(); // 3023b0f5-ec55-4e75-9cd8-104700698052

// See the alphabet used by a translator
translator.alphabet;

// View the constants
short.constants.flickrBase58; // Avoids similar characters (0/O, 1/I/l, etc.)
short.constants.cookieBase90; // Safe for HTTP cookies values for smaller IDs.
```

#### Differences

There are some slight differences between this project and the node
version ([short-uuid](https://github.com/oculus42/short-uuid)) by
oculus42.

 * Most notable is that you have to call an init function to get a
translator. This is because `ShortUuid` is a class and not a function.
 * There is no `translator.new()`. This is because `new` is a reserved
word in Dart. Instead, `translator.generate()` can be used. The
`generate` alias exists in the node version as well.

## Attributions

This is a direct conversion of Samuel Rouse's (aka oculus42) npm package
[short-uuid](https://github.com/oculus42/short-uuid) to Dart. A copy of
the project's license can be found in the [LICENSE](LICENSE) file under
the section `short-uuid`.
