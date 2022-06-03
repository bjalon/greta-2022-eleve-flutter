import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() async {
  testWidgets('Test HTTP', (WidgetTester tester) async {
    var url = Uri.parse('http://127.0.0.1:8080/moyenne/Benjamin');
    var response = await http.get(url);
    print("status: ${response.statusCode}");
    print("body: ${response.body}");
  });
}
