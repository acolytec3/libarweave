import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String api_url = 'http://arweave.net';
List peers;

/// Returns a list of the IP addresses of all known peer nodes in string format.
Future<List> getPeers() async {
  List peers;
  final response = await http.get(api_url + '/peers');
  try {
    peers = jsonDecode(response.body);
  } catch (__) {
    peers = [];
  }
  return peers;
}

/// Sets the current IP address for the node to be used when querying the blockchain.
///
/// If a node address [peerAddress] is provided, sets the node address accordingly. 
/// Otherwise, assigns a random node address from the list provided by [getPeers].
void setPeer({String peerAddress}) async {
  if (peerAddress != null) {
    (api_url = peerAddress);
  } else {
    try {
      peers = await getPeers();
      var rng = Random(25);
      api_url = 'http://' + peers[rng.nextInt(peers.length)];
    } catch (__) {
      print('Error message: $__');
    }
  }
}

/// Helper function for HTTP GET methods
///
/// Retries up to 5 times if current node becomes unresponsive.
/// Returns HTTP response object or error string.
dynamic getHttp(String route) async {
  var i = 0;
  String error;
  while (i < 5) {
    try {
      final response = await http.get(api_url + route);
      return response.body;
    } catch (__) {
      print('Error message: ${__}');
      i++;
      await setPeer();
      error = __;
    }
  }
  return error;
}

///Helper function for HTTP POST methods

/// Retries up to 5 times if current node becomes unresponsive.
///
/// Returns HTTP response object or error string.
dynamic postHttp(String route, dynamic body) async {
  var i = 0;
  String error;
  while (i < 5) {
    try {
      final response = await http.post(api_url + route, body: body);
      print('Http post request status code: ${response.statusCode}');
      print('Http post request status reason: ${response.body.toString()}');
      return response;
    } catch (__) {
      print('Error message: ${__}');
      i++;
      await setPeer();
      error = __.toString();
    }
  }
  return error;
}

/// Returns an AR representation of a winston string [winston].
double winstonToAr(String winston) {
  
  return double.parse(winston) / pow(10, 12);
}

/// Returns a winston string representation of an AR value [ar].
String arToWinston(double ar) {
  return (ar * pow(10, 12)).truncate().toString();
}

/// Returns a bytes representation of a base64 encoded string [encodedString].
List<int> decodeBase64EncodedBytes(String encodedString) =>
    encodedString == null
        ? null
        : base64Url.decode(encodedString +
            List.filled((4 - encodedString.length % 4) % 4, '=').join());

/// Returns a base64 encoded string representation of a bytes object [data].
String encodeBase64EncodedBytes(List<int> data) =>
    data == null ? null : base64Url.encode(data).replaceAll('=', '');

/// Converts a base64 encoded string representation of wallet address to a UTF8 encoded string representation.
String ownerToAddress(owner) {
  var address = base64Url.encode(sha256
      .convert(base64Url
          .decode(owner + List.filled((4 - owner.length % 4) % 4, '=').join()))
      .bytes);
  if (address.endsWith('=')) {
    address = address.substring(0, address.length - 1);
  }
  return address;
}

/// Converts a base64 encoded set of Arweave transaction tags to their UTF8 encoded string equivalent.
///
/// Converts the name and value fields of an Arweave transaction tag from base64URL strings to UTF8 strings.
List<dynamic> decodeTags(List<dynamic> tags) {
  if ((tags != []) && (tags != null)) {
    List decodedTags = [];
    for (var j = 0; j < tags.length; j++) {
      (decodedTags == null) ? decodedTags = [
        {
          'name': utf8.decode(decodeBase64EncodedBytes(tags[j]['name'])),
          'value': utf8.decode(decodeBase64EncodedBytes(tags[j]['value']))
        }
      ] : decodedTags.add(
        {
          'name': utf8.decode(decodeBase64EncodedBytes(tags[j]['name'])),
          'value': utf8.decode(decodeBase64EncodedBytes(tags[j]['value']))
        }
      ) ;
    }
    return decodedTags;
  }
  return [];
}
