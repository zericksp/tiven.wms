import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/items.dart';

class Inventory extends StatefulWidget {
  final String idUser;

  const Inventory({super.key, required this.idUser});

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _InventoryState createState() => _InventoryState(user: idUser.toString());
}

class _InventoryState extends State<Inventory> {
  late String title, user;

  _InventoryState({required this.user});

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Inventory';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.from(colorScheme: ColorScheme.light()),
      title: appTitle,
      home: InventoryPage(title: appTitle, user: this.user),
    );
  }
}

class InventoryPage extends StatefulWidget {
  final String title, user;

  const InventoryPage({super.key, required this.title, required this.user});

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _InventoryPageState createState() => _InventoryPageState(usr: user);
}

class _InventoryPageState extends State<InventoryPage> {
  final String _value = "0";
  bool blFetch = false;
  late int _intBar, _barcode, _quant = 0;
  late String _usr, _sku, _location, contentText;
  String _title = '';
  final String _url = 'https://www.tiven.com.br/crud/images/';
  String _imagePath = 'https://www.tiven.com.br/crud/images/nopic.jpg';
  var data;
  late int _estAtual;
  int _qty = 0;
  int _newquant = 0;
  final int _inventory = 1;
  final int _team = 1;
  late String title, usr;
  var focusNode = FocusNode();
  var myfocusNode = FocusNode();
  final myController = TextEditingController();
  final myQtyController = TextEditingController();

  _InventoryPageState({required this.usr});

  Future<void> _total(_newqty) async {
    setState(() {
      _newquant = _newqty;
      contentText = _newquant.toString();
      myQtyController.text = contentText;
    });
  }

  int showInt(int intDun) {
    if (_barcode.toString().substring(1, 8) == "7896497") {
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
    } else if (_barcode.toString().substring(1, 8) == "7897807") {
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
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 50,
        leading: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  this._qty == 0 ? "" : this._qty.toString(),
                  style: TextStyle(
                      color: Color.fromARGB(255, 109, 106, 106),
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Balanço",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 360,
        title: Row(
          children: <Widget>[Text("Junho-2022")],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            color: Colors.black,
            child: Column(
              children: [
                _picture(context, data),
                _data(context, data),
                _ShowEanBarcode(context, data),
                // _GetEanBarcode(context, data),
                Container(child: _ListItems()),
              ],
            )),
      ),
    );
  }

  Widget _picture(BuildContext context, var data) {
    return Stack(alignment: const Alignment(0.7, 0.7), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
        child: InkWell(
          onTap: () {
            getProd();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.network(
              _imagePath,
              height: 80,
              width: 80,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(
                  'assets/images/nopic.png',
                  height: 80,
                  width: 80,
                ); // Text('😢');
              },
              fit: BoxFit.scaleDown,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // ignore: unused_local_variable
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      _barcode = int.parse(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
  }

  getDigtin(_barcode) {
    int _intval1 = 0;
    int _intval2 = 0;
    int _round = 0;
    int $length = _barcode.toString().length - 1;
    double _sum = 0;
    int _digit = 0;

    for (int x = 0; x <= $length; x++) {
      print(x);
      if (x == $length) {
        _intval2 += int.parse(_barcode.toString().substring(x, x + 1));
      } else if ((x % 2) == 0) {
        _intval1 += int.parse(_barcode.toString().substring(x, x + 1));
      } else {
        _intval2 += int.parse(_barcode.toString().substring(x, x + 1));
      }
    }

    _intval2 = (_intval2 * 3);

    _sum = (_intval1 + _intval2) * 1.0;
    _sum = (_sum / 10);
    _round = _sum.round() + 1;
    _round = _round * 10;
    _digit = _round - (_intval1 + _intval2);
    if (_digit == 10) {
      _digit = 0;
    }

    _barcode = _barcode.toString() + (_digit).toString();
    return _barcode;
  }

  Future<void> splitBarcode() async {
    if (_barcode.toString().length == 14) {
      _qty = showInt(int.parse(_barcode.toString().substring(0, 1)));
      _barcode =
          int.parse(getDigtin(int.parse(_barcode.toString().substring(1, 13))));
    } else if (_barcode.toString().length == 13) {
      _qty = 1;
    }
    _newquant = _qty;
  }

  void clearFields() {
    setState(() {
      // _ListItems();
      myController.clear();
      _title = '';
      _imagePath = '';
      FocusScope.of(context).requestFocus(myfocusNode);
    });
  }

  Future insertInventory_(String _inventory, String _team, String _sku,
      String _barcode, String _newquant, String _user) async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/insInventory.php?inventory=$_inventory&team=$_team&barcode=$_barcode&sku=$_sku&quantity=$_newquant&user=$_user"),
        headers: {"Accept": "application/json"});

    if (response.contentLength! >= 100) {
      print(response.body);
    }
  }

  Future insertInventory(String _inventory, String _team, String _sku,
      String _barcode, String _newquant, String _user) async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/insInventory.php?inventory=$_inventory&team=$_team&barcode=$_barcode&sku=$_sku&quantity=$_newquant&user=$_user"),
        headers: {"Accept": "application/json"});

    setState(() {
      if (response.contentLength! >= 100) {
        print(response.body);
      }
    });
  }

  Future dialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        myQtyController.text = _newquant.toString();
        return StatefulBuilder(builder: (context, snapshot) {
          return AlertDialog(
            elevation: 8,
            title: Container(
              height: 20,
              child: Row(children: [
                Text('Leitura de Produto'),
              ]),
            ),
            content: Container(
              height: 280,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.network(
                      '$_url$_sku.jpg',
                      height: 120,
                      width: 120,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/images/nopic.png',
                          height: 80,
                          width: 80,
                        ); // Text('😢');
                      },
                      fit: BoxFit.scaleDown,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${_title.toLowerCase()}?",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('$_qty * ',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.justify),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: SpinBox(
                            min: 1,
                            max: 50,
                            value: 1,
                            spacing: 2,
                            direction: Axis.horizontal,
                            textStyle: TextStyle(fontSize: 16),
                            incrementIcon:
                                Icon(Icons.keyboard_arrow_up, size: 12),
                            decrementIcon:
                                Icon(Icons.keyboard_arrow_down, size: 12),
                            iconColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.grey;
                              }
                              if (states.contains(MaterialState.error)) {
                                return Colors.red;
                              }
                              if (states.contains(MaterialState.focused)) {
                                return Colors.blue;
                              }
                              return Colors.black;
                            }),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(2),
                            ),
                            onChanged: (value) {
                              setState(
                                () async {
                                  await _total(value.toInt());
                                },
                              );
                            },
                          ),
                        ),
                        // Expanded(
                        //   flex: 2,
                        //   child: Text(' = ' + myQtyController.text,
                        //       style: TextStyle(
                        //           fontSize: 22, fontWeight: FontWeight.bold),
                        //       textAlign: TextAlign.justify),
                        // ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: TextField(
                                readOnly: true,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0.0),
                                  border: OutlineInputBorder(),
                                  labelText: 'total',
                                ),
                                controller: myQtyController,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Color.fromARGB(255, 95, 90, 90),
                    //Colors.grey[100],
                    minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      clearFields();
                      Navigator.of(context).pop();
                    });
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Color.fromARGB(255, 95, 90, 90),
                    //Colors.grey[100],
                    minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  child: Text(
                    "Adicionar",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await insertInventory(
                        _inventory.toString(),
                        _team.toString(),
                        _sku.toString(),
                        _barcode.toString(),
                        _newquant.toString(),
                        this.usr);
                    clearFields();
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
      },
    );
  }

  Future getProd() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/getProductByCode.php?CODE=$_barcode"),
        headers: {"Accept": "application/json"});
    print(_barcode);
    if (response.contentLength! >= 100) {
      var convertDataToJson = json.decode(response.body);
      //myController.text = '';
      data = convertDataToJson['result'];
      _title = data[0]['prd_titulo'];
      _barcode = int.parse(data[0]['prd_barcode']);
      _sku = data[0]['prd_sku'];
      _location =
          data[0]['prd_location'] == null ? 0 : (data[0]['prd_location']);
      // _location2 =
      //     data[0]['prd_location2'] == null ? 0 : (data[0]['prd_location2']);
      // _location3 =
      //     data[0]['prd_location3'] == null ? 0 : (data[0]['prd_location3']);
      _quant = data[0]['prd_quantidade'];
      // _quant2 = data[0]['prd_quantidade2'] == null
      //     ? 0
      //     : int.tryParse(data[0]['prd_quantidade2']);
      // _quant3 = data[0]['prd_quantidade3'] == null
      //     ? 0
      //     : int.tryParse(data[0]['prd_quantidade3']);
      // _quantot = _quant + _quant2 + _quant3;
      _imagePath =
          "http://www.tiven.com.br/crud/images/" + data[0]['prd_sku'] + ".jpg";
      setState(() {
        myController.text = _barcode.toString();
      });
    } else {
      setState(() {
        _title = '';
        _barcode = _barcode;
        myController.text = '';
        _sku = _sku;
        _location = "";
        _quant = 0;
        _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
        print(_barcode);
      });
    }
  }

  Widget _ShowEanBarcode(BuildContext context, data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.white,
          primaryColorDark: Colors.red,
        ),
        child: RawKeyboardListener(
          focusNode: focusNode,
          onKey: (event) async {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              _barcode = int.parse(myController.text);
              //await scanBarcodeNormal();
              while (_barcode.toString().length <= 12) {
                while (_intBar < 4) {
                  await scanBarcodeNormal();
                  _intBar++;
                }
              }
              _intBar = 0;
              if (_barcode.toString().length >= 13) {
                await splitBarcode();
                await getProd();
                if (_sku.length >= 4) {
                  await dialog();
                }
                clearFields();
              }
              return;
              // splitBarcode();
              // getProd();
              // FocusScope.of(context).nextFocus();
              // dialog();
              // myController.clear();
              // FocusScope.of(context).requestFocus(myfocusNode);
              // return;
            }
          },
          child: TextField(
            style: TextStyle(color: Colors.white, fontSize: 20),
            focusNode: myfocusNode,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'Código do Produto',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              //helperText: myController.text.length.toString() + '/14',
              //helperStyle: TextStyle(color: Colors.grey),
              labelText: 'EAN/SKU',
              labelStyle: TextStyle(color: Colors.grey),
              prefixIcon: IconButton(
                color: Colors.white,
                onPressed: (() async {
                  await scanBarcodeNormal();
                  await splitBarcode();
                  await getProd();
                  if (_sku.length >= 4) {
                    dialog();
                  }
                  return;
                }),
                icon: Icon(Icons.chrome_reader_mode),
              ),
              prefixText: ' + ',
              // suffixText: 'Limpa',
              suffixIcon: IconButton(
                color: Colors.white,
                onPressed: () => myController.clear(),
                icon: Icon(Icons.delete),
              ),
              suffixStyle: const TextStyle(color: Colors.green),
            ),
            controller: myController,
            onChanged: (value) {
              setState(
                () async {},
              );
            },
            onSubmitted: (value) {
              _barcode = int.parse(myController.text);
              splitBarcode();
              getProd();
              myController.clear();
              FocusScope.of(context).requestFocus(myfocusNode);
              return;
//            setState(() {
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
      ),
    );
  }

  Widget _ListItems() {
    return Container(
      height: 500,
      color: Colors.black,
      child: FutureBuilder<List<InvItems>>(
        future: fetchInvItems(this.usr, true, _value.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none &&
              !snapshot.hasData) {
            return Container(
              height: 20,
              color: Colors.black,
              child: Text(
                "Aguardando conexão...",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 20,
              color: Colors.black,
              child: Text(
                "Carregando a lista...",
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {}
          _onRefresh();
          Future.delayed(Duration(seconds: 1));
          return ItemsList(Items: snapshot.data!, usr: this.usr);
        },
      ),
    );
  }

  Future<Widget> _ListItems_() async {
    return Container(
      height: 500,
      color: Colors.black,
      child: blFetch == true
          ? Container()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: FutureBuilder<List<InvItems>>(
                future: fetchInvItems(this.usr, true, _value.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // this._qty = snapshot.data.length;
                    _onRefresh();
                    return ItemsList(Items: snapshot.data!, usr: this.usr);
                  } else if (snapshot.hasError == true) {
                    if (kDebugMode) {
                      print(snapshot.error);
                    }
                    return Center(
                        child: CircularProgressIndicator(color: Colors.grey));
                  } else {
                    _qty = 0;
                    return Center(
                        child: CircularProgressIndicator(color: Colors.grey));
                  }
                },
              ),
            ),
    );
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer timer = Timer(Duration(seconds: 1), () {
      completer.complete();
    });
    this._qty = this._qty;
    return completer.future;
  }
}

class ItemsList extends StatefulWidget {
  final List<InvItems> Items;
  late String usr;

  ItemsList({Key? key, required this.Items, required this.usr})
      : super(key: key);

  @override
  _ItemsListState createState() => _ItemsListState(usr: this.usr);
}

class _ItemsListState extends State<ItemsList> {
  _ItemsListState({required this.usr});
  late String _scanLocation;
  late String _location;
  late String usr;
  late bool saved;
  final myController = TextEditingController();

  get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";
  final String _scanBarcode = 'Desconhecido';
  final String _title = "";
  final int _barcode = 0;
  final String _sku = "";
  final int _location2 = 0;
  final int _location3 = 0;
  final int _quant = 0;
  final int _quant2 = 0;
  final int _quant3 = 0;
  final int _quantot = 0;
  final String _imagePath = 'https://www.tiven.com.br/crud/images/nopic.jpg';
  late bool _notFound, _badLabel, _urgRepo, _obs = false;
  var data;
  var focusNode = FocusNode();
  var myfocusNode = FocusNode();
  final int _newquant = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // qtdeController.dispose();
    // locController.dispose();
    myController.dispose();
    focusNode.dispose();
    myfocusNode.dispose();
    super.dispose();
  }

  _printLatestValue() {
    print("Second text f");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _List(),
    );
  }

  Future<void> sendMessage(String _code, String _message) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/insertMessage.php?CODE=$_code&MESSAGE=$_message"),
        headers: {"Accept": "application/json"});

    if (response.contentLength! >= 1) {
      print("");
    }
  }

  Future insIssue(String _user, String _sku, String _type, bool _status) async {
    saved = false;
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/insertIssue.php?isu_user=$_user&isu_sku=$_sku&isu_type=$_type&isu_status=$_status"),
        headers: {"Accept": "application/json"});
    setState(() {
      if (response.contentLength! >= 20) {
        var data = json.decode(response.body);
        saved = data["code"] == 0 ? false : true;
      }
    });
  }

  Widget _List() {
    // fetchInvItems(this.usr, true, "1");
    // ItemsList();
    return ListView.builder(
      itemCount: widget.Items.length <= 0 ? 0 : widget.Items.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Container(
              color: Color.fromARGB(255, 0, 0, 0),
              alignment: Alignment.center,
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
                            widget.Items[index].thumbnailUrl,
                            height: 60,
                            width: 60,
                            errorBuilder: (BuildContext context,
                                Object? exception, StackTrace? stackTrace) {
                              sendMessage(widget.Items[index].sku,
                                  'Foto nao localizada no repositorio');
                              return Image.asset(
                                  'assets/images/nopic.png'); // Text('😢');
                            },
                            fit: BoxFit.scaleDown,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      onTap: () {
                        // _showDialog(context, index);
                      },
                      title: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: AutoSizeText(
                                widget.Items[index].sku,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: AutoSizeText(
                                widget.Items[index].gtin,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  color: Colors.yellow,
                                  child: AutoSizeText(
                                    widget.Items[index].address,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 3,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Container(
                        width: 20.0,
                        height: 40.0,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: AutoSizeText(
                            '${widget.Items[index].qty} * ${widget.Items[index].title.toLowerCase()}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
