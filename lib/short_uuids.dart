library short_uuid;

import 'dart:math';

import 'package:any_base/any_base.dart';
import 'package:uuid/uuid.dart';

typedef Generator = String Function();
typedef Translator = String Function(String);

class PaddingParams {
  final bool consistentLength;
  final int shortIdLength;
  final paddingChar;
  const PaddingParams({
    this.consistentLength = true,
    required this.shortIdLength,
    this.paddingChar = '0',
  });
}

class Convertor {
  final Generator generate;
  final Generator uuid;
  final Translator fromUUID;
  final Translator toUUID;
  final String alphabet;
  const Convertor({
    required this.generate,
    required this.uuid,
    required this.fromUUID,
    required this.toUUID,
    required this.alphabet
  });
}

class _Constants {
  final flickrBase58 = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
  final cookieBase90 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#\$%&'()*+-./:<=>?@[]^_`{|}~";
  const _Constants();
}

class ShortUuid {
  static const constants = _Constants();
  static final uuidV4 = Uuid().v4;

  // A default generator, instantiated only if used.
  static Convertor? _toFlickr;

  // Expose the UUIDv4 generator.
  static String Function({Map<String, dynamic> options}) get uuid => uuidV4;

  /// Initialize the default translator.
  static Convertor init([String? toAlphabet, PaddingParams? options]) =>
      makeConvertor(toAlphabet, options);

  const ShortUuid();

  /// Takes a UUID, strips the dashes, and translates.
  ///
  /// Strips [longId] of dashes and passes it to the [translator] function to be
  /// converted into shortened form and returns the result.
  ///
  /// Adds padding in front of the resulting short form if [paddingParams] has
  /// `consistentLength` set to true.
  static String shortenUUID(String longId, Translator translator,
      [PaddingParams? paddingParams]) {
    final translated = translator(longId.toLowerCase().replaceAll('-', ''));

    if (paddingParams == null || !paddingParams.consistentLength)
      return translated;

    return translated.padLeft(
      paddingParams.shortIdLength,
      paddingParams.paddingChar,
    );
  }

  /// Translate back to hex and turn back into UUID format, adding dashes.
  ///
  /// Passes [shortId] to the [translator] function to be expanded to hex.
  /// Dashes are then added to construct a standard uuid string and the
  /// resulting `String` is returned.
  static String enlargeUUID(String shortId, Translator translator) {
    final uu1 = translator(shortId).padLeft(32, '0');

    // Join the zero padding and the UUID and then slice it up with match
    final m = RegExp(r'(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})').firstMatch(uu1);

    // Accumulate the matches and join them.
    return [m![1], m[2], m[3], m[4], m[5]].join('-');
  }

  /// Calculate the length of the shortened id.
  static int getShortIdLength(alphabetLength) =>
      (log(pow(2.0, 128.0)) / log(alphabetLength.toDouble())).ceil();

  /// Create a custom convertor using a specified alphabet.
  static Convertor makeConvertor([String? toAlphabet, PaddingParams? options]) {
    // Default to Flickr 58
    final useAlphabet = toAlphabet ?? constants.flickrBase58;

    // Default to baseOptions
    final selectedOptions = options ?? PaddingParams(
      shortIdLength: getShortIdLength(useAlphabet.length),
      paddingChar: useAlphabet[0],
    );

    // Check alphabet for duplicate entries
    if (Set.from(useAlphabet.split('')).length != useAlphabet.length) {
      throw FormatException(
          'The provided Alphabet has duplicate characters resulting in unreliable results');
    }

    // UUIDs are in hex, so we translate to and from.
    final anyBase = AnyBase(AnyBase.hex, useAlphabet);
    final fromHex = anyBase.convert;
    final toHex = anyBase.revert;
    final generate = () => shortenUUID(uuidV4(), fromHex, options);

    return Convertor(
      generate: generate,
      uuid: uuidV4,
      fromUUID: (uuid) => shortenUUID(uuid, fromHex, selectedOptions),
      toUUID: (shortUuid) => enlargeUUID(shortUuid, toHex),
      alphabet: useAlphabet,
    );
  }

  // Provide a generic generator
  String generate() {
    if (_toFlickr == null) {
      // Generate on first use;
      _toFlickr = makeConvertor(constants.flickrBase58);
    }
    return shortenUUID(uuid(), _toFlickr!.fromUUID);
  }
}
