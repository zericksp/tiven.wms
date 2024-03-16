import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../effects/shadows.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_tags/simple_tags.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:tiven/pages/supplier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Returns extends StatefulWidget {
  final String user, idUser;

  const Returns({Key? key, required this.idUser, required this.user})
      : super(key: key);

  @override
  _ReturnsState createState() => _ReturnsState(user: user, idUser: idUser);
}

class _ReturnsState extends State<Returns> {
  final String _urlimage = "https://www.tiven.com.br/crud/images/";
  final String user, idUser;

  _ReturnsState({required this.user, required this.idUser});
  final ImagePicker _picker = ImagePicker();
  late XFile imageObj;
  late XFile imageIssue;
  final myController = TextEditingController();
  final myKeyController = TextEditingController();
  late Future<File> file;
  String status = '';
  late String objBase64Image;
  late String issueBase64Image;
  late File tmpFile;
  String errMessage = 'Erro Carregando Imagem';
  String _defect = '';
  String _defects = '';
  var focusNode = FocusNode();
  var myfocusNode = FocusNode();
  var mykeyfocusNode = FocusNode();
  bool _bcode = false;
  bool _supply = false;
  late String _key;
  int _estAtual = 0;
  int _qrcode = 0;
  int _barcode = 0;
  int _scanQRcode = 0;
  String qrcodeScanRes = '';
  String _newlocation = '';
  String _scanLocation = '';
  late String barcodeScanRes;
  String _supplier = '';
  String urlimage = 'http://www.tiven.com.br/crud/images/';
  String imagePath = 'logo.png';
  String _imagePath = 'logo.png';
  String _imageObjPath = "";
  String _imageIssuePath = "";
  var data;
  var _prod;
  String _title = '';
  String _sku = '';
  String _location = '';
  int _quant = 0;

  _printLatestValue() {
    if (kDebugMode) {
      print("Second text f");
    }
  }

  @override
  void initState() {
    super.initState();
    myController.addListener(_printLatestValue);
    focusNode = FocusNode();
    myfocusNode = FocusNode();
    _loadQrcode();
  }

  //Loading qrcode value on start
  _loadQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _qrcode = (prefs.getInt('qrcode') ?? 0);
    });
  }

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)
        ?.listen((barcode) => print(barcode));
  }

  Future setScan() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=${_barcode.toString()}"),
        headers: {"Accept": "application/json"});
    if (kDebugMode) {
      print(_scanQRcode);
    }
    if (response.contentLength! >= 100) {
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson['result'];
        _barcode = data[0]['scn_value'];
      });
    } else {
      setState(() {
        _barcode = _barcode;
      });
    }
  }

  Future setScanReturn() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=$_key"),
        headers: {"Accept": "application/json"});
    print(_scanQRcode);
    if (response.contentLength! >= 100) {
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson['result'];
        _barcode = data[0]['scn_value'];
      });
    } else {
      setState(() {
        _barcode = _barcode;
      });
    }
  }

  static final String uploadEndPoint =
      'http://localhost/flutter_test/upload_image.php';

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload(imageObj, imageIssue) {
    setStatus('Uploading Image...');
    if (null == imageObj || null == imageIssue) {
      setStatus(errMessage);
      return;
    }
    // base64Image = base64Encode(bytes);
    upload();
  }

  uploadAll(String fileName, String base64Image) {
    String uploadEndPoint =
        //'http://127.0.0.1/tiven/inventory/saveData.php';
        'https://www.tiven.com.br/inventory/saveData.php';
    http.post(Uri.parse(uploadEndPoint), body: {
      "image": base64Image,
      "name": _sku + fileName,
    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }

  Future upload() async {
    var objBytes = File(imageObj.path).readAsBytesSync();
    late var IssueBytes = File(imageIssue.path).readAsBytesSync();

    objBase64Image = base64Encode(objBytes);
    issueBase64Image = base64Encode(IssueBytes);

    print('upload proccess started');
    var apipostdata = {
      'key': _key,
      'name': _sku,
      'ean': _barcode.toString(),
      'imageObj': objBase64Image,
      'imageIssue': issueBase64Image,
      'defects': _defects,
      'supplier': _supplier,
    };

    setScanReturn();

    await http
        .post(Uri.parse('https://www.tiven.com.br/inventory/saveData.php'),
            body: apipostdata)
        .then((response) async {
      var returndata = jsonEncode(response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(returndata);
        }
      } else {
        if (kDebugMode) {
          print('failed');
        }
      }
    }).catchError((err) {
      setState(() {
        if (kDebugMode) {
          print(err.toString());
        }
      });
    });
  }

  Future getProdBling(String code) async {
    var response = await http.get(
        Uri.parse(
            "https://bling.com.br/Api/v2/produto/$code/json&apikey=a64370ceea64ecf3f2831d211fea334d3fd1606cca506679de43079a97d821ddc56cda49&estoque=S"),
        headers: {"Accept": "application/json"});
    if (kDebugMode) {
      print(code);
    }
    if (response.contentLength! >= 100) {
      data = json.decode(response.body);
      _prod = data['retorno']['produtos'][0]['produto'];
      // _sku = data["retorno"]["produtos"][0]["produto"]["code"].toString();
    } else {
      setState(() {
        _title = '';
        _barcode = _barcode;
        _sku = _sku;
        _location = '';
        _quant = 0;
        _imagePath = 'notregistered.png';
        if (kDebugMode) {
          print(code);
        }
      });
    }
  }

  incrementQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setInt('qrcode', int.parse(qrcodeScanRes));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: Colors.black,
          leadingWidth: 70,
          toolbarHeight: 36,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                alignment: AlignmentGeometry.lerp(
                    Alignment.bottomLeft, Alignment.bottomLeft, 5),
                height: 20,
                width: 20,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              Textstyles(
                data: 'Devoluções',
                size: 14.0,
                blColor: false,
              ),
              ElevatedButton(
                onPressed: () async {
                  //showDialogClear(),
                  final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Supplier()));
                  setState(
                    () {
                      if (result.place.toString().length >= 2) {
                        _supplier = result.place;
                        _supply = true;
                      } else {
                        _supply = false;
                      }
                    },
                  );
                  ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.amber),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.amber),
                    side: WidgetStateProperty.all(
                      BorderSide.lerp(
                          BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xffe4e978),
                            width: 10.0,
                          ),
                          BorderSide(
                            style: BorderStyle.solid,
                            color: Color(0xffe4e978),
                            width: 10.0,
                          ),
                          10.0),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade700,
                  disabledForegroundColor: Colors.black.withValues(alpha: 0.38),
                  disabledBackgroundColor: Colors.black.withValues(alpha: 0.12),
                  minimumSize: Size(60, 15),
                ),
                child: Textstyles(data: 'Fornecedor', size: 12, blColor: false),
              ),
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () async {
                  //Scaffold.of(context).openDrawer();
                  qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                      "#ff6666", "Cancel", false, ScanMode.QR);
                  setScan();
                  _qrcode = int.parse(qrcodeScanRes);
                  incrementQrcode();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ],
          ),
        ),
        body: home(context, data),
      ),
    ); // _nova == true ? home(context, data) : Container()),
  }

  Future<Widget> homeLess() async {
    return await picture(context, data);
  }

  Widget home(context, data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _supply
                ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        supplier(context, data),
                      ],
                    ),
                  )
                : Container(
                    height: 0,
                  ),
            _supply && _bcode
                ? Column(
                    children: [
                      dat(context, data),
                      address(context, data),
                    ],
                  )
                : Container(
                    height: 0,
                  ),
            _supply
                ? Column(
                    children: [
                      TextField(
                        style: TextStyle(color: Colors.white),
                        onSubmitted: (value) async {
                          String items = await getProd(value);
                          List listitems = json.decode(items) as List;
                          SizedBox(
                            height: 200.0,
                            child: ListView.builder(
                                itemCount: listitems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Text(listitems[index].prd_descricao);
                                }),
                          );
                          setState(() {
                            myController.text = _barcode.toString();
                          });
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 124, 120, 120),
                                width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          hintText: 'Pesquisar produto',
                          hintStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          helperText: 'Sku / Descrição / EAN',
                          helperStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),

                          labelText: 'Ean / Sku / Descrição',
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          labelStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          prefixIcon: IconButton(
                            onPressed: () async {
                              await scanBarcodeNormal();
                              if (_barcode.toString().length == 13) {
                                Future<String> itemList =
                                    (await getSkuProd(_barcode.toString()))
                                        as Future<String>;
                                var now = DateTime.now();
                                var formatterTime = DateFormat('HHmmss');
                                _key = formatterTime.format(now);
                                await getProdBling(_sku);
                                setState(
                                  () {
                                    _bcode = true;
                                    _estAtual = int.parse(
                                        _prod["estoqueAtual"].toString());
                                    _title = _prod["descricao"].toString();
                                    _location = _prod["localizacao"].toString();
                                    _imagePath = '${_prod["codigo"]}.jpg';
                                  },
                                );
                              } else {
                                setState(
                                  () {
                                    _bcode = false;
                                    _estAtual = 0;
                                    _title = '';
                                    _location = '';
                                  },
                                );
                              }
                            },

                            //=> scanBarcodeNormal(),
                            icon: Icon(Icons.document_scanner_outlined),
                            color: Colors.grey,
                          ),

                          // const Icon(
                          //   Icons.chrome_reader_mode,
                          //   color: Colors.grey,
                          // ),
                          prefixText: ' + ',
                          // suffixText: 'Limpa',
                          suffixIcon: IconButton(
                            onPressed: () => myController.clear(),
                            icon: Icon(Icons.delete),
                            color: Colors.grey,
                          ),
                          suffixStyle: const TextStyle(color: Colors.grey),
                        ),
                        controller: myController,
                      ),
                    ],
                  )
                : Container(
                    height: 0,
                  ),

            SizedBox(
              height: 10,
            ),
            // Text(
            //   'SKU : $_sku  |  EAN : $_barcode',
            //   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            // ),
            _bcode && _imageIssuePath.length >= 10 && _imageObjPath.length >= 10
                ? defect()
                : Container(
                    height: 0,
                  ),
            _bcode
                ? Container(
                    color: Colors.white,
                    height: 160,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            picture(context, data),
                            pictureObject(context, data),
                            pictureIssue(context, data),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                _defects.toLowerCase().capitalize(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 0,
                  ),
            _bcode &&
                    _imageIssuePath.length >= 10 &&
                    _imageObjPath.length >= 10 &&
                    _defects.length > 0
                ? Column(
                    children: [
                      ElevatedButton(
                        onPressed: (() {
                          startUpload(imageObj, imageIssue);
                          setState(() {
                            _barcode = 0;
                            _bcode = false;
                            _defect = '';
                            _defects = '';
                            _estAtual;
                            _imageIssuePath = '';
                            _imageObjPath = '';
                            _imagePath = '';
                            _key = '';
                            _location = '';
                            _newlocation = '';
                            _prod = '';
                            _quant = 0;
                            _scanLocation = '';
                            _sku = '';
                            _title = '';
                          });
                        }),
                        child: Text('Enviar'),
                      ),
                    ],
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }

  defect() {
    return ElevatedButton(
      onPressed: showDialogDefects,
      child: Text('Defeitos'),
    );
  }

  Future<String?> getSkuProd(String code) async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/getItemsImages.php?CODE=$code"),
        headers: {"Accept": "application/json"});
    if (kDebugMode) {
      print(code);
    }
    if (response.contentLength! >= 100) {
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson['result'];
        _title = data[0]['prd_titulo'];
        _barcode = int.tryParse(data[0]['prd_barcode'])!;
        _sku = data[0]['prd_sku'];
        _location = data[0]['prd_location'];
        _quant = int.tryParse(data[0]['prd_quantidade'])!;
        _imagePath = data[0]['prd_sku'] + ".jpg";
        _bcode = true;
      });
    } else {
      setState(() {
        _title = '';
        _barcode = _barcode;
        _sku = _sku;
        _location = "";
        _quant = 0;
        _imagePath = 'notregistered.png';
        if (kDebugMode) {
          print(code);
        }
      });
    }
    return null;
  }

  Future<String> getSkuProd_(code) async {
    var itemList;
    try {
      itemList = '';
      var response = await http.get(
          Uri.parse(
              "https://www.tiven.com.br/bling/getProductBySku.php?code=$code"),
          headers: {"Accept": "application/json"});
      // Uri.parse("http://www.tiven.com.br/crud/getItems.php?code=$_code"),
      // headers: {"Accept": "application/json"});
      // var response = await http.get(
      //     Uri.parse("localhost/tiven/bling/getProductBySku.php?code=$_code"),
      //     headers: {"Accept": "application/json"});
      // // Uri.parse("http://www.tiven.com.br/crud/getItems.php?code=$_code"),
      // // headers: {"Accept": "application/json"});
      // print(response);
      if (response.contentLength! >= 100) {
        itemList = json.decode(response.body);
        itemList = itemList["result"];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return json.decode(itemList);
  }

  Future<String> getProd(code) async {
    String ItemList = '';
    var response = await http.get(
        // Uri.parse("localhost/tiven/crud/getItems.php?itm=$_code"),
        // headers: {"Accept": "application/json"});
        Uri.parse("http://www.tiven.com.br/crud/getItemsImages.php?code=$code"),
        headers: {"Accept": "application/json"});

    if (response.contentLength! >= 100) {
      ItemList = response.body;
    }
    return ItemList;
  }

  Widget _picture(BuildContext context, var data) {
    return Stack(alignment: const Alignment(0.7, 0.7), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
        child: InkWell(
          onTap: () {
            // getProdBling(_sku);
          },
          child: Image.network(
            _imagePath,
            height: 80,
            width: 60,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset('assets/images/logo.png'); // Text('😢');
            },
          ),
        ),
      ),
    ]);
  }

  final List<String> content = [
    'Acabamento',
    'Amassado',
    'Bucha',
    'Deformado',
    'Desgaste',
    'Embalagem',
    'Errado',
    'Falta',
    'Ferrugem',
    'Lascado',
    'Parafuso',
    'Plástico',
    'Pintura',
    'Quebrado',
    'Solda',
    'Riscos',
    'Torto',
    'Trincado',
    'Ventosa'
  ];

  Future showDialogDefects() async {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        String contentText = 'Defeitos do Produto';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 8,
              title: InkWell(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            width: 1.0,
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Defeitos do produto",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    SimpleTags(
                      content: content,
                      wrapSpacing: 4,
                      wrapRunSpacing: 4,
                      onTagPress: (tag) {
                        bool inTag = _defect.toString().contains(tag);
                        if (inTag) {
                          setState(() {
                            _defect = _defect.replaceAll(tag, '');
                          });
                        } else {
                          setState(() {
                            if (kDebugMode) {
                              print('defeito = $tag');
                            }
                            _defect += '$tag ';
                          });
                        }
                      },
                      // onTagLongPress: (tag) {
                      //   _defect.replaceAll(tag, '');
                      //   _defect += tag + ' ';
                      //   //print('long pressed $tag');
                      //   print('defeitos = $_defects');
                      //   setState(
                      //     () async {
                      //       setState(() {
                      //         //Navigator.of(context).pop();
                      //       });
                      //     },
                      //   );
                      // },
                      onTagDoubleTap: (tag) {
                        _defect.replaceAll(tag, '');
                        _defect += tag;
                        print('defeitos = $_defects');
                        setState(
                          () async {
                            setState(() {
                              _defects = _defect;
                              _defect = '';
                              Navigator.of(context).pop();
                            });
                          },
                        );
                        if (kDebugMode) {
                          print('double tapped $tag');
                        }
                      },
                      tagContainerPadding: EdgeInsets.all(6),
                      tagTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      tagIcon: Icon(Icons.clear, size: 12),
                      tagContainerDecoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(139, 139, 142, 0.16),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(1.75, 3.5), // c
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _defect,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() async {
                    // var route = new MaterialPageRoute(
                    //   builder: (BuildContext context) => new Supplier(),
                    // );
                    // final result = await Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => Supplier()));
                    // print('teste: ' + result.toString());
                    setState(
                      () {},
                    );
                  });
                },
              ),
              actions: <Widget>[
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
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        _defect = '';
                        Navigator.of(context).pop();
                      });
                    }),
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
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      setState(() {
                        _defects = _defect;
                        _defect = '';
                        Navigator.of(context).pop();
                      });
                    }),
              ],
            );
          },
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
              setState(() async {
                var route = MaterialPageRoute(
                  builder: (BuildContext context) => Supplier(),
                );
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Supplier()));
                if (kDebugMode) {
                  print('teste: $result');
                }
                setState(
                  () {},
                );
              });
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
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                }),
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
                  //   _countprod = 0;
                  //   _countvol = 0;
                  //   _supplier = "";
                  //   _nfe = "";
                  //   _invoicedate = "";
                  //   clearData();
                  // checkInventory(_barcode, _newquant, idUser);
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Future<int> scanBarcodeNormal() async {
    // ignore: unused_local_variable
    _barcode = 0;
    try {
      while (_barcode < 1) {
        String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancelar", true, ScanMode.BARCODE);
        _barcode = int.parse(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
    return _barcode;
  }

  Future<Future> showDialogBarcode(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          backgroundColor:
              Color.fromARGB(255, 202, 196, 196).withValues(alpha: 0.9),
          elevation: 8,
          title: Row(
            children: [
              Textstyles(data: 'Busca por produto', size: 14.0, blColor: false),
              // new Text(
              //   'Informe a Chave de Acesso da NFe',
              //   style: TextStyle(fontSize: 12),
              // ),
            ],
          ),
          content: TextField(
            textAlign: TextAlign.center,
            maxLines: 4,
            onChanged: (context) async {
              //print(myController.text);
              // await getProd (myController.text);
            },
            onTap: () async {
              _barcode = await scanBarcodeNormal();
              barcodeScanRes = _barcode.toString();
              if (barcodeScanRes.length == 13) {
                myKeyController.text = barcodeScanRes.toString();
                _barcode = int.parse(myKeyController.text);
                // dialog();
                myKeyController.clear();
                setState(
                  () {
                    barcodeScanRes = '';
                  },
                );
                FocusScope.of(context).requestFocus(mykeyfocusNode);
                Navigator.of(context).pop();
                // return;
              }
              _barcode = 0;
            },

            focusNode: mykeyfocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Informe SKU, descrição ou EAN',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              helperText: 'Pesquisar (SKU / EAN / Descrição)',
              hintStyle: TextStyle(fontSize: 10),
              labelText: 'NFe',
              prefixIcon: const Icon(
                Icons.chrome_reader_mode,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                onPressed: () => myKeyController.clear(),
                icon: Icon(
                  Icons.delete,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              suffixStyle:
                  const TextStyle(color: Color.fromARGB(255, 100, 152, 201)),
            ),
            controller: myKeyController,
            onSubmitted: (value) {
              setState(
                () {
                  _barcode = int.parse(myKeyController.text);
                },
              );
              myKeyController.clear();
              FocusScope.of(context).requestFocus(mykeyfocusNode);
              // return;
//            setState(() {
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                  child: Text(
                    "Pesquisar",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        // clearFields();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
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
                  child: Text(
                    "Fechar",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        Navigator.of(context).pop();
                        //getaceesskey,
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  picture(BuildContext context, var data) {
    return Container(
      alignment: const Alignment(0.7, 0.7),
      height: 80,
      child: InkWell(
        onTap: () {
          getProdBling(_sku);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            _urlimage + _imagePath,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset(
                'assets/images/logo.png',
                height: 80,
              );
            },
          ),
        ),
      ),
    );
  }

  pictureObject(BuildContext context, var data) {
    return Stack(
      alignment: const Alignment(0.7, 0.7),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () async {
              imageObj = (await _picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 600,
                maxHeight: 800,
                imageQuality: 100,
              ))!;
              setState(() {
                _imageObjPath = imageObj.path;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(_imageObjPath),
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return TextButton.icon(
                    icon: Icon(Icons.add_a_photo,
                        color: Colors.black), // Your icon here
                    label: Text('Produto',
                        style:
                            TextStyle(color: Colors.black)), // Your text here
                    onPressed: () async {
                      // using your method of getting an image
                      imageObj = (await _picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 600,
                        maxHeight: 800,
                        imageQuality: 100,
                      ))!;
                      setState(() {
                        _imageObjPath = imageObj.path;
                      });
                      //startUpload("_Prod", image);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  pictureIssue(BuildContext context, var data) {
    return Stack(
      alignment: const Alignment(0.7, 0.7),
      children: [
        InkWell(
          onTap: () async {
            imageIssue = (await _picker.pickImage(
              source: ImageSource.camera,
              maxWidth: 600,
              maxHeight: 800,
              imageQuality: 100,
            ))!;
            setState(() {
              _imageIssuePath = imageIssue.path;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(_imageIssuePath),
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return TextButton.icon(
                  icon: Icon(Icons.add_a_photo,
                      color: Colors.black), // Your icon here
                  label: Text(
                    'Defeito',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    imageIssue = (await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 600,
                      maxHeight: 800,
                      imageQuality: 100,
                    ))!;
                    setState(() {
                      _imageIssuePath = imageIssue.path;
                    });
                    //startUpload("_Def", image);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget dat(BuildContext context, data) {
    return Stack(
      alignment: const Alignment(0.2, 0.2),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 20, 2, 2),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 14, 13, 13).withValues(alpha: 0.7),
            ),
            child: Center(
              child: AutoSizeText(
                _title.toLowerCase().capitalize(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
                maxLines: 2,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget supplier(BuildContext context, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: AutoSizeText(
            'Fornecedor : $_supplier',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget address(BuildContext context, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Flexible(
            child: Text(
              'Endereço',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w100),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _location,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget quantity(BuildContext context, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2.0, left: 10, right: 10),
          child: Text(
            'Quantidade',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$_estAtual',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ],
    );
  }

  Widget getAddress(BuildContext context, data) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    icon: Icon(Icons.add_location),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        minimumSize: Size(120, 50),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        shadowColor: Colors.grey,
                        elevation: 10),
                    label: Text('Localização'),
                    onPressed: () {
                      scanBarcodeLocation();
                      setState(() {});
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> scanBarcodeLocation() async {
    String locationScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      locationScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      _newlocation = (locationScanRes).toString();
      //updateLocation((locationScanRes).toString());
      if (kDebugMode) {
        print(locationScanRes);
      }
    } on PlatformException {
      locationScanRes = 'Falha ao verificar versão da plataforma.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanLocation = _location = _location.toString();
    });
  }

  Widget getEanBarcode(BuildContext context, data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.document_scanner_outlined),
          style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 255, 255, 255),
              minimumSize: Size(120, 50),
              backgroundColor: Color.fromARGB(255, 41, 39, 39),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              shadowColor: Colors.grey,
              elevation: 10),
          label: Text('Produto'),
          onPressed: () async {
            _barcode = await scanBarcodeNormal();
            if (_barcode.toString().length >= 4) {
              Future<String> itemList =
                  (await getSkuProd(_barcode.toString())) as Future<String>;
              var data = json.decode(itemList as String);
              _sku = data['produto']['codigo'];
              var now = DateTime.now();
              var formatterTime = DateFormat('kkmmss');
              _key = formatterTime.format(now);
              getProdBling(_sku);
              setState(
                () {
                  _estAtual = int.parse(_prod["estoqueAtual"].toString());
                  _title = _prod["descricao"].toString();
                  _location = _prod["localizacao"].toString();
                  _imagePath = '${_prod["codigo"]}.jpg';
                },
              );
            } else {
              _estAtual = 0;
              _title = '';
              _location = '';
            }
          },
        ),
      ],
    );
  }

  Widget showAddress(BuildContext context, data) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3, // doesn't work
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 20, 10),
            child: Center(
              child: Text(
                '$_newlocation',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
