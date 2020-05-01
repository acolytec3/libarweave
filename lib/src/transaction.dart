import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:libarweave/src/utils.dart';

/// A set of helper functions specific to retrieving/creating transactions from Arweave.
class Transaction {
  /// Returns a transaction object associated with the transaction ID [txId].
  ///
  /// All addresses and tag names/values are decoded into UTF8 strings.
  static Future<Map> getTransaction(String txId) async {
    final response = await getHttp('/tx/$txId');
    Map txn = jsonDecode(response);
    txn['owner'] = ownerToAddress(txn['owner']);

    if (txn.containsKey('tags')) {
      txn['tags'] = decodeTags(txn['tags']);
    }
    return txn;
  }

  /// Returns transaction IDs resulting from a simple ArQL query as defined by the operation [op]
  /// expression 1 [expr1], and expression 2 [expr2].
  static Future<dynamic> arQl(String op, String expr1, String expr2) async {
    final body = {'op': op, 'expr1': expr1, 'expr2': expr2};
    final response = await postHttp('/arql', jsonEncode(body));
    return jsonDecode(response.body);
  }

  /// Returns the current estimated transaction price in winston for a given data payload.
  ///
  /// Accepts either a number of bytes [numBytes] or an actual data payload [data] and a target address [targetAddress] as parameters.
  static Future<String> transactionPrice(
      {int numBytes = 0, String data, String targetAddress = ''}) async {
    var byteSize;
    if (data != null) {
      byteSize = base64Url.encode(ascii.encode(data)).length;
    } else {
      byteSize = numBytes;
    }
    final response =
        await getHttp('/price/${byteSize.toString()}/$targetAddress');
    return response;
  }

  /// Returns the current transaction anchor.
  ///
  /// The transaction anchor is needed when posting multiple transactions to the same block.
  static Future<String> transactionAnchor() async {
    final response = await getHttp('/tx_anchor');
    return response;
  }

  /// Returns the ArweaveID associated with a given address or an error if no ID found.
  static Future<String> arweaveIdLookup(String address) async {
    final query = {
      'query':
          'query { transactions(from:["$address"],tags: [{name:"App-Name", value:"arweave-id"},{name:"Type", value:"name"}]) {id}}'
    };
    final response = await postHttp('/arql', jsonEncode(query));
    try {
      final txId = jsonDecode(response.body)['data']['transactions'][0]['id'];
      final txDetails = await getTransaction(txId);
      final id = txDetails['data'];
      return utf8.decode(decodeBase64EncodedBytes(id));
    }
    catch (__) {
      return 'None';
    }
  }
}
