// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/items.dart';
// import 'Loc2.dart';

//void main() => runApp(Scan());

class Conference extends StatefulWidget {
  final List<Photo> photos;
  final String user, idUser;

  const Conference(
      {super.key,
      required this.idUser,
      required this.user,
      required this.photos});

  @override
  _ConferenceState createState() =>
      // ignore: no_logic_in_create_state
      _ConferenceState(user: user, idUser: idUser);
}

class _ConferenceState extends State<Conference> {
  final String _url = "https://www.tiven.com.br/crud/images/";
  final String user, idUser;
  int _qty = 0;

  _ConferenceState({required this.user, required this.idUser});

  var focusNode = FocusNode();
  var myfocusNode = FocusNode();
  var mykeyfocusNode = FocusNode();
  final myController = TextEditingController();
  final myKeyController = TextEditingController();

  // ignore: unused_field
  String _scanLocation = '';
  String _scanBarcode = 'Desconhecido';
  String barcodeScanRes = '';
  String _title = "";
  String _barcode = "";
  int vol = 0;
  int countvol = 0;
  late String _KeyNfe = "";
  String _sku = "";
  String _location = "";

  // ignore: unused_field
  String _location2 = "";

  // ignore: unused_field
  String _location3 = "";
  int _quant = 0;
  int _quant2 = 0;
  int _quant3 = 0;
  int _countvol = 0;
  int _countprod = 0;

  // ignore: unused_field
  int _quantot = 0;

  // ignore: unused_field
  int _estAtual = 0;
  int _newquant = 0;
  var data;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // qtdeController.dispose();
    // locController.dispose();
    myController.dispose();
    myKeyController.dispose();
    focusNode.dispose();
    myfocusNode.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print("Second text f");
  }

  String _imagePath = 'assets/images/logo.png';

  @override
  void initState() {
    super.initState();
    myController.addListener(_printLatestValue);
    focusNode = FocusNode();
    myfocusNode = FocusNode();
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  int showIntFuture(int intDun) {
    switch (intDun) {
      case 1:
        {
          return 6;
        }
      case 2:
        {
          return 8;
        }
      case 3:
        {
          return 12;
        }
      case 5:
        {
          return 3;
        }
      case 6:
        {
          return 2;
        }
      case 7:
        {
          return 5;
        }
      case 8:
        {
          return 10;
        }
      case 9:
        {
          return 16;
        }
      default:
        {
          return 4;
        }
    }
  }

  int showIntArthi(intDun) {
    switch (intDun) {
      case 1:
        {
          return 10;
        }
      case 2:
        {
          return 2;
        }
      case 3:
        {
          return 12;
        }
      case 5:
        {
          return 5;
        }
      case 6:
        {
          return 6;
        }
      case 7:
        {
          return 7;
        }
      case 8:
        {
          return 8;
        }
      case 9:
        {
          return 9;
        }
      default:
        {
          return 4;
        }
    }
  }

/*
  Step 1: add together all alternate numbers starting from the right
  5 0 1 2 3 4 5 7 6 4 2 1
  0 + 2 + 4 + 7 + 4 + 1 = 18

  Step 2: multiply the answer by 3
  18 x 3 = 54

  Step 3: now add together the remaining numbers
  5 0 1 2 3 4 5 7 6 4 2 1
  5 + 1 + 3 + 5 + 6 + 2 = 22

  Step 4: add step 2 and 3 together
  54 + 22 = 76

  Step 5: the difference between step 4 and the next 10th number:
  76 + 4 = 80

  Check digit = 4
*/

  dynamic getDigtin(barcode) {
    int intval1 = 0;
    int intval2 = 0;
    int $length = barcode.toString().length - 1;
    int digit = 0;

    for (int x = 0; x <= $length; x++) {
      print(x);
      if (x == $length) {
        intval2 += int.parse(barcode.toString().substring(x, x + 1));
      } else if ((x % 2) == 0) {
        intval1 += int.parse(barcode.toString().substring(x, x + 1));
      } else {
        intval2 += int.parse(barcode.toString().substring(x, x + 1));
      }
    }

    intval2 = (intval2 * 3);
    // _sum = ((_intval1 + _intval2) * 1.0) / 10;

    digit = (((intval1 + intval2) / 10).ceil() * 10) - (intval1 + intval2);

    // ARREDONDAR.PARA.CIMA(142/10;0) * 10 - 142

    if (digit == 10) {
      digit = 0;
    }

    barcode = barcode.toString() + (digit).toString();
    return barcode;
  }

  void splitBarcode() {
    if (_barcode.toString().length == 14) {
      if (_barcode.toString().substring(4, 8) == '6497') {
        _newquant =
            showIntFuture(int.parse(_barcode.toString().substring(0, 1)));
      } else if (_barcode.toString().substring(4, 8) == '7807') {
        _newquant =
            showIntArthi(int.parse(_barcode.toString().substring(0, 1)));
      } else {
        _newquant = int.parse(_barcode.toString().substring(0, 1));
      }
      _barcode = getDigtin(int.parse(_barcode.toString().substring(1, 13)));
    } else if (_barcode.toString().length == 13) {
      _newquant = 1;
    }
  }

  Future<void> scanBarcodeNormal() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      if (result != null && result.isNotEmpty && result != '-1') {
        barcodeScanRes = result;
        _barcode = barcodeScanRes;
      }
    } catch (e) {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeLocation(sku) async {
    String locationScanRes = '';
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      if (result != null && result.isNotEmpty && result != '-1') {
        locationScanRes = result;
        bool chkadd = _checkAddress(locationScanRes);
        if (chkadd == true) {
          updateLocation(sku, locationScanRes);
        }
      }
    } catch (e) {
      locationScanRes = 'Falha ao verificar versão da plataforma.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanLocation = _location.toString();
    });
  }

  Future updateLocation(String code, String local) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/updateLocation.php?CODE=$code&LOCAL=$local"),
        headers: {"Accept": "application/json"});
    print(local);
    if (response.contentLength! >= 100) {
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson['result'];
        _title = data[0]['prd_titulo'];
        _barcode = data[0]['prd_barcode'];
        _sku = data[0]['prd_sku'];
        _location = data[0]['prd_location'] as String;
        _quant = int.parse(data[0]['prd_quantidade']);
        _imagePath =
            "http://www.tiven.com.br/crud/images/" + data[0]['prd_pic1'];
      });
    }
  }

// TODO: BUILD XML FILE
//   Future<HttpClientResponse> _sendOTP(
//       String _sku, String _title, int _newlocation) async {
//     var builder = new xml.XmlBuilder();

//     /*<?xml version="1.0" encoding="UTF-8"?>
// <produto>
// <codigo>$codigo</codigo>
// <descricao>$descricao</descricao>
// <localizacao>$localizacao</localizacao>
// </produto>
// */
//     builder.processing('xml', 'version="1.0" version="1.0" encoding="UTF-8"');
//     builder.element('produto', nest: () {
//       builder.element('codigo', nest: _sku);
//       builder.element('descricao', nest: _title);
//       builder.element('localizacao', nest: _newlocation);
//     });
//     var bookshelfXml = builder.build();
//     String _apikey =
//         "a64370ceea64ecf3f2831d211fea334d3fd1606cca506679de43079a97d821ddc56cda49";
//     String _uriMsg = bookshelfXml.toString();

//     String _uri = "https://bling.com.br/Api/v2/produto/$_sku/";
//     //var _responseOtp = postOTP(_uri, _uriMsg);
//     var _responseOtp = (
//         String _uri, String _xml, String _key) async {
//       var credential = base64.encode(utf8.encode('apikey:$_key'));
//       var request = http.Request(
//         'POST',
//         Uri.parse(_uri),
//       );
//       request.headers.addAll({
//         HttpHeaders.authorizationHeader: 'Basic $credential',
//         'content-type': 'text/xml' // or text/xml;charset=utf-8
//       });

//     either
//       request.body = _xml;
//       // which will encode the string to bytes, and modify the content-type header, adding the encoding
//       // or
//       // request.bodyBytes = utf8.encode(xml);
//       // which gives you complete control over the character encoding

//       var streamedResponse = await (request.send());
//       print(streamedResponse.statusCode);

//       var responseBody =
//           await streamedResponse.stream.transform(utf8.decoder).join();
//       print(responseBody);
//     }(_uri, _uriMsg, _apikey);

//     print('_responseOtp: $_responseOtp');
//   }

  Future<String> postOTP(String uri, String message) async {
    HttpClient client = HttpClient();
    HttpClientRequest request = await client.postUrl(Uri.parse(uri));
    request.write(message);
    HttpClientResponse response = await request.close();
    StringBuffer buffer = StringBuffer();
    await for (String a in response.transform(utf8.decoder)) {
      buffer.write(a);
    }
    print("_buffer.toString: ${buffer.toString()}");
    return buffer.toString();
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    minimumSize: Size(88, 44),
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
    backgroundColor: Colors.grey.withValues(alpha: 0.1),
  );

  Future dialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          elevation: 8,
          title: Row(children: [
            Row(
              children: [
                Text('Inventário'),
              ],
            ),
            FadeInImage.assetNetwork(
              placeholder: 'assets/load.gif',
              image: '$_url$_sku.jpg',
              height: 50,
            ),
          ]),
          content: Text("Deseja realmente adicionar :\n$_newquant * $_title?"),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              onPressed: () {
                setState(() {
                  clearFields();
                  Navigator.of(context).pop();
                });
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
                style: flatButtonStyle,
                child: Text(
                  "Enviar",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(
                    () {
                      // checkInventory(_barcode, _newquant, idUser);
                      clearFields();
                      Navigator.of(context).pop();
                    },
                  );
                }),
          ],
        );
      },
    );
  }

  Future showDialogKey() async {
    showDialog(
      barrierColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          backgroundColor: Colors.black,
          shadowColor: Colors.white,
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.5),
                width: 1,
              ),
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(-1, -1), // changes position of shadow
                ),
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
            child: Icon(
              Icons.barcode_reader,
              size: 40,
              color: Colors.grey.withValues(alpha: 1),
            ),
          ),
          elevation: 10,
          title: Row(
            children: [
              Text(
                'Informe a Chave de Acesso da NFe',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: TextFormField(
            maxLines: 4,
            style: TextStyle(color: Colors.white, fontSize: 26),
//             onFieldSubmitted: (value){
//               if (value == value)
//               setState(
//                 () {
//                   _KeyNfe = myKeyController.text;
//                 },
//               );
//               getAccessKey(_KeyNfe, idUser);
//               // dialog();
//               // myKeyController.clear();
//               FocusScope.of(context).requestFocus(mykeyfocusNode);
//               return;
// //            setState(() {
//             },
            onTap: () {
              scanBarcodeNormal();
              setState(() {
                if (barcodeScanRes.isNotEmpty) {
                  myKeyController.text = barcodeScanRes;
                  _KeyNfe = myKeyController.text;
                  data = getAccessKey(_KeyNfe, idUser);
                  dialog();
                  myKeyController.clear();
                  FocusScope.of(context).requestFocus(mykeyfocusNode);
                  data = jsonDecode(data);
                }
              });
            },
            focusNode: mykeyfocusNode,
            autofocus: true,
            decoration: InputDecoration(
              iconColor: Colors.white,
              suffixIconColor: Colors.white,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.white, style: BorderStyle.solid),
              ),
              prefixIconColor: Colors.white,
              hintText: 'Chave NFe',
              helperText: 'Informe a chave de acesso',
              labelText: 'NFe',
              prefixIcon: Icon(
                Icons.chrome_reader_mode,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                onPressed: () => myKeyController.clear(),
                icon: Icon(Icons.delete),
                color: Colors.white,
              ),
              suffixStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w100,
              ),
            ),
            controller: myKeyController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  clearFields();
                  Navigator.of(context).pop();
                });
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    // Change your radius here
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(
                    Color.fromARGB(255, 230, 96, 7)),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                side: WidgetStateProperty.all(
                  BorderSide.lerp(
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blueGrey,
                        width: 1.0,
                      ),
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      2.0),
                ),
              ),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  clearFields();
                  Navigator.of(context).pop();
                });
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    // Change your radius here
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(
                    Color.fromARGB(255, 230, 96, 7)),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                side: WidgetStateProperty.all(
                  BorderSide.lerp(
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blueGrey,
                        width: 1.0,
                      ),
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      2.0),
                ),
              ),
              child: Text(
                "   Buscar   ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future showDialogClear() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          elevation: 8,
          title: InkWell(
            child: Text("Deseja limpar todos dados?"),
            onTap: () {
              setState(
                () {
                  _KeyNfe = myKeyController.text;
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                side: WidgetStateProperty.all(
                  BorderSide.lerp(
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blueGrey,
                        width: 1.0,
                      ),
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      2.0),
                ),
              ),
              onPressed: () {
                setState(() {
                  clearFields();
                  Navigator.of(context).pop();
                });
              },
              child: Container(),
            ),
            TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  side: WidgetStateProperty.all(
                    BorderSide.lerp(
                        BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.blueGrey,
                          width: 1.0,
                        ),
                        BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        2.0),
                  ),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    // checkInventory(_barcode, _newquant, idUser);
                    clearData();
                    Navigator.of(context).pop();
                  });
                }),
          ],
        );
      },
    );
  }

  Future getProd() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/getProductByCode.php?CODE=$_barcode"),
        headers: {"Accept": "application/json"});
    if (kDebugMode) {
      print(_barcode);
    }
    if (response.contentLength! >= 100) {
      var convertDataToJson = json.decode(response.body);
      //myController.text = '';
      data = convertDataToJson['result'];
      _title = data[0]['prd_titulo'];
      _barcode = data[0]['prd_barcode'];
      _sku = data[0]['prd_sku'];
      _location =
          data[0]['prd_location'] == null ? 0 : (data[0]['prd_location']);
      _location2 =
          data[0]['prd_location2'] == null ? 0 : (data[0]['prd_location2']);
      _location3 =
          data[0]['prd_location3'] == null ? 0 : (data[0]['prd_location3']);
      _quant = (data[0]['prd_quantidade'] == null
          ? 0
          : int.tryParse(data[0]['prd_quantidade']))!;
      _quant2 = (data[0]['prd_quantidade2'] == null
          ? 0
          : int.tryParse(data[0]['prd_quantidade2']))!;
      _quant3 = (data[0]['prd_quantidade3'] == null
          ? 0
          : int.tryParse(data[0]['prd_quantidade3']))!;
      _quantot = _quant + _quant2 + _quant3;
      _imagePath = "assets/images/${data[0]['prd_sku']}.jpg";
    } else {
      setState(() {
        _title = '';
        _barcode = _barcode;
        // myController.text = '';
        _sku = _sku;
        _location = "";
        _quant = 0;
        _imagePath = 'assets/images/notregistered.png';
        if (kDebugMode) {
          print(_barcode);
        }
      });
    }
  }

  Future<String> getAccessKey(String keyNfe, String idUser) async {
    var response = await http.get(
        // Uri.parse("http://localhost/crud/getNfeByKey.php?keynfe=43210490406117000162550000001151321942649269&idUser=13"),headers: {"Accept": "application/json"});
        Uri.parse("https://www.tiven.com.br/crud/getNfeByKey.php?keynfe={$keyNfe}&idUser={$idUser}"),
        headers: {"Accept": "application/json"});
    if (response.contentLength! >= 100) {
      var convertDataToJson = json.decode(response.body);
      //myController.text = '';
      data = convertDataToJson;
    } else {
      setState(() {
        _imagePath = 'assets/images/notregistered.png';
        print(_barcode);
      });
    }
    return data;
  }

  Future getProdBling(String code) async {
    var response = await http.get(
        Uri.parse("https://bling.com.br/Api/v2/produto/" +
            code +
            "/json&apikey=a64370ceea64ecf3f2831d211fea334d3fd1606cca506679de43079a97d821ddc56cda49&estoque=S"),
        headers: {"Accept": "application/json"});
    print(code);
    if (response.contentLength! >= 150) {
      setState(() {
        var data = json.decode(response.body);
        _estAtual = int.parse(data["retorno"]["produtos"][0]["produto"]
                ["estoqueAtual"]
            .toString());
        _title =
            data["retorno"]["produtos"][0]["produto"]["descricao"].toString();
      });
    } else {
      setState(() {
        _title = '';
        _barcode = _barcode;
        //myController.text = '';
        _sku = _sku;
        _location = "";
        _quant = 0;
        _imagePath = 'assets/images/notregistered.png';
        print(code);
      });
    }
  }

  Future updateProd(
      String barcode, String sku, String location, String quant) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/updateProduct.php?CODE=$barcode&SKU=$sku&LOCAL=1&ADDRESS=$location&QUANTITY=$quant"),
        headers: {"Accept": "application/json"});

    setState(() {
      if (response.contentLength! >= 20) {
        print(barcode);
      }
    });
  }

  Future checkInventory(String barcode, int newquant, String user) async {
    await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/updInventory.php?BARCODE=$barcode&QUANTITY=$newquant&USER=$user"),
        headers: {"Accept": "application/json"});
  }

  Future getvol() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/getInvoicesVols.php?idUser=$idUser"),
        headers: {"Accept": "application/json"});
    _countvol = 0;
    _countprod = 0;
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      clearFields();
      if (response.contentLength! >= 20) {
        var convertDataToJson = json.decode(response.body);
        _countvol = convertDataToJson['result'][0]['vol'] == null
            ? 0
            : int.parse(convertDataToJson['result'][0]['vol']);
        _countprod = convertDataToJson['result'][0]['count'] == null
            ? 0
            : int.parse(convertDataToJson['result'][0]['count']);
      }
    });
  }

  Future clearData() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/delInvoices.php?idUser=$idUser"),
        headers: {"Accept": "application/json"});
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      if (response.contentLength! >= 20) {
        clearFields();
      }
    });
  }

  int segmentedControlValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: 36,
        title: const Text(
          'Conferência',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Row(
                children: <Widget>[
                  Text("Chave NFe"),
                  IconButton(
                    icon: Icon(Icons.download_sharp),
                    highlightColor: Colors.pink,
                    onPressed: () {
                      showDialogKey();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    highlightColor: Colors.pink,
                    onPressed: () {
                      showDialogClear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
                height: MediaQuery.of(context).size.height - 50,
                alignment: Alignment.center,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _getvol(context, data),
                    _picture(context, data),
                    _data(context, data),
                    _ShowEanBarcode(context, data),
                    Text(
                      'SKU : $_sku  |  EAN : $_scanBarcode',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            _KeyNfe.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: FutureBuilder<List<NFe>>(
                      future: fetchInvoice(
                          http.Client(), user, _KeyNfe.substring(25, 10)),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          if (kDebugMode) {
                            print(snapshot.error);
                          }
                          return Center(child: CircularProgressIndicator());
                        } else {
                          if (snapshot.hasData) {
                            _qty = snapshot.data!.length;
                            _onRefresh();
                            return PhotosList(
                                invoice: snapshot.data!, user: user);
                          } else {
                            _qty = 0;
                            return Center(child: CircularProgressIndicator());
                          }
                        }
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer(Duration(seconds: 2), () {
      completer.complete();
    });
    _qty = _qty;
    return completer.future;
  }

  Widget _getvol(BuildContext context, var data) {
    return Stack(children: [
      InkWell(
        onTap: getvol,
        child: Row(
          children: [
            Text(
              'Volumes: $_countvol  |  ',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Produtos: $_countprod',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _picture(BuildContext context, var data) {
    return Stack(alignment: const Alignment(0.6, 0.6), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
        child: InkWell(
          onTap: () {
            getProdBling(_sku);
          },
          child: FadeInImage(
            image: AssetImage(
              _imagePath,
            ),
            placeholder: AssetImage(
              "assets/images/load.gif",
            ),
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.width / 5,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/nopic.png',
                  fit: BoxFit.contain); // Text('😢');
            },
            fit: BoxFit.fill,
          ),
        ),
        // child: Image.network(
        //   '$_imagePath',
        //   height: 160,
        // ),
      ),
    ]);
  }

  Widget _data(BuildContext context, data) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        alignment: const Alignment(0.6, 0.6),
        children: [
          Center(
            child: AutoSizeText(
              _title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void clearFields() {
    setState(() {
      myController.clear();
      _title = '';
      _imagePath = '';
      FocusScope.of(context).requestFocus(myfocusNode);
    });
  }

  // Widget _GetEanBarcode(BuildContext context, data) {
  //   return Row(
  //     children: <Widget>[
  //       Expanded(
  //         flex: 3, // doesn't work
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
  //           child: TextButton(
  //             onPressed: (() async {
  //               await scanBarcodeNormal();
  //               await splitBarcode();
  //               await getProd();
  //               if (_sku.length >= 4) {
  //                 dialog();
  //               }
  //               return;
  //             }),
  //             child: Text("Código De Barras / EAN"),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _ShowEanBarcode(BuildContext context, data) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.blueAccent,
        primaryColorDark: Colors.red,
      ),
      child: RawKeyboardListener(
        focusNode: focusNode,
        onKey: (event) async {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            _barcode = myController.text;
            splitBarcode();
            await getProd();
            checkInventory(_barcode, _newquant, idUser.toString());
            setState(() {
              _countvol = _countvol - 1;
              _countprod = _countprod - _newquant;
              myController.text = "";
              FocusScope.of(context).requestFocus(myfocusNode);
            });
            return;
          }
        },
        child: TextField(
          style: TextStyle(color: Colors.white, fontSize: 20),
          focusNode: myfocusNode,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
            hintText: 'Código do Produto',
            helperText: 'Código de Barras / Sku',
            labelText: 'EAN/SKU',
            prefixIcon: const Icon(
              Icons.barcode_reader,
              color: Colors.blueAccent,
            ),
            prefixText: ' + ',
            // suffixText: 'Limpa',
            suffixIcon: IconButton(
              onPressed: () => myController.clear(),
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            suffixStyle: const TextStyle(color: Colors.green),
          ),
          controller: myController,
          onSubmitted: (value) {
            _barcode = myController.text;
            splitBarcode();
            getProd();
            // checkInventory(_barcode, _newquant, idUser);
            clearFields();

            myController.clear();
            FocusScope.of(context).requestFocus(myfocusNode);
            return;
          },
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
        ),
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool _checkAddress(String value) {
    if (!isNumeric(value.substring(0, 1)) &&
        isNumeric(value.substring(1, 3)) &&
        value.length == 3) {
      return true;
    } else {
      return false;
    }
  }
}

// ignore: must_be_immutable
class PhotosList extends StatefulWidget {
  final List<NFe> invoice;
  String user;

  PhotosList({super.key, required this.invoice, required this.user});

  @override
  _PhotosListState createState() => _PhotosListState(usr: user);
}

class _PhotosListState extends State<PhotosList> {
  _PhotosListState({required this.usr});

  // String _scanLocation;
  // String Nfe;
  // String _store;
  // DateTime _date;
  String usr;
  late bool saved;

  Null get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";

  // String _scanBarcode = 'Desconhecido';
  // String _title = "";
  // int _barcode = 0;
  int captured = 0;

  // int _quant = 0;
  // int _quant2 = 0;
  // int _quant3 = 0;
  // int _quantot = 0;
  // String _imagePath = '';
  var data;

  void _showDialog(context, idx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          content: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/load.gif',
                  image: _url + widget.invoice[idx].sku + '.jpg',
                ),

                // Image.network(
                //   _url + widget.nfe[idx].sku + '.jpg',
                //   height: 250,
                //   width: 250,
                //   fit: BoxFit.cover,
                // ),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  side: WidgetStateProperty.all(
                    BorderSide.lerp(
                        BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.blueGrey,
                          width: 1.0,
                        ),
                        BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        2.0),
                  ),
                ),
                child: Text(widget.invoice[idx].sku.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(-2.0, 0.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Shadow(
                          offset: Offset(0.0, -0.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Shadow(
                          offset: Offset(2.0, 0.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Shadow(
                          offset: Offset(0.0, 2.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.invoice.length <= 0 ? 0 : widget.invoice.length,
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white10,
                alignment: Alignment.center,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/logosys.png',
                          image: widget.invoice[index].thumbnailUrl,
                          height: 80,
                          width: 60,
                          fit: BoxFit.contain,
                        ),
                        onTap: () {
                          _showDialog(context, index);
                        },
                        title: Container(
                          width: 20.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.grey),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.black),
                                      side: WidgetStateProperty.all(
                                        BorderSide.lerp(
                                            BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.blueGrey,
                                              width: 1.0,
                                            ),
                                            BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                            2.0),
                                      ),
                                    ),
                                    child: Text(
                                      widget.invoice[index].sku +
                                          '\n' +
                                          widget.invoice[index].ean,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      //launch(data[index]["link"],
                                      //    forceWebView: false);
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.grey),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.black),
                                      side: WidgetStateProperty.all(
                                        BorderSide.lerp(
                                            BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.blueGrey,
                                              width: 1.0,
                                            ),
                                            BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                            2.0),
                                      ),
                                    ),
                                    child: Text(
                                      widget.invoice[index].qty +
                                          " (" +
                                          widget.invoice[index].captured +
                                          ')',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: double.parse(widget
                                                      .invoice[index].qty) >
                                                  1
                                              ? Colors.red
                                              : Colors.blueAccent),
                                    ),
                                    onPressed: () {
                                      //launch(data[index]["link"],
                                      //    forceWebView: false);
                                    },
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   flex: 2,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(0.0),
                              //     child: FlatButton(
                              //       onPressed: () {
                              //         // scanBarcodeNormal(index);
                              //       },
                              //       padding: EdgeInsets.all(0.0),
                              //       child: Image.asset(
                              //         'assets/images/postit.png',
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        subtitle: SizedBox(
                          width: 20.0,
                          height: 55.0,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              widget.invoice[index].title.toLowerCase(),
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
