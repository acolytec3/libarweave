import 'package:jose/jose.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:libarweave/src/utils.dart';
import 'package:pointycastle/export.dart';
import 'package:libarweave/src/transaction.dart';
import 'package:http/http.dart';

class Wallet {

  /// JSON Web Key formatted wallet key.
  JsonWebKey _wallet;

  /// Owner encoded as a base64 URL string.
  String _owner;

  /// Wallet address as UTF8 encoded string.
  String _address;
  dynamic _jwk;

  /// Constructor for the [Wallet] class
  Wallet({String jsonWebKey}) {
    if (jsonWebKey != null) {
      _jwk = jsonDecode(jsonWebKey);
      _wallet = JsonWebKey.fromJson(_jwk);
      _owner = _jwk['n'];
      _address = ownerToAddress(_owner);
    }
  }

  /// Initializes a [Wallet] object and sets key public field values.
  void loadWallet(String jsonWebKey) {
    var jwk = jsonDecode(jsonWebKey);
    _wallet = JsonWebKey.fromJson(jwk);
    _owner = jwk['n'];
    _address = base64Url.encode(sha256
        .convert(base64Url.decode(
            _owner + List.filled((4 - _owner.length % 4) % 4, '=').join()))
        .bytes);
    if (_address.endsWith('=')) {
      _address = _address.substring(0, _address.length - 1);
    }
  }

  /// Wallet address as UTF8 encoded string.
  String get address {
    return _address;
  }

  /// Wallet object as JsonWebKey.
  JsonWebKey get jwk {
    return _wallet;
  }

  /// Returns current balance of wallet in AR. 
  Future<double> balance() async {
    var response = await getHttp('/wallet/$_address/balance');
    return winstonToAr(response);
  }

  /// Returns ID for last transaction from wallet.
  Future<String> lastTransaction() async {
    var response = await getHttp('/wallet/$_address/last_tx');
    return response;
  }

  /// Returns a list of transaction IDs for all transactions sent from wallet.
  Future<List> allTransactionsFromAddress() async {
    final response = await Transaction.arQl('equals', 'from', _address);
    if (response.runtimeType == Response){
      return errorMessage(response);
    }
    else {
      return response;
    }
  }

  /// Returns a list of transaction IDs for all transactions sent to wallet
  Future<List> allTransactionsToAddress() async {
    final response = await Transaction.arQl('equals', 'to', _address);
    if (response.runtimeType == Response){
      return errorMessage(response);
    }
    else {
      return response;
    }
  }

  /// Returns a list of transaction IDs for transactions not included in provided [txnHistory] 
  Future<List> getNewTransactions(List txnHistory) async {
    var toTxns = await allTransactionsToAddress();
    var fromTxns = await allTransactionsFromAddress();
    var allTxns;
    if ((toTxns[0] != 'Error') && (fromTxns[0] != 'Error')){
      allTxns = toTxns + fromTxns;
    }
    else {
      toTxns[0] != 'Error' ? allTxns = toTxns : allTxns = fromTxns;
    }

    if (allTxns[0] != 'Error'){
      return List.from((Set.of(allTxns)).difference(Set.of(txnHistory)));
    }
    else {
      return allTxns;
    }
  }

  /// Returns a list of transaction IDs for all transactions that have tags attached to them initiated by the wallet.
  Future<List> dataTransactionHistory() async {
    final query = {
      'query':
          'query {transactions(from: ["${_address}"]){id tags{name value}}} '
    };
    final response = await postHttp('/arql', jsonEncode(query));
    if (response.body != '') {
      final txns = jsonDecode(response.body)['data']['transactions'];
      return txns;
    }
    return [];
  }

  /// Returns a raw transaction ready to be signed and then posted to the blockchain.
  List<int> createTransaction(String lastTx, String reward,
      {String targetAddress = '',
      List tags,
      String quantity = '0',
      List<int> data}) {
    var dataBytes = <int>[];
        
    final lastTxBytes = decodeBase64EncodedBytes(lastTx);
    final targetBytes = decodeBase64EncodedBytes(targetAddress);
    final ownerBytes = decodeBase64EncodedBytes(_owner);
    final rewardBytes = utf8.encode(reward);
    final quantityBytes = utf8.encode(quantity);
    var tagsBytes = <int>[] ;

    print('dataBytes $dataBytes');
    print('lastTxBytes $lastTxBytes');
    print('ownerBytes $ownerBytes');
    print('rewardBytes $rewardBytes');
    print('quantityBytes $quantityBytes');
    print('targetBytes $targetBytes');
    
    if (data != null) {
      dataBytes = decodeBase64EncodedBytes(encodeBase64EncodedBytes(data));
    }

    if (tags != null) {
      for (var tag in tags) {
        tagsBytes += decodeBase64EncodedBytes(
            encodeBase64EncodedBytes(utf8.encode(tag['name'])));
        tagsBytes += decodeBase64EncodedBytes(
            encodeBase64EncodedBytes(utf8.encode(tag['value'])));
      }
    } else {
      tagsBytes = [];
    }

    print('Tags are: ${tags.toString()}');
    print('Tag bytes: ${tagsBytes.toString()}');
    var rawTransaction = ownerBytes +
        targetBytes +
        dataBytes +
        quantityBytes +
        rewardBytes +
        lastTxBytes +
        tagsBytes;

    return rawTransaction;
  }

  /// Posts a signed transaction to the blockchain and returns the response object.
  ///
  /// Important Note: There is no package in Dart that currently supports the RSA-PSS signing method so the raw transaction produced by [createTransaction] must be signed using some other method and then passed to this function.
  Future<dynamic> postTransaction(
      List<int> signature, String lastTx, String reward,
      {String targetAddress = '',
      List tags,
      String quantity = '0',
      List<int> data}) async {
    final digest = SHA256Digest();
    final hash = digest.process(signature);
    List tagsB64 = [];
    if (tags != null) {
      for (var tag in tags) {
        if (tagsB64 != null) {
          print('Adding tag: ${tag.toString()}');
          tagsB64.add({
            'name': encodeBase64EncodedBytes(utf8.encode(tag['name'])),
                'value': encodeBase64EncodedBytes(utf8.encode(tag['value']))
          });
        } else {
          print('Adding tag: ${tag.toString()}');
          tagsB64 = [
            {
              'name': (encodeBase64EncodedBytes(utf8.encode(tag['name']))),
                  'value':(encodeBase64EncodedBytes(utf8.encode(tag['value'])))
            }
          ];
        }
      }
    }
    else {
      tagsB64 = [];
    }
    final id = encodeBase64EncodedBytes(hash);
    print('Transaction ID is: $id');
    final body = json.encode({
      'id': id,
      'last_tx': lastTx,
      'owner': _owner,
      'tags': tagsB64,
      'target': targetAddress,
      'reward': reward,
      'quantity': quantity,
      'data': (data != null) ? encodeBase64EncodedBytes(data) : '',
      'signature': encodeBase64EncodedBytes(signature)
    });
    final response = await postHttp('/tx', body);
    return [response, id];
  }
}
