import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tiven/pages/items.dart';
import 'package:tiven/utils/logger.dart' as log;

// ig.:page=1;limit=100&filters=dataEmissao[2024-02-13T12:49:20.000Z TO 2024-02-14T23:59:00.000Z]; idSituacao[68912, 15,6,9]
final String url = 'https://www.bling.com.br/Api/v3/';
final String urlOrders = 'pedidos/vendas?';

Future<List<Photo>> getBlingOrders() async{ 
  var headers = {
  'Accept': 'application/json',
  'Authorization': 'Bearer ad2f4a9424f284c9fee3c46ca657e5b307cad9a0',
  'Cookie': 'PHPSESSID=nlf31cdnjktgpkhfccu4e3qlhq'
};
var dio = Dio();
var response = await dio.request(
  '$url${urlOrders}page=1;limit=100&filters=dataEmissao[2024-02-13T12:49:20.000Z TO 2024-02-14T23:59:00.000Z]; idSituacao[68912, 15,6,9]',
  options: Options(
    method: 'GET',
    headers: headers,
  ),
);

if (response.statusCode == 200) {
  log.logger.i('Bling orders fetched successfully');
} else {
  log.logger.e('Error fetching orders: ${response.statusMessage}');
}
return response.data;  
 }
