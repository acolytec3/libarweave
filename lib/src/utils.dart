import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

String api_url = 'http://arweave.net';
List peers;

Future<List> getPeers() async {
  final response = await http.get(api_url + '/peers');
  List peers = jsonDecode(response.body);
  return peers;
}

void setPeer({String peerAddress}) async {
  if (peerAddress != null) {
    (api_url = peerAddress);
  } else {
    peers = await getPeers();
    var rng = Random(25);
    api_url = 'http://' + peers[rng.nextInt(peers.length)];
  }
}

dynamic getHttp(String route) async {
  var i = 0;
  while (i < 5) {
    try {
      final response = await http.get(api_url + route);
      return response.body;
    } catch (__) {
      print('Error message: ${__}');
      i++;
      await setPeer();
    }
  }
}

dynamic postHttp(String route, dynamic body) async {
  while (true) {
    try {
      final response = await http.post(api_url + route, body: body);
      return response.body;
    } catch (__) {
      print('Error message: ' + __);
      await setPeer();
    }
  }
}
