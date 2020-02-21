import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String api_url = 'http://arweave.net';
List peers;

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
      error = __;
    }
  }
  return error;
}

double winstonToAr(String winston) {
  return int.parse(winston) / pow(10, 12);
}

String arToWinston(double ar) {
  return (ar * pow(10, 12)).toString();
}

List<int> decodeBase64EncodedBytes(String encodedString) =>
    encodedString == null
        ? null
        : base64Url.decode(encodedString +
            List.filled((4 - encodedString.length % 4) % 4, '=').join());

String encodeBase64EncodedBytes(List<int> data) =>
    data == null ? null : base64Url.encode(data).replaceAll('=', '');

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

List<dynamic> decodeTags(List<dynamic> tags) {
  if ((tags != []) && (tags != null)) {
    List decodedTags = [];
    for (var j = 0; j < tags.length; j++) {
      (decodedTags == null) ? decodedTags = [
        {
          'name': utf8.decode(decodeBase64EncodedBytes(tags[j]['name'])),
          'value': utf8.decode(decodeBase64EncodedBytes(tags[j]['value']))
        }
      ] : decodedTags.add([
        {
          'name': utf8.decode(decodeBase64EncodedBytes(tags[j]['name'])),
          'value': utf8.decode(decodeBase64EncodedBytes(tags[j]['value']))
        }
      ]) ;
    }
    return decodedTags;
  }
  return [];
}
