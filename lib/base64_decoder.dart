library base64_decoder;
import 'dart:typed_data';



final Base64Decoder base64decoder = new Base64Decoder();

/**
 * Written by Don Olmstead I think, thanks!
 *
 *
 */

/// Decodes a raw base64 string.
///
/// Base64 is an encoding scheme that represents binary data as an ASCII
/// string. This is used to transfer binary data within text. As an example an image
/// can be embedded within a HTML page by Base64 encoding it.
///
/// The [Base64Decoder] reads raw strings, meaning it does not account for or recognize
/// line separators. This means it cannot be used for decoding MIME transfers.
class Base64Decoder {
  /// The table used to decode the string.
  List<int> _decodingTable;

  /// Creates an instance of the Base64Decoder class.
  Base64Decoder() {
    _createDecodingTable();
  }

  int getDecodeLength(String encoded) => _getDecodedBufferSize(encoded);

  /// Decodes the [encoded] string into an [ArrayBuffer].
  ByteBuffer decode(String encoded) {
    assert (encoded.length % 4 == 0);
    // Create the buffer to store the decoded data into
    int decodedLength = _getDecodedBufferSize(encoded);
    Uint8List decoded = new Uint8List(decodedLength);

    int decodeIndex = 0;
    int encodeIndex = 0;
    int encodeLengthMinus4 = encoded.length - 4;

    int sextet0;
    int sextet1;
    int sextet2;
    int sextet3;
    int triple;

    // Run through everything but the last block of data
    // This makes it so padding can be ignored within this loop
    while (encodeIndex < encodeLengthMinus4) {
      sextet0 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 18;
      sextet1 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 12;
      sextet2 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 6;
      sextet3 = _decodingTable[encoded.codeUnitAt(encodeIndex++)];
      triple = sextet0 | sextet1 | sextet2 | sextet3;

      decoded[decodeIndex++] = (triple & 0xff0000) >> 16;
      decoded[decodeIndex++] = (triple & 0xff00) >> 8;
      decoded[decodeIndex++] = (triple & 0xff);
    }

    // Decode the last block of data
    sextet0 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 18;
    sextet1 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 12;
    sextet2 = _decodingTable[encoded.codeUnitAt(encodeIndex++)] << 6;
    sextet3 = _decodingTable[encoded.codeUnitAt(encodeIndex++)];
    triple = sextet0 | sextet1 | sextet2 | sextet3;

    decoded[decodeIndex++] = (triple & 0xff0000) >> 16;

    if (decodedLength > decodeIndex) {
      decoded[decodeIndex++] = (triple & 0xff00) >> 8;

      if (decodedLength > decodeIndex) {
        decoded[decodeIndex++] = (triple & 0xff);
      }
    }

    // Return the ArrayBuffer
    return decoded.buffer;
  }

  /// Creates a table used to decode Base64 values.
  void _createDecodingTable() {
    // Create the encoding table first
    final List<int> encodingTable = [
    // A-Z [65-90]
    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
     // a-z [97-122]
    97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
     // 0-9 [48-57]
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
     // +
    43,
     // /
    47
    ];

    // Generate the decoding table
    _decodingTable = new List<int>.filled(256, 0);

    int encodingTableLength = encodingTable.length;

    for (int i = 0; i < encodingTableLength; ++i) {
      _decodingTable[encodingTable[i]] = i;
    }
  }

  /// Computes the size needed to store the decoded data.
  ///
  /// Base64 encodes 4 bytes for each 3 bytes in the original data. Additionally
  /// '=' is used as a padding character when the total number of bytes is not
  /// a multiple of 3.
  static int _getDecodedBufferSize(String encoded) {
    int encodedLength = encoded.length;

    // For every 4 bytes of encoded data there is 3 bytes of decoded data
    int decodeLength = (encodedLength ~/ 4) * 3;

    // Check for padding
    if (encoded[encodedLength - 1] != '=') {
      return decodeLength;
    }

    // See if there's 2 or 1 bytes of padding
    return decodeLength - ((encoded[encodedLength - 2] == '=') ? 2 : 1);
  }
}
