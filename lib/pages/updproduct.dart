import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiven/utils/getData.dart';
import 'package:tiven/utils/functions.dart';
import 'package:tiven/widgets/beeps.dart';
import 'package:tiven/widgets/dialogMoveAddress.dart';
import 'package:tiven/widgets/nav-drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:mysql1/mysql1.dart';

class UpdateProd extends StatelessWidget {
  const UpdateProd({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      initialRoute: '/',
      title: 'tiven',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'tiven', key: UniqueKey()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class UserDetails {
  final int id;
  final String firstName, lastName, profileUrl;

  UserDetails(
      {required this.id,
      required this.firstName,
      required this.lastName,
      this.profileUrl =
          'https://i.amz.mshcdn.com/3NbrfEiECotKyhcUhgPJHbrL7zM=/950x534/filters:quality(90)/2014%2F06%2F02%2Fc0%2Fzuckheadsho.a33d0.jpg'});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    // ignore: unnecessary_new
    return new UserDetails(
      id: json['id'],
      firstName: json['name'],
      lastName: json['username'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _qrcode = 0;
  String _barcode = "";
  var data;
  final List<UserDetails> _searchResult = [];
  final List<UserDetails> _userDetails = [];
  TextEditingController scanController = TextEditingController();
  TextEditingController scanAddController = TextEditingController();
  late FocusNode myFocusNodeItem;
  late FocusNode myFocusNodeAddress;
  late FocusNode myFocusNodeNewAddress;
  @override
  void initState() {
    _loadQrcode();
    scanController.addListener(
      () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
    scanAddController.addListener(
      () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
    super.initState();
    myFocusNodeItem = FocusNode();
    myFocusNodeAddress = FocusNode();
    myFocusNodeNewAddress = FocusNode();
    myFocusNodeItem.addListener(() {
      if (myFocusNodeItem.hasFocus) {
        scanController.clear(); // Limpa o campo quando recebe foco
      }
    });
    myFocusNodeAddress.addListener(() {
      if (myFocusNodeAddress.hasFocus) {
        scanAddController.clear(); // Limpa o campo quando recebe foco
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Loading qrcode value on start
  _loadQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _qrcode = (prefs.getInt('qrcode') ?? 0);
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  late String _title = "";
  String clientId = '5ec82041fae60a71485134ad93e576357f746eb7';
  String _location = "";
  late String barcodeScanRes = "";
  late String qrcodeScanRes = "";
  late String _scanBarcode = "";
  late String _lastCode = "";
  late String _scanAddress = "";
  late String _lastAddress = "";
  late final int _scanQRcode = 0;
  String _sku = "";
  late int _id = 0;
  String _imagePath = 'https://www.tiven.com.br/crud/images/cover.jpg';
  final String _imageError =
      'https://www.tiven.com.br/crud/images/nopicture.png';
  static final orgColor = Colors.black;
  var currentColor = orgColor;
  late String curDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  DateTime SelectedDate = DateTime.now();
  bool shouldCheck = false;
  bool shouldCheckDefault = false;
  // AndroidSoundIDs AlertSound = AndroidSoundIDs.TONE_CDMA_ANSWER as AndroidSoundIDs;
  // AndroidSoundIDs OkSound = AndroidSoundIDs.TONE_PROP_BEEP as AndroidSoundIDs; // TONE_CDMA_ANSWER;
  final settings = ConnectionSettings(
    host: 'www.tiven.com.br', // Substitua pelo IP ou domínio do seu servidor
    port: 3306, // Porta padrão do MySQL
    user: 'eladec62_tbs',
    password: 'Pedimu\$-2019',
    db: 'eladec62_tbs',
  );

  bool isChecked = false;

  //Incrementing qrcode after click
  incrementQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setInt('qrcode', int.parse(qrcodeScanRes));
      },
    );
  }

// Função para exibir Snackbar
  void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> changeItem(BuildContext context, id, sku, location, qty) async {
    try {
      // Convertendo qty para int de forma segura
      int quantity = (qty is double) ? qty.toInt() : qty as int;

      String token = await getToken(clientId);
      String data = await getProductByCode(sku, token);
      quantity > 0
          ? updateAddressStock(context, location, sku)
          : changeItemQtyAddress(context, location, sku, quantity);
      // Exibir Snackbar de sucesso (Laranja)
      showSnackbar(context, "Item movimentado com sucesso!", Colors.orange);
    } catch (e) {
      // Exibir Snackbar de erro (Vermelho)
      showSnackbar(context, "Erro ao movimentar produto: $e", Colors.red);
    } finally {}
  }

  Future<void> fetchData() async {
    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
          'SELECT prd_id, prd_codigo, prd_descricao, prd_gtin, prd_localizacao, prd_localizacao2, prd_localizacao3 FROM tbl_produtos WHERE prd_codigo = $_barcode or prd_gtin = $_barcode');
      if (result.isNotEmpty) {
        var row = result.first;
        _id = row['prd_id'];
        _title = row['prd_descricao'];
        _barcode = row['prd_gtin'].toString();
        _sku = row['prd_codigo'];
        _location = row['prd_localizacao'] ?? "N/A";
        _imagePath = "https://www.tiven.com.br/crud/images/" +
            row["prd_codigo"] +
            ".jpg";
      } else {
        setState(() {
          _title = '';
          // _barcode = '';
          _id = 0;
          _sku = '';
          _location = "";
          _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
          print(_barcode);
        });
      }
      await conn.close();
    } catch (e) {
      _sku = '';
      if (kDebugMode) {
        print("Erro: $e");
      }
    }
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.BARCODE);
    _scanBarcode = barcodeScanRes;
    barcodeTreatment();
  }

  Future<void> fetchProductBySKU(String barcode) async {
    const String apiUrl = "https://www.bling.com.br/Api/v3/produtos";
    String token = await getToken(clientId);

    final Uri uri = Uri.parse("$apiUrl?codigo=$barcode");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      _title = data['data'][0]['nome'].toString();
      barcode = "";
      _id = data['data'][0]['prd_id'];
      _sku = data['data'][0]['prd_codigo'].toString();
      _location = "N/A";
      _imagePath =
          "https://www.tiven.com.br/crud/images/$data['data'][0]['prd_codigo'].jpg";
    } else {
      setState(() {
        _title = '';
        barcode = '';
        _id = 0;
        _sku = '';
        _location = "";
        _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
        print(barcode);
      });
    }
  }

  Future<void> barcodeTreatment() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      if (_scanBarcode.toString().length >= 4) {
        _barcode = _scanBarcode;
        setScan();
        setState(() {
          currentColor = Colors.lightGreen;
        });
        Timer(Duration(seconds: 2), () {
          setState(() {
            currentColor = orgColor;
          });
        });
      } else {
        _scanBarcode = "";
        _barcode = "";
        //FlutterBeep.playSysSound(41);
        setState(() {
          currentColor = Colors.red;
        });
        Timer(Duration(seconds: 2), () {
          setState(() {
            currentColor = orgColor;
          });
        });
      }
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      barcodeScanRes = (_scanBarcode.toString());
    });
  }

  Future setScan() async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=${_barcode.toString()}"),
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

  Future getProd(String code) async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/getProductByCode.php?CODE=$code"),
        headers: {"Accept": "application/json"});
    // print(_code);
    if (response.contentLength! >= 100) {
      var convertDataToJson = json.decode(response.body);
      data = convertDataToJson['result'];
      _title = data[0]['prd_titulo'];
      _barcode = data[0]['prd_barcode'];
      _sku = data[0]['prd_sku'];
      _location = data[0]['prd_location'] ?? "N/A";
      _imagePath =
          "https://www.tiven.com.br/crud/images/" + data[0]['prd_sku'] + ".jpg";
    } else {
      setState(() {
        _title = '';
        _barcode = '';
        _sku = '';
        _location = "";
        _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
        if (kDebugMode) {
          print(code);
        }
      });
    }
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in _userDetails) {
      if (userDetail.firstName.contains(text) ||
          userDetail.lastName.contains(text)) {
        _searchResult.add(userDetail);
      }
    }

    setState(() {});
  }

  void _toggleCheckbox() async {
    setState(() {
      isChecked = !isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isChecked
                ? Text(
                    "Movimentar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                : Text(
                    "Endereçar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
            SizedBox(
              width: 80,
            ),
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 26,
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: NavDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(color: Colors.grey.withValues(alpha: 0.5)),
                _picture(context, data),
                Divider(color: Colors.grey.withValues(alpha: 0.5)),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      inherit: true,
                      height: 2,
                      fontSize: 15.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            // bottomLeft
                            offset: Offset(-0.5, -0.5),
                            color: Colors.grey),
                        Shadow(
                            // bottomRight
                            offset: Offset(0.5, -0.5),
                            color: Colors.grey),
                        Shadow(
                            // topRight
                            offset: Offset(0.5, 0.5),
                            color: Colors.grey),
                        Shadow(
                            // topLeft
                            offset: Offset(-0.5, 0.5),
                            color: Colors.grey),
                      ]),
                ),
                TextField(
                  // readOnly: true,
                  focusNode: myFocusNodeItem,
                  keyboardType: TextInputType.none,
                  controller: scanController,
                  autofocus: true,
                  onChanged: (code) async {
                    // check for all available sounds
                    // FlutterBeepPlayer.playAllSounds(2000);
                    _scanBarcode = scanController.text;
                    // check sku valid format
                    if (isValidSku(_scanBarcode)) {
                      //
                      await barcodeTreatment();
                      await fetchData();
                      if (_sku.length <= 1) {
                        fetchProductBySKU(_barcode);
                      }

                      if (_sku.length <= 3) {
                        FlutterBeepPlayer.playSound(
                          soundIndex: 91,
                          duration: 500,
                        );
                        setState(() {
                          scanController.text = '';
                        });
                      } else {
                        setState(() {
                          _sku = _sku;
                        });
                        // await changeItem(
                        //   context,
                        //   _location,
                        //   _sku,
                        //   0
                        // );
                        if (_scanBarcode != _lastCode) {
                          FlutterBeepPlayer.playSound(
                            soundIndex: 57,
                            duration: 1000,
                          );
                        } else {
                          FlutterBeepPlayer.playSound(
                            soundIndex: 51,
                            duration: 150,
                          );
                        }
                      }
                      Future.delayed(Duration(milliseconds: 200), () {
                        myFocusNodeAddress.requestFocus();
                      });
                      _lastCode = _scanBarcode;
                      // scanController.text = '';
                      Future.delayed(Duration(milliseconds: 200), () {
                        myFocusNodeAddress.requestFocus();
                      });
                      myFocusNodeAddress.requestFocus();
                    } else {
                      FlutterBeepPlayer.playSound(
                        soundIndex: 40,
                        duration: 500,
                      );
                      setState(() {
                        scanAddController.text = '';
                      });
                    }
                  },

                  onTap: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueGrey, width: 1.0)),
                    labelText: 'Item',
                    labelStyle: TextStyle(color: Colors.grey),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.2),
                    ),
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.barcode_reader,
                          color: Colors.grey,
                          size: 24,
                        )),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () {
                        scanController.text = '';
                        myFocusNodeItem.requestFocus();
                      },
                    ),
                  ),
                ),
                // Divider(color: Colors.black),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  //address
                  focusNode: myFocusNodeAddress,
                  keyboardType: TextInputType.none,
                  controller: scanAddController,
                  autofocus: true,
                  onChanged: (code) async {
                    scanAddController.text =
                        scanAddController.text.replaceAll(' ', '');
                    _scanAddress = scanAddController.text;
                    // check address valid format
                    if (isValidAddress(_scanAddress)) {
                      _location = _scanAddress;
                      if (_scanAddress.length <= 6) {
                        FlutterBeepPlayer.playSound(
                          soundIndex: 2,
                          duration: 250,
                        );
                      } else {
                        setState(() {
                          _sku = _sku;
                        });
                        if (_scanAddress != _lastAddress) {
                          FlutterBeepPlayer.playSound(
                            soundIndex: 57,
                            duration: 1000,
                          );
                        } else {
                          FlutterBeepPlayer.playSound(
                            soundIndex: 51,
                            duration: 150,
                          );
                        }
                      }
                      sleep(Duration(milliseconds: 150));
                      Future.delayed(Duration(milliseconds: 200), () {
                        myFocusNodeItem.requestFocus();
                      });
                      _lastCode = _scanAddress;
                      // scanAddController.text = '';
                      Future.delayed(Duration(milliseconds: 200), () async {
                        if (_scanAddress.length >= 4 &&
                            _scanAddress.length >= 6) {
                          double? selectedQuantity = await showQuantityDialog(
                              context, isChecked ? 'Movimentar' : 'Endereçar');
                          if (selectedQuantity != null &&
                              selectedQuantity > 0) {
                            await changeItem(context, _id, _sku, _location,
                                selectedQuantity);
                            if (kDebugMode) {
                              print(
                                  "Quantidade selecionada: $selectedQuantity");
                            }
                          } else {
                            if (kDebugMode) {
                              print(
                                  "Nenhuma quantidade válida foi selecionada.");
                            }
                          }
                        }
                        myFocusNodeItem.requestFocus();
                      });
                    } else {
                      FlutterBeepPlayer.playSound(
                        soundIndex: 40,
                        duration: 500,
                      );
                      setState(() {
                        scanController.text = '';
                      });
                    }
                  },
                  onTap: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueGrey, width: 1.0)),
                    labelText: 'Endereço',
                    labelStyle: TextStyle(color: Colors.grey),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.2),
                    ),
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.barcode_reader,
                          color: Colors.grey,
                          size: 24,
                        )),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () {
                        scanAddController.text = '';
                        myFocusNodeAddress.requestFocus();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                isChecked
                    ? TextField(
                        // readOnly: true,
                        focusNode: myFocusNodeNewAddress,
                        keyboardType: TextInputType.none,
                        controller: scanController,
                        autofocus: true,
                        onChanged: (code) async {
                          _scanBarcode = scanController.text;
                          if (_scanBarcode
                                  .split('')
                                  .where((c) => c == '-')
                                  .length >=
                              4) {
                            _location = _scanBarcode;
                          } else {
                            await barcodeTreatment();
                            await fetchData();
                            if (_sku.length <= 1) {
                              fetchProductBySKU(_barcode);
                            }
                          }
                          // getProd(_barcode);
                          if (_sku.length <= 3) {
                            FlutterBeepPlayer.playSound(
                              soundIndex: 2,
                              duration: 250,
                            );
                          } else {
                            setState(() {
                              _sku = _sku;
                            });
                            // await changeItem(context, _location, _sku, );
                            if (_scanBarcode == _lastCode) {
                              FlutterBeepPlayer.playSound(
                                soundIndex: 1,
                                duration: 150,
                              );
                            } else {
                              FlutterBeepPlayer.playSound(
                                soundIndex: 0,
                                duration: 150,
                              );
                            }
                          }

                          Future.delayed(Duration(milliseconds: 200), () {
                            myFocusNodeNewAddress.requestFocus();
                          });
                          _lastCode = _scanBarcode;
                          // scanController.text = '';
                          Future.delayed(Duration(milliseconds: 200), () {
                            myFocusNodeNewAddress.requestFocus();
                          });
                        },

                        onTap: () {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        },
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 1.0)),
                          labelText: 'Novo Endereço',
                          labelStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.2),
                          ),
                          prefixIcon: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.barcode_reader,
                                color: Colors.grey,
                                size: 24,
                              )),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.delete_rounded,
                              color: Colors.grey,
                              size: 24,
                            ),
                            onPressed: () {
                              null;
                            },
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 48,
                      ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomCheckBox(
                        splashColor: Colors.lightBlue.withValues(alpha: 0.4),
                        splashRadius: 40,
                        tooltip: 'Movimentar / Endereçar',
                        value: shouldCheck,
                        shouldShowBorder: true,
                        uncheckedIcon: IconData(0xee44,
                            fontFamily: 'MaterialIcons',
                            matchTextDirection: true),
                        checkedIcon: IconData(0xf0357,
                            fontFamily: 'MaterialIcons',
                            matchTextDirection: true),
                        borderColor: Colors.blueAccent,
                        checkedFillColor: Colors.blueAccent,
                        uncheckedFillColor: Colors.blueGrey,
                        borderRadius: 6,
                        borderWidth: 1,
                        checkBoxSize: 35,
                        onChanged: (val) {
                          //do your stuff here
                          setState(() {
                            shouldCheck = val;
                            isChecked = !isChecked;
                          });
                        },
                      ),
                      // O texto será alterado com base no valor de isChecked
                      isChecked
                          ? Text(
                              "   Movimentar",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          : Text(
                              "   Endereçar   ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                    ],
                  ),
                ),
                Text(
                  "Altere entre Endereçar e Movimentar",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Container(
                  height: 20,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Text(
                    _barcode,
                    style: TextStyle(
                      inherit: true,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(1.5, 1.5), color: Colors.black26),
                      ],
                    ),
                  ),
                ),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.grey,
                //       shape: RoundedRectangleBorder(
                //         side: BorderSide(
                //           color: Colors.grey.shade300,
                //           width: 1,
                //           style: BorderStyle.solid,
                //           strokeAlign: BorderSide.strokeAlignOutside,
                //         ),
                //         borderRadius: BorderRadius.all(
                //           Radius.elliptical(6, 4),
                //         ),
                //       )),
                //   onPressed: () async {
                //     null;
                // await scanBarcodeNormal();
                // await getProd(_barcode);
                // setState(() {
                //   scanController.text = _sku;
                //   _sku = _sku;
                // });
                // },
                // child: Text(
                //   "Leitor",
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontFamily: "Arial",
                //     fontSize: 20,
                //   ),
                // ),
                // ),
              ]),
        ),
      ),
    );
  }

  Widget _picture(BuildContext context, var data) {
    return Stack(
      alignment: const Alignment(0.80, 0.80),
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: _imagePath,
            fit: BoxFit.fill,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Colors.white,
              radius: 80.0,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: imageProvider,
                foregroundColor: Colors.white,
              ),
            ),
            progressIndicatorBuilder: (context, imageError, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Colors.red,
              radius: 82.0,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/nopic.png'),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        _sku.isNotEmpty
            ? Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(
                      width: 1.0, color: Colors.white10.withValues(alpha: 0.7)),
                  color: Colors.white70.withValues(alpha: 0.5),
                ),
                // ignore: unnecessary_null_comparison
                child: Text(
                  "$_sku\n$_location",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              )
            : Container(),
      ],
    );
    // ...
  }
}
