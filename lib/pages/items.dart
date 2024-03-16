// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final String _url = "https://www.tiven.com.br/crud/images/";
String _status = "";
String _creationdate = "";

Future setQty(http.Client client, String _sSku, String _sEan, String _sTitle,
    String _sLoc, String _sQty) async {
  String strparam = 'https://www.tiven.com.br/picking/updqty.php/';
  strparam += '?usr=zerick'; //' + $strUser;

  var _created = DateTime.now();
  strparam += '&created=$_created';
  strparam += '&sku=$_sSku';
  strparam += '&ean=$_sEan';
  strparam += '&tit=$_sTitle';
  strparam += '&loc=$_sLoc';
  strparam += '&qty=$_sQty';
  strparam += '&status=picking';

  final response = await client.get(Uri.parse(strparam));
  print(response.body);

// Use the compute function to run parsePhotos in a separate isolate
}

Future setPicked(http.Client client, String strUser, String nOrder,
    String nStore, String picked) async {
  String strparam = 'https://www.tiven.com.br/picking/updpicked.php/';
  strparam += "?usr=$strUser";
  strparam += "&nOrder=$nOrder";
  strparam += "&nStore=$nStore";
  strparam += "&status=$picked";

  final response = await client.get(Uri.parse(strparam));
  print(response.body);

// Use the compute function to run parsePhotos in a separate isolate
}

Future<List<Repo>> fetchRepos(http.Client client) async {
  String strparam = 'https://www.tiven.com.br/picking/repos.php/';
  final response = await client.get(Uri.parse(strparam));

// Use the compute function to run parsePhotos in a separate isolate
  return compute(parseRepos, response.body);
}

// A function that will convert a response body into a List<Repo>
Future<List<Repo>> parseRepos(String responseBody) async {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Repo>((json) => Repo.fromJson(json)).toList();
}

//----------------------------------------------------------------------------------------------
class Repo {
  final String sku;
  final String ean;
  final String title;
  final String qty;
  final String address;
  final String thumbnailUrl;

  Repo(
      {required this.sku,
      required this.ean,
      required this.title,
      required this.qty,
      required this.address,
      required this.thumbnailUrl});

  factory Repo.fromJson(Map<String, dynamic> json) {
    var strPath = FileSystemEntity.isFile(_url + json['sku'] + '.jpg') != null
        ? _url + json['sku'] + '.jpg'
        : '${_url}nopicture.jpg';

    return Repo(
      sku: json['sku'] as String,
      ean: json['ean'] as String,
      title: json['title'] as String,
      qty: json['qty'] as String,
      address: json['address'] as String,
      thumbnailUrl: strPath,
    );
  }
}

Future<List<NFe>> fetchNFe(
    http.Client client, String user, String nOrder, String strStore) async {
  String strparam = 'https://www.tiven.com.br/picking/exped.php/';
  strparam += '?user=$user';
  strparam += '&nOrder=$nOrder';
  strparam += '&picked=false';
  strparam += '&status=6';
  strparam += strStore.length > 5 ? '&nStore=$strStore' : '';

  final response = await client.get(Uri.parse(strparam));
  print(response.body);
// Use the compute function to run parsePhotos in a separate isolate
  return compute(parseNFe, response.body);
}

// A function that will convert a response body into a List<NFe>
Future<List<NFe>> parseNFe(String responseBody) async {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<NFe>((json) => NFe.fromJson(json)).toList();
}

//----------------------------------------------------------------------------------------------

Future<List<NFe>> fetchInvoice(
    http.Client client, String user, String nOrder) async {
  String strparam = 'https://www.tiven.com.br/picking/exped.php/';
  strparam += '?user=$user';
  strparam += '&nOrder=$nOrder';
  strparam += '&picked=false';
  strparam += '&status=6';

  final response = await client.get(Uri.parse(strparam));
  print(response.body);
// Use the compute function to run parsePhotos in a separate isolate
  return compute(parseNFe, response.body);
}

class NFe {
  final String Nfe;
  final DateTime date;
  final String store;
  final String nStore;
  final String nClient;
  final String sku;
  final String ean;
  final String title;
  final String qty;
  String captured;
  final String address;
  final String thumbnailUrl;

  NFe(
      {required this.Nfe,
      required this.date,
      required this.store,
      required this.nStore,
      required this.nClient,
      required this.sku,
      required this.ean,
      required this.title,
      required this.qty,
      required this.captured,
      required this.address,
      required this.thumbnailUrl});

  factory NFe.fromJson(Map<String, dynamic> json) {
    var strPath = FileSystemEntity.isFile(_url + json['sku'] + '.jpg') != null
        ? _url + json['sku'] + '.jpg'
        : '${_url}nopicture.jpg';

    return NFe(
      Nfe: json['Nfe'] as String,
      date: json['date'] as DateTime,
      store: json['store'] as String,
      nClient: json['nClient'] as String,
      nStore: json['nStore'] as String,
      sku: json['sku'] as String,
      ean: json['ean'] as String,
      title: json['title'] as String,
      qty: json['qty'] as String,
      captured: json['captured'] as String,
      address: json['address'] as String,
      thumbnailUrl: strPath,
    );
  }
}

Future<List<Order>> fetchOrders(
    http.Client client, String user, String strStore, String picked) async {
  String strparam = 'https://www.tiven.com.br/picking/listOrders.php/';
  strparam += '?user=$user';
  strparam += strStore.length > 2 ? '&store=$strStore' : '';
  strparam += '&picked=$picked';
  final response = await client.get(Uri.parse(strparam));
  print(response.body);
// Use the compute function to run parsePhotos in a separate isolate
  return compute(parseOrders, response.body);
}

// A function that will convert a response body into a List<Order>
Future<List<Order>> parseOrders(String responseBody) async {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}

//----------------------------------------------------------------------------------------------
class Order {
  final String nOrder;
  final String nStore;
  final String store;
  final String nClient;
  final String market;
  final String items;
  final String products;
  final String total;
  final String ordDate;
  final String thumbnailMarketUrl;
  final String thumbnailStoreUrl;

  Order(
      {required this.nOrder,
      required this.nStore,
      required this.store,
      required this.nClient,
      required this.market,
      required this.items,
      required this.products,
      required this.total,
      required this.ordDate,
      required this.thumbnailMarketUrl,
      required this.thumbnailStoreUrl});

  factory Order.fromJson(Map<String, dynamic> json) {
    String strMarketPath =
        FileSystemEntity.isFile('${_url}logos/' + json['market'] + '.jpg') !=
                null
            ? '${_url}logos/' + json['market'] + '.jpg'
            : '${_url}nopicture.jpg';
    String strStorePath =
        FileSystemEntity.isFile('${_url}logos/' + json['store'] + '.jpg') !=
                null
            ? '${_url}logos/' + json['store'] + '.jpg'
            : '${_url}nopicture.jpg';

    return Order(
      nOrder: json['nOrder'] as String,
      nStore: json['nStore'] as String,
      store: json['store'] as String,
      nClient: json['nClient'] as String,
      market: json['market'] as String,
      items: json['items'] as String,
      products: json['products'] as String,
      total: json['total'] as String,
      ordDate: json['ordDate'] as String,
      thumbnailMarketUrl: strMarketPath,
      thumbnailStoreUrl: strStorePath,
    );
  }
}

PickingResponse parsePickingResponse(String responseBody) {
  final decoded = json.decode(responseBody);

  final items =
      (decoded['items'] as List).map((e) => Photo.fromJson(e)).toList();

  return PickingResponse(
    blockId: decoded['block_id'],
    total: decoded['total'],
    items: items,
  );
}

class PickingResponse {
  final int blockId;
  final int total;
  final List<Photo> items;

  PickingResponse({
    required this.blockId,
    required this.total,
    required this.items,
  });
}

Future<PickingResponse> fetchItems(
  String store,
  String user,
) async {
  final client = http.Client();

  final uri = Uri.parse('https://www.tiven.com.br/picking/blingOrders.php')
      .replace(queryParameters: {'store': store, 'user': user});

  final response = await client.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Erro ao carregar picking');
  }

  return compute(parsePickingResponse, response.body);
}

Future<List<Photo>> fetchNFeItems(String user, String strStore) async {
  http.Client client = http.Client();
  String strparam = 'https://www.tiven.com.br/picking/blingOrder.php';
  strparam += '?user=$user';
  strparam += '&idSituacao=Emitida';
  strparam += '&store=$strStore';
  final response = await client.get(Uri.parse(strparam));
  if (kDebugMode) {
    print(response.body);
  }
  // Use the compute function to run parsePhotos in a separate isolate
  return compute(parsePhotos, response.body);
}

Future<List<Photo>> fetchEdItems(
    String user, bool blStatus, String strStore, String strCourier) async {
  http.Client client = http.Client();
  // String $strStatus = $blStatus ? '6' : '6';
  String strparam = 'https://www.tiven.com.br/picking/siteED.php';
  strparam += '?user=user';
  //strparam += '&idSituacao=' + $strStatus;
  strparam += '&store=strStore';
  strparam += '&courier=strCourier';
  final response = await client.get(Uri.parse(strparam));
  print(response.body);
  // Use the compute function to run parsePhotos in a separate isolate

  return await fetchVwEdItems(user, blStatus, strStore, strCourier);
  //return compute(parsePhotos, response.body);
}

Future<List<Photo>> fetchVwEdItems(
    String user, bool blStatus, String strStore, String strCourier) async {
  http.Client client = http.Client();
  String strparam = 'https://www.tiven.com.br/picking/vwSiteED.php';
  strparam += '?user=user';
  strparam += '&store=strStore';
  strparam += '&courier=strCourier';
  strparam += '&r=${DateTime.now().millisecondsSinceEpoch}';

  final response = await client.get(Uri.parse(strparam));
  print(response.body);
  // Use the compute function to run parsePhotos in a separate isolate
  return compute(parsePhotos, response.body);
}

// A function that will convert a response body into a List<Photo>
Future<List<Photo>> parsePhotos(String responseBody) async {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final String box;
  final String order;
  final String supplier;
  final String sku;
  final String channel;
  final String courier;
  final String ean;
  String captured;
  final String title;
  final String qty;
  final String address;
  final String thumbnailUrl;

  Photo(
      {required this.box,
      required this.order,
      required this.supplier,
      required this.sku,
      required this.channel,
      required this.courier,
      required this.ean,
      required this.captured,
      required this.title,
      required this.qty,
      required this.address,
      required this.thumbnailUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      box: json['box']?.toString() ?? '',
      order: json['order']?.toString() ?? '',
      supplier: json['supplier']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      channel: json['store']?.toString() ?? '',
      courier: json['courier']?.toString() ?? '',
      ean: json['ean']?.toString() ?? '0',
      captured: '0',
      title: json['title']?.toString() ?? '',
      qty: json['quantity']?.toString() ??
          json['qty']?.toString() ??
          '0', // CORRIGIDO
      address: json['location']?.toString() ??
          json['address']?.toString() ??
          '', // CORRIGIDO
      thumbnailUrl:
          json['sku'] != null ? '$_url${json['sku']}.jpg' : '${_url}nopic.jpg',
    );
  }
}

Future<List<InvItems>> fetchInvItems(
    String user, bool blStatus, String intInv) async {
  http.Client client = http.Client();
  String strparam = 'https://www.tiven.com.br/crud/InventoryList.php';
  strparam += '?user=user';
  strparam += '&IdSituacao=blStatus';
  strparam += '&IdInv=1'; // + $intInv;
  var response = await client.get(Uri.parse(strparam));
  // Use the compute function to run parseInvItems in a separate isolate
  return await compute(parseInvItems, response.body);
}

// A function that will convert a response body into a List<Photo>
Future<List<InvItems>> parseInvItems(String responseBody) async {
  var parsed = await json.decode(responseBody).cast<Map<String, dynamic>>();
  return await parsed.map<InvItems>((json) => InvItems.fromJson(json)).toList();
}

class InvItems {
  final String id;
  final String idInv;
  final String qty;
  String captured;
  final String gtin;
  final String sku;
  final String title;
  final String address;
  final String thumbnailUrl;
  String user;
  final String team;
  final String timestamp;

  InvItems(
      {required this.id,
      required this.idInv,
      required this.qty,
      required this.captured,
      required this.gtin,
      required this.sku,
      required this.title,
      required this.address,
      required this.thumbnailUrl,
      required this.user,
      required this.team,
      required this.timestamp});

  factory InvItems.fromJson(Map<String, dynamic> json) {
    var strPath = FileSystemEntity.isFile(_url + json['sku'] + '.jpg')
                .timeout(Duration(milliseconds: 500)) !=
            null
        ? _url + json['sku'] + '.jpg'
        : '${_url}nopicture.jpg';

    return InvItems(
      id: json['id'] as String,
      idInv: json['idInv'] as String,
      qty: json['qty'] as String,
      gtin: json['gtin'] as String,
      sku: json['sku'] as String,
      title: json['title'] as String,
      captured: '0',
      address: json['address'] as String,
      thumbnailUrl: _url + json['sku'] + '.jpg',
      user: json['user'] as String,
      team: json['team'] as String,
      timestamp: json['timestamp'] as String,
      // thumbnailUrl: strPath,
    );
  }
}
