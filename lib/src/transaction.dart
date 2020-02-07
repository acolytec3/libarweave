import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:libarweave/src/utils.dart';

class Transaction {
    static Future<Map> getTransaction (String txId) async {
        final response = await getHttp('/tx/'+txId);
        return jsonDecode(response);
    }
    static Future<dynamic> arQl (String op, String expr1, String expr2) async {
      final body = {'op': op, 'expr1': expr1, 'expr2': expr2};
      final response = await http.post(api_url + '/arql',body:jsonEncode(body));
      return jsonDecode(response.body);
    }
}
