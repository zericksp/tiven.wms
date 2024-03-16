// ignore_for_file: must_be_immutable
import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiven/data/BlingDB.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/items.dart';

class Picking_Nfe extends StatefulWidget {
  final String title, username;

  Picking_Nfe({Key? key, required this.title, required this.username})
      : super(key: key);

  @override
  _Picking_NfeState createState() =>
      _Picking_NfeState(title: title, idUser: username);
}

class _Picking_NfeState extends State<Picking_Nfe> {
  final String title, idUser;
  _Picking_NfeState({required this.title, required this.idUser});

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Picking_Nfe';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.from(colorScheme: ColorScheme.light()),
      title: appTitle,
      home: Picking_NfePage(title: appTitle, idUser: idUser),
    );
  }
}

class Picking_NfePage extends StatefulWidget {
  final String title, idUser;

  Picking_NfePage({Key? key, required this.title, required this.idUser})
      : super(key: key);

  @override
  _Picking_NfePageState createState() => _Picking_NfePageState(idUser: idUser);
}

class _Picking_NfePageState extends State<Picking_NfePage> {
  String _value = "0";
  String _courier = "0";
  // String _status = "NFe";
  bool _checkbox = false;
  int _qty = 0;
  late int _barcode, intNFes = 0;
  late String _usr, data;
  late final String title, idUser;
  bool blFetch = false;
  _Picking_NfePageState({required this.idUser});
  String _KeyNfe = "";
  var focusNode = FocusNode();
  var myfocusNode = FocusNode();
  var mykeyfocusNode = FocusNode();
  final myController = TextEditingController();
  final myKeyController = TextEditingController();
  String barcodeScanRes = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 50,
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 20,
                width: 20,
              )
            ],
          ),
        ),
        leadingWidth: 30,
        title: Row(
          children: <Widget>[
            Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    width: 1.0, color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    onChanged: (String? value) {
                      setState(
                        () {
                          _value = value.toString();
                          blFetch = (_value.toString() != '0');
                          _usr = _usr;
                          _qty = _qty;
                        },
                      );
                    },
                    value: _value,
                    items: <DropdownMenuItem<String>>[
                      // Geral
                      DropdownMenuItem(
                        value: '0',
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            'Loja',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      // Vip Capas
                      DropdownMenuItem(
                          value: 'VIP CAPAS',
                          child: Container(
                            child: Text(
                              'Vip Capas',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            padding: EdgeInsets.all(0),
                          )),
                      // ********  Eladecora  ********
                      // Eladecora
                      DropdownMenuItem(
                        value: 'ELA DECORA',
                        child: Text(
                          'Eladecora',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      ),
                    ],
                    dropdownColor: Color.fromARGB(255, 34, 31, 31)),
              ),
            ),
            Container(
              width: 125,
              padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    width: 1.0, color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  onChanged: (String? value) {
                    setState(
                      () {
                        _courier = value.toString();
                        // _value = value.toString();
                        blFetch = (_value.toString() != '0' && _courier != '0');
                        _usr = _usr;
                        _qty = _qty;
                      },
                    );
                  },
                  value: _courier,
                  items: <DropdownMenuItem<String>>[
                    // Geral
                    DropdownMenuItem(
                      value: '0',
                      child: Text(
                        'Transportadora ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // ********  Eladecora  ********
                    // Site
                    DropdownMenuItem(
                      value: 'Loja',
                      child: Text(
                        'Retira Loja',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),

                    // Loggi
                    DropdownMenuItem(
                      value: 'Loggi',
                      child: Text(
                        'Loggi',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 252, 255)),
                      ),
                    ),

                    //
                    DropdownMenuItem(
                      value: 'Mandae',
                      child: Text(
                        'Mandae',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'TEX COURIER S.A',
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Sedex',
                      child: Text(
                        'Correios',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ],
                  dropdownColor: Color.fromARGB(255, 34, 31, 31),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
              child: Row(
                children: <Widget>[
                  //Text("NFe"),
                  IconButton(
                    icon: Icon(Icons.download_sharp),
                    highlightColor: Colors.pink,
                    onPressed: () {
                      showDialogKey();
                    },
                  ),
                  Container(
                    width: 20,
                  ),
                  // Text("Limpar"),
                  IconButton(
                    icon: Icon(Icons.delete_forever),
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
      body: blFetch
          ? RefreshIndicator(
              onRefresh: _onRefresh,
              child: FutureBuilder<List<Photo>>(
                future:
                    // fetchVwEdItems(this.idUser, _checkbox,
                    //    _value.toString(), _courier.toString()),
                    getBlingOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData) {
                      _qty = snapshot.data!.length;
                      _onRefresh();
                      return PhotosList(photos: snapshot.data!, user: idUser);
                    } else {
                      _qty = 0;
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                },
              ),
            )
          : Container(
              color: Colors.black,
            ),
    );
  }

  Future<void> clearDataPicking(
      String $user, String $strStore, String $strCourier) async {
    http.Client client = http.Client();
    String strparam = 'https://www.tiven.com.br/picking/del_picking.php';
    //strparam = '127.0.0.1/tiven/picking/siteED.php';
    strparam += '?user=' + $user;
    strparam += '&isu_status=true';
    // strparam += '&store=' + $strStore;
    // strparam += '&courier=' + $strCourier;
    final response = await client.get(Uri.parse(strparam));
    print(response.body);
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer(Duration(seconds: 2), () {
      completer.complete();
    });
    _qty = _qty;
    return completer.future;
  }

  Future<void> scanBarcodeNormal() async {
    // ignore: unused_local_variable
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      _barcode = int.parse(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
  }

  Future<void> scanBarcodeNfe() async {
    // ignore: unused_local_variable
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
  }

  Future getAccessKey(KeyNfe) async {
    var response = await http.get(
        // Uri.parse("http://localhost/crud/getNfeByKey.php?keynfe=43210490406117000162550000001151321942649269&idUser=13"),headers: {"Accept": "application/json"});
        Uri.parse("http://www.tiven.com.br/picking/InsPickingByNfeKey.php?keynfe=$KeyNfe&idUser=$idUser"),
        headers: {"Accept": "application/json"});
    print(_barcode);
    if (response.contentLength! >= 100) {
      var convertDataToJson = json.decode(response.body);
      //myController.text = '';
      data = convertDataToJson['result'];
      _barcode = int.parse(data[0]);
    } else {
      setState(() {
        _barcode = _barcode;
        print(_barcode);
      });
    }
  }

  Future showDialogKey() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 231, 134, 6),
          elevation: 8,
          title: Row(
            children: [
              Text(
                'Nota Fiscal Eletrônica',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: TextField(
            controller: myKeyController,
            maxLines: 4,
            onTap: () async {
              await scanBarcodeNfe();
              setState(() {
                myKeyController.text = barcodeScanRes;
                _KeyNfe = myKeyController.text;
                getAccessKey(_KeyNfe);
                myKeyController.clear();
                FocusScope.of(context).requestFocus(mykeyfocusNode);
                return;
              });
            },
            focusNode: mykeyfocusNode,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              hintText: 'Chave /Número NFe',
              helperText: 'Notas adicionadas: $intNFes',
              labelText: 'NFe',
              labelStyle: TextStyle(color: Colors.black87),
              prefixIcon: const Icon(
                Icons.chrome_reader_mode,
                color: Colors.black87,
              ),
              suffixIcon: IconButton(
                onPressed: () => myKeyController.clear(),
                icon: Icon(Icons.delete),
                color: Colors.black87,
              ),
              suffixStyle: const TextStyle(color: Colors.black26),
            ),
            onChanged: (value) {
              setState(
                () {
                  if (value.length == 44) {
                    getAccessKey(value);
                    // dialog();
                    myKeyController.clear();
                    FocusScope.of(context).requestFocus(mykeyfocusNode);
                    return;
                  }
                },
              );
            },
            onSubmitted: (value) {
              setState(
                () {
                  _KeyNfe = myKeyController.text;
                },
              );
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
          actions: <Widget>[
            TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
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
                  "Fechar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    clearFields();
                    Navigator.of(context).pop();
                  });
                }),
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
                () async {
                  _KeyNfe = myKeyController.text;
                  await clearDataPicking(idUser, _value, _courier);
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
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
                  "Sim",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    clearFields();
                    Navigator.of(context).pop();
                  });
                }),
            TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
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
                  "Não",
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

  void clearFields() {
    setState(() {
      myController.clear();
      FocusScope.of(context).requestFocus(myfocusNode);
    });
  }
}

class PhotosList extends StatefulWidget {
  final List<Photo> photos;
  String user;

  PhotosList({Key? key, required this.photos, required this.user})
      : super(key: key);

  @override
  _PhotosListState createState() => _PhotosListState(usr: user);
}

class _PhotosListState extends State<PhotosList> {
  _PhotosListState({required this.usr});

  String usr;
  late bool saved;

  get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";
  String _sku = "";
  var data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.photos.isEmpty ? 0 : widget.photos.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Container(
              color: Color.fromARGB(255, 0, 0, 0),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Color.fromARGB(255, 0, 0, 0),
                  shadowColor: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(width: 1, color: Colors.grey)),
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.white,
                          ),
                          height: 50,
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              widget.photos[index].thumbnailUrl,
                              height: 80,
                              width: 80,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                sendMessage(widget.photos[index].sku,
                                    'Foto nao localizada no repositorio');
                                return Image.asset(
                                    'assets/images/nopic.png'); // Text('😢');
                              },
                              fit: BoxFit.scaleDown,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        onTap: () {
                          _showDialog(context, index);
                        },
                        title: Container(
                          width: 20.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor:
                                          Color.fromARGB(221, 0, 0, 0),
                                      backgroundColor:
                                          Color.fromARGB(255, 3, 0, 0),
                                      //Colors.grey[100],
                                      minimumSize: Size(88, 36),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      //launch(data[index]["link"],
                                      //    forceWebView: false);
                                    },
                                    child: Text(
                                      widget.photos[index].sku,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 253, 253, 253),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: TextButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 0, 0),
                                    minimumSize: Size(30, 36),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    // shape: RoundedRectangleBorder(
                                    //   borderRadius:
                                    //        BorderRadius.circular(3.0)),
                                  ),
                                  onPressed: () {
                                    //launch(data[index]["link"],
                                    //    forceWebView: false);
                                  },
                                  child: Text(
                                    "(${widget.photos[index].captured})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextButton(
                                  onPressed: () {
                                    _showDialogStaff(context, index, usr);
                                  },
                                  child: Image.asset(
                                    'assets/images/postit.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Container(
                          alignment: Alignment.centerLeft,
                          width: 20.0,
                          height: 55.0,
                          child: AutoSizeText(
                            //capitalize(
                            widget.photos[index].title.toLowerCase()
                            //)
                            ,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {
                                    scanBarcodeNormal(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    alignment: AlignmentGeometry.lerp(
                                        Alignment.center, Alignment.center, 5),
                                    minimumSize: Size(140, 60),
                                    maximumSize: Size(140, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      side: BorderSide(
                                          color: Colors.grey
                                              .withValues(alpha: 0.5)),
                                    ),
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.white,
                                    elevation: 3,
                                  ),
                                  child: Column(children: [
                                    Image.asset(
                                      'assets/images/scanme.png',
                                      width: 240,
                                      height: 30,
                                    ),
                                    Text("Scanner",
                                        style: TextStyle(fontSize: 8)),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {
                                    scanBarcodeNormal(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    alignment: AlignmentGeometry.lerp(
                                        Alignment.center, Alignment.center, 5),
                                    minimumSize: Size(140, 60),
                                    maximumSize: Size(140, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                      side: BorderSide(
                                          color: Colors.grey
                                              .withValues(alpha: 0.5)),
                                    ),
                                    backgroundColor: Colors.blue.shade900
                                        .withValues(alpha: 0.1),
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.white,
                                    elevation: 3,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        // Image.asset(
                                        //   'assets/images/scanme.png',
                                        //   width: 30,
                                        //   height: 30,
                                        // ),
                                        Text(widget.photos[index].box,
                                            style: TextStyle(fontSize: 12)),
                                        Text(widget.photos[index].order,
                                            style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () {
                                //
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromARGB(221, 0, 0, 0),
                                backgroundColor: Color.fromARGB(255, 3, 0, 0),
                                //Colors.grey[100],
                                minimumSize: Size(88, 36),
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              child: Text(
                                widget.photos[index].ean,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Color.fromARGB(255, 194, 157, 47)),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.yellow),
                                  side: WidgetStateProperty.all(
                                    BorderSide.lerp(
                                        BorderSide(
                                          style: BorderStyle.solid,
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        BorderSide(
                                          style: BorderStyle.solid,
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        1.0),
                                  ),
                                ),
                                child: AutoSizeText(
                                  widget.photos[index].address,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(-1.0, 0.0),
                                        blurRadius: 2.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(0.0, -0.0),
                                        blurRadius: 2.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 0.0),
                                        blurRadius: 2.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      Shadow(
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                ),
                                onPressed: () => scanBarcodeLocation(
                                    widget.photos[index].sku),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMessage(String code, String message) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/insertMessage.php?CODE=$code&MESSAGE=$message"),
        headers: {"Accept": "application/json"});

    if (response.contentLength! >= 1) {
      print("");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeLocation(sku) async {
    String locationScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      locationScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      String value = locationScanRes;
      bool chkadd = _checkAddress(value);

      if (chkadd == true) {
        updateLocation(sku, value.toString());
        //print(locationScanRes);
      }
    } on PlatformException {
      locationScanRes = 'Falha ao verificar versão da plataforma.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      //String _scanLocation = _location.toString();
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
        _sku = data[0]['prd_sku'];
      });
    }
  }

  Future insIssue(String user, String sku, String type, bool status) async {
    saved = false;
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/insertIssue.php?isu_user=$user&isu_sku=$sku&isu_type=$type&isu_status=$status"),
        headers: {"Accept": "application/json"});
    setState(() {
      if (response.contentLength! >= 20) {
        var data = json.decode(response.body);
        saved = data["code"] == 0 ? false : true;
      }
    });
  }

  int showInt(int intDun) {
    switch (intDun) {
      case 6:
        {
          return 2;
        }
      case 5:
        {
          return 3;
        }
      case 4:
        {
          return 4;
        }
      case 7:
        {
          return 5;
        }
      case 1:
        {
          return 6;
        }
      case 2:
        {
          return 8;
        }

      case 8:
        {
          return 10;
        }

      case 3:
        {
          return 12;
        }
      case 9:
        {
          return 16;
        }

      default:
        {
          return 1;
        }
    }
  }

  Future<void> scanBarcodeNormal(int idx) async {
    String barcodeScanRes;
    int intCaptured = 1;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // scan barrcode from external source
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);

      // check for DUN14
      if (barcodeScanRes.length == 14) {
        intCaptured = showInt(int.parse(barcodeScanRes.substring(0, 1)));
        barcodeScanRes = barcodeScanRes.substring(1, 13);
      }

      // check if scanner captured valid code found
      if (barcodeScanRes.toString() == widget.photos[idx].ean.toString() ||
          barcodeScanRes.toString() == widget.photos[idx].sku.toString()) {
        if (intCaptured <=
            (int.parse(widget.photos[idx].qty) -
                    int.parse(widget.photos[idx].captured)) +
                1) {
          setState(
            () {
              widget.photos[idx].captured =
                  (int.parse(widget.photos[idx].captured) + intCaptured)
                      .toString();
              setQty(
                  http.Client(),
                  widget.photos[idx].sku,
                  widget.photos[idx].ean,
                  widget.photos[idx].title,
                  widget.photos[idx].address,
                  '1');
            },
          );
        }
      }
      if (kDebugMode) {
        print(barcodeScanRes);
      }
      if (widget.photos[idx].captured == widget.photos[idx].qty) {
        setState(
          () {
            widget.photos.removeAt(idx);
          },
        );
      }
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }

    final snackBar = SnackBar(
      backgroundColor: int.parse(widget.photos[idx].qty) -
                  int.parse(widget.photos[idx].captured) >
              0
          ? Colors.blueAccent[300]
          : Colors.redAccent.withValues(alpha: 0.9),
      content: Text(widget.photos[idx].qty == widget.photos[idx].captured
          ? widget.photos[idx].qty +
              " - " +
              widget.photos[idx].title.toString() +
              ' capturados'
          : 'Todos ' +
              widget.photos[idx].title.toString() +
              ' foram capturados'),
      action: SnackBarAction(
        textColor: widget.photos[idx].qty == widget.photos[idx].captured
            ? Colors.black
            : Colors.white,
        label: 'Fechar',
        onPressed: () {
          // código para desfazer a ação!
        },
      ),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
                  placeholder: 'assets/images/load.gif',
                  image: _url + widget.photos[idx].sku + '.jpg',
                ),

                // Image.network(
                //   _url + widget.photos[idx].sku + '.jpg',
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
                child: Text(widget.photos[idx].sku.toString(),
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

  void _showDialogStaff(context, idx, user) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white10.withValues(alpha: 0.8),
              actions: <Widget>[
                Container(
                  width: 400,
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Registro de Ocorrências",
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
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
                                onPressed: () async {
                                  await insIssue(user, widget.photos[idx].sku,
                                      "Nao Localizado", false);
                                  if (saved) {
                                    snacksaved();
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(Icons.search_off),
                                    Text("Não Localizado")
                                  ],
                                ),
                              ),
                              TextButton(
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
                                onPressed: () async {
                                  await insIssue(usr, widget.photos[idx].sku,
                                      "Etiqueta Ruim", false);
                                  if (saved) {
                                    snacksaved();
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(Icons.label_off),
                                    Text("Etiqueta Ruim")
                                  ],
                                ),
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
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
                                onPressed: () async {
                                  await insIssue(usr, widget.photos[idx].sku,
                                      "Reposição", false);
                                  if (saved) {
                                    snacksaved();
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(Icons.library_add),
                                    Text("Reposição")
                                  ],
                                ),
                              ),
                              TextButton(
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
                                onPressed: () async {
                                  await insIssue(usr, widget.photos[idx].sku,
                                      "Sem endereço", false);
                                  if (saved) {
                                    snacksaved();
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                                child: Column(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(Icons.mail_outline),
                                    Text("Sem endereço")
                                  ],
                                ),
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.mic_none),
                            Text("Observações"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.grey),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.black),
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
                                Navigator.of(context).pop();
                              });
                            },
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(Icons.reset_tv),
                                Text("Cancelar")
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  snacksaved() {}

  bool isNumeric(String s) {
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
