import 'package:http/http.dart' as http;
import 'dart:convert';

class Transaction {
    static Future<Map> getTransaction (String txId) async {
        final response = await http.get('http://54.36.165.155:1984' + '/tx/'+txId);
        return jsonDecode(response.body);
    }
    static Future<dynamic> arQl (String op, String expr1, String expr2) async {
      final body = {'op': op, 'expr1': expr1, 'expr2': expr2};
      final response = await http.post('http://54.36.165.155:1984/arql',body:jsonEncode(body));
      return jsonDecode(response.body);
    }
}
