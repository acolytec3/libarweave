import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:libarweave/src/utils.dart';

class Transaction {
    static Future<Map> getTransaction (String txId) async {
        final response = await getHttp('/tx/$txId');
        Map txn = jsonDecode(response);
        txn['owner'] = ownerToAddress(txn['owner']);
        if (txn.containsKey('target')){
          txn['target'] = ownerToAddress(txn['target']);
        }
        if (txn.containsKey('tags')) {
            txn['tags'] = decodeTags(txn['tags']);
        }
        return txn;
    }
    
    static Future<dynamic> arQl (String op, String expr1, String expr2) async {
      final body = {'op': op, 'expr1': expr1, 'expr2': expr2};
      final response = await http.post(api_url + '/arql',body:jsonEncode(body));
      return jsonDecode(response.body);
    }

    static Future<String> transactionPrice({int numBytes = 0, String data, String targetAddress = ''}) async  {
      var byteSize;
      if (data != null) {
        byteSize = base64Url.encode(ascii.encode(data)).length;
      } else {
        byteSize = numBytes;
      }
      final response = await getHttp('/price/${byteSize.toString()}/$targetAddress');
      return response;
    }

    static Future<String> transactionAnchor() async {
    final response = await getHttp('/tx_anchor');
    return response;
  }

   static Future<String> arweaveIdLookup(String address) async {
    final query = {
      'query':'query { transactions(from:["$address"],tags: [{name:"App-Name", value:"arweave-id"},{name:"Type", value:"name"}]) {id}}'};
    final response = await postHttp('/arql', jsonEncode(query));
    if (response.body != '') {
	final txId = jsonDecode(response.body)['data']['transactions'][0]['id'];
	final txDetails = await getTransaction(txId);
	final id = txDetails['data'];
	return utf8.decode(decodeBase64EncodedBytes(id));
    }
    return "No arweave id found";
  }
}
