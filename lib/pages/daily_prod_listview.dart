import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiven/widgets/nav-drawer.dart';
import 'package:flutter_beep_plus/flutter_beep_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:mysql1/mysql1.dart';
// import 'package:date_picker_plus/date_picker_plus.dart';

class DailyProd extends StatelessWidget {
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
  MyHomePage({required Key key, required this.title}) : super(key: key);
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
    return UserDetails(
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
  List<UserDetails> _searchResult = [];
  List<UserDetails> _userDetails = [];
  TextEditingController scanController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
    _loadQrcode();
    scanController.addListener(
      () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
    super.initState();
    fetchProductionData();
    myFocusNode = FocusNode();
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
  String _location2 = "";
  String _location3 = "";
  late String barcodeScanRes = "";
  late String qrcodeScanRes = "";
  late String _scanBarcode = "";
  late int _scanQRcode = 0;
  String _sku = "";
  String _imagePath = 'https://www.tiven.com.br/crud/images/cover.jpg';
  String _imageError = 'https://www.tiven.com.br/crud/images/nopicture.png';
  static final orgColor = Colors.black;
  var currentColor = orgColor;
  late String curDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  DateTime SelectedDate = DateTime.now();
  final _flutterBeepPlusPlugin = FlutterBeepPlus();
  List<AndroidSoundID> sounds = [];
  // AndroidSoundIDs AlertSound = AndroidSoundIDs.TONE_CDMA_ANSWER as AndroidSoundIDs;
  // AndroidSoundIDs OkSound = AndroidSoundIDs.TONE_PROP_BEEP as AndroidSoundIDs; // TONE_CDMA_ANSWER;
  final String startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final settings = ConnectionSettings(
    host: 'www.tiven.com.br', // Substitua pelo IP ou domínio do seu servidor
    port: 3306, // Porta padrão do MySQL
    user: 'eladec62_tbs',
    password: 'Pedimu\$-2019',
    db: 'eladec62_tbs',
  );
  List<dynamic> productionList = [];
  int totalQuantity = 0;
  bool isLoading = true;

  //Incrementing qrcode after click
  incrementQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setInt('qrcode', int.parse(qrcodeScanRes));
      },
    );
  }

  Future<void> fetchProductionData() async {
    final conn = await MySqlConnection.connect(settings);
    final results = await conn.query("""
      SELECT prd_codigo, SUM(prd_quantidade) AS total_quantidade, prd_descricao, prd_gtin, MAX(prd_ts) AS prd_ts
      FROM tbl_daily_produced_products
      WHERE DATE_FORMAT(prd_ts, '%Y-%m-%d') = ?
      GROUP BY prd_codigo
      ORDER BY prd_ts DESC
      """, ["2025-02-03"]
        //[startDate],
        );

    List<Map<String, dynamic>> fetchedData = [];
    int sumTotal = 0;
    for (var row in results) {
      var item = {
        'prd_codigo': row[0],
        'total_quantidade': row[1],
        'prd_descricao': row[2],
        'prd_gtin': row[3],
        'prd_ts': row[4],
      };
      sumTotal += row[1] as int;
      fetchedData.add(item);
    }

    await conn.close();

    setState(() {
      productionList = fetchedData;
      totalQuantity = sumTotal;
      isLoading = false;
    });
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> insDailyProd(
      BuildContext context, _sku, _title, _barcode) async {
    MySqlConnection? conn;
    int qty = 1;
    try {
      conn = await MySqlConnection.connect(settings);

      String query = '''
      INSERT INTO tbl_daily_produced_products 
      (prd_codigo, prd_descricao, prd_quantidade, prd_gtin)
      VALUES (?, ?, ?, ?)
    ''';

      await conn.query(query, [_sku, _title, qty, _barcode]);

      // Exibir Snackbar de sucesso (Laranja)
      showSnackbar(context, "Produto inserido com sucesso!", Colors.orange);
    } catch (e) {
      // Exibir Snackbar de erro (Vermelho)
      showSnackbar(context, "Erro ao inserir produto: $e", Colors.red);
    } finally {
      await conn?.close();
    }
  }

  Future<String> getToken(String appId) async {
    MySqlConnection? conn;
    try {
      // Conectar ao banco de dados
      conn = await MySqlConnection.connect(settings);

      // Chamar a procedure armazenada
      var results = await conn.query('CALL prc_getBlingToken(?)', [appId]);

      // Retorna o token se houver resultado
      if (results.isNotEmpty) {
        return results.first['accessToken'] as String;
      } else {
        return "Nenhum resultado encontrado.";
      }
    } catch (e) {
      throw Exception("Erro no banco de dados: $e");
    } finally {
      // Garante que a conexão será fechada
      await conn?.close();
    }
  }

  Future<void> fetchData() async {
    try {
      final conn = await MySqlConnection.connect(settings);
      var result = await conn.query(
          'SELECT prd_codigo, prd_descricao, prd_gtin, prd_localizacao, prd_localizacao2, prd_localizacao3 FROM tbl_produtos WHERE prd_codigo = $_barcode or prd_gtin = $_barcode');
      if (result.isNotEmpty) {
        var row = result.first;
        _title = row['prd_descricao'];
        _barcode = row['prd_gtin'].toString();
        _sku = row['prd_codigo'];
        _location = row['prd_localizacao'] ?? "N/A";
        _location2 = row['prd_localizacao2'] ?? "N/A";
        _location3 = row['prd_localizacao3'] ?? "N/A";
        _imagePath = "https://www.tiven.com.br/crud/images/" +
            row["prd_codigo"] +
            ".jpg";
      } else {
        setState(() {
          _title = '';
          // _barcode = '';
          _sku = '';
          _location = "";
          _location2 = "";
          _location3 = "";
          _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
          print(_barcode);
        });
      }
      await conn.close();
    } catch (e) {
      _sku = '';
      print("Erro: $e");
    }
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.BARCODE);
    _scanBarcode = barcodeScanRes;
    barcodeTreatment();
  }

  Future<void> fetchProductBySKU(String _barcode) async {
    const String apiUrl = "https://www.bling.com.br/Api/v3/produtos";
    String token = await getToken(clientId);

    final Uri uri = Uri.parse("$apiUrl?codigo=$_barcode");

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
      _barcode = "";
      _sku = data['data'][0]['prd_codigo'].toString();
      _location = "N/A";
      _location2 = "N/A";
      _location3 = "N/A";
      _imagePath = "https://www.tiven.com.br/crud/images/" +
          data['data'][0]["prd_codigo"] +
          ".jpg";
    } else {
      setState(() {
        _title = '';
        _barcode = '';
        _sku = '';
        _location = "";
        _location2 = "";
        _location3 = "";
        _imagePath = 'http://www.tiven.com.br/crud/images/notregistered.png';
        print(_barcode);
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

  Future getProd(String _code) async {
    var response = await http.get(
        Uri.parse(
            "https://www.tiven.com.br/crud/getProductByCode.php?CODE=$_code"),
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
        print(_code);
      });
    }
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.firstName.contains(text) ||
          userDetail.lastName.contains(text)) _searchResult.add(userDetail);
    });

    setState(() {});
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
            Text(
              "Produção    ",
              textAlign: TextAlign.start,
              style: TextStyle(
                inherit: true,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() async {
                  DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: SelectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026));
                  // change curDate to view historical daily production
                  // curDate = DateFormat('dd/MM/yyyy').format(newDate!);
                });
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(
                    Color.fromARGB(255, 230, 96, 7)),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                side: WidgetStateProperty.all(
                  BorderSide.lerp(
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey.withValues(alpha: 0.3),
                        strokeAlign: BorderSide.strokeAlignCenter,
                        width: 1.0,
                      ),
                      BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                      3.0),
                ),
              ),
              child: Text(
                curDate,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.sync,
            //     color: Colors.grey,
            //   ),
            //   onPressed: () async {
            //     //Scaffold.of(context).openDrawer();
            //     qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            //         "#ff6666", "Cancel", true, ScanMode.QR);
            //     setScan();
            //     _qrcode = int.parse(qrcodeScanRes);
            //     incrementQrcode();
            //   },
            //   tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            // ),
            //  Image.asset(
            //   'assets/images/logo.png',
            //   fit: BoxFit.contain,
            //   height: 32,
            // ),
            // Container(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Text(
            //     widget.title,
            //     style: TextStyle(
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      drawer: NavDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   "Produção do Dia",
              //   textAlign: TextAlign.start,
              //   style: TextStyle(
              //     inherit: true,
              //     fontSize: 20.0,
              //     color: Colors.grey,
              //   ),
              // ),
              Divider(color: Colors.grey.withValues(alpha: 0.5)),
              _picture(context, data),
              Divider(color: Colors.grey.withValues(alpha: 0.5)),
              Text(
                '$_title',
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
              Container(
                child: TextField(
                  // readOnly: true,
                  focusNode: myFocusNode,
                  keyboardType: TextInputType.none,
                  controller: scanController,
                  autofocus: true,
                  onChanged: (code) async {
                    _scanBarcode = scanController.text;
                    await barcodeTreatment();
                    await fetchData();
                    if (_sku.length <= 1) {
                      fetchProductBySKU(_barcode);
                    }
                    // getProd(_barcode);
                    if (_sku.length <= 3) {
                      _flutterBeepPlusPlugin
                          .playSysSound(AndroidSoundID.TONE_CDMA_PIP);
                    } else {
                      setState(() {
                        _sku = _sku;
                      });
                      //await insDailyProd(context, _sku, _title, _barcode);
                      await _flutterBeepPlusPlugin
                          .playSysSound(AndroidSoundID.TONE_CDMA_MED_SS);
                      sleep(Duration(milliseconds: 150));
                      await _flutterBeepPlusPlugin
                          .playSysSound(AndroidSoundID.TONE_CDMA_SIGNAL_OFF);
                    }
                    fetchProductionData();
                    Future.delayed(Duration(milliseconds: 200), () {
                      myFocusNode.requestFocus();
                    });
                    scanController.text = '';
                    Future.delayed(Duration(milliseconds: 200), () {
                      myFocusNode.requestFocus();
                    });
                  },

                  onTap: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0)),
                    labelText: 'Leitor',
                    labelStyle: TextStyle(color: Colors.grey),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
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
                ),
              ),
              // Divider(color: Colors.black),
              Container(
                height: 20,
                color: Colors.black,
                alignment: Alignment.center,
                child: Text(
                  '$_barcode',
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
              //     await scanBarcodeNormal();
              //     await getProd(_barcode);
              //     setState(() {
              //       scanController.text = _sku;
              //       _sku = _sku;
              //     });
              //   },
              //   child: Text(
              //     "Leitor",
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontFamily: "Arial",
              //       fontSize: 20,
              //     ),
              //   ),
              // ),
              !isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Total Produzido: $totalQuantity',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: productionList.length,
                            itemBuilder: (context, index) {
                              final item = productionList[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(item['prd_descricao']),
                                  subtitle: Text(
                                      'Código: ${item['prd_codigo']} - GTIN: ${item['prd_gtin']}'),
                                  trailing:
                                      Text('Qtd: ${item['total_quantidade']}'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
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
            progressIndicatorBuilder:
                (context, _imageError, downloadProgress) =>
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
        !_sku.isEmpty
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
                  _sku.toString() + "\n" + _location.toString(),
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
