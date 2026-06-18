import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:tiven/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/items.dart';

class Repositing extends StatefulWidget {
  final String title;
  final String idUser;
  final String username;

  const Repositing(
      {Key? key,
      required this.title,
      required this.idUser,
      required this.username})
      : super(key: key);

  @override
  _RepositingState createState() =>
      _RepositingState(title: title, idUser: idUser, user: username);
}

class _RepositingState extends State<Repositing> {
  final String title, idUser, user;

  _RepositingState(
      {required this.title, required this.idUser, required this.user});

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Repositing';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.from(colorScheme: ColorScheme.light()),
      title: appTitle,
      home: RepositingPage(title: appTitle, idUser: idUser, user: user),
    );
  }
}

class RepositingPage extends StatefulWidget {
  final String title, idUser, user;

  const RepositingPage(
      {super.key,
      required this.title,
      required this.idUser,
      required this.user});

  @override
  _RepositingPageState createState() =>
      _RepositingPageState(idUser: idUser, usr: user);
}

class _RepositingPageState extends State<RepositingPage> {
  late final String title, idUser, usr;

  _RepositingPageState({required this.usr, required String idUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Reposição',
                style:
                    TextStyle(fontWeight: FontWeight.w100, color: Colors.white),
              ),
            ],
          )),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<Repo>>(
          future: fetchRepos(http.Client(), idUser),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? ReposList(repos: snapshot.data!)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Future<Null> _onRefresh() {
  Completer<Null> completer = Completer<Null>();
  Timer(Duration(seconds: 3), () {
    completer.complete();
  });
  return completer.future;
}

class ReposList extends StatefulWidget {
  final List<Repo> repos;

  const ReposList({Key? key, required this.repos}) : super(key: key);

  @override
  _ReposListState createState() => _ReposListState();
}

class _ReposListState extends State<ReposList> {
  late String _scanLocation;
  late String _location;

  Null get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";
  final String _scanBarcode = 'Desconhecido';
  String _title = "";
  int _barcode = 0;
  String _sku = "";
  final int _location2 = 0;
  final int _location3 = 0;
  int _quant = 0;
  final int _quant2 = 0;
  final int _quant3 = 0;
  final int _quantot = 0;
  String _imagePath = '';
  var data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.repos.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(seconds: 1),
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Column(
            children: [
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                elevation: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/logosys.png',
                          image: widget.repos[index].thumbnailUrl,
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill,
                        ),
                      ),
                      onTap: () {
                        _showDialog(context, index);
                      },
                      title: SizedBox(
                        width: 20.0,
                        height: 30.0,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(6.0),
                        //   color: Colors.white,
                        // ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 6,
                              child: ElevatedButtons(
                                height: 22,
                                obj: Text(
                                  widget.repos[index].sku,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ElevatedButtons(
                                height: 22,
                                obj: Text(
                                  widget.repos[index].qty,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.lightBlue,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Toggle light when tapped.
                                      scanBarcodeNormal(index);
                                    });
                                  },
                                  child: ElevatedButtons(
                                    height: 22,
                                    obj: Image.asset(
                                      'assets/images/postit.png',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        //capitalize(
                        widget.repos[index].title.toLowerCase().capitalize()
                        //)
                        ,
                        style: TextStyle(
                            fontSize: 15,
                            height: 1.1,
                            // fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.yellow,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 4, 24, 8),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                // Toggle light when tapped.
                                scanBarcodeNormal(index);
                              });
                            },
                            child: SizedBox(
                              height: 35,
                              width: 90,
                              child: Image.asset(
                                'assets/images/scan.png',
                                height: 25.0,
                                width: 35.0,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButtons(
                              height: 22,
                              obj: Text(widget.repos[index].ean.toString(),
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                scanBarcodeLocation(widget.repos[index].ean);
                              },
                              child: ElevatedButtons(
                                height: 22,
                                obj: Text(widget.repos[index].address),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 5,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeLocation(sku) async {
    String locationScanRes = '';
    // Platform messages may fail, so we use a try/catch for all exceptions.
    try {
      locationScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      if (locationScanRes.isNotEmpty && locationScanRes != '-1') {
        String value = locationScanRes;
        bool chkadd = _checkAddress(value);

        if (chkadd == true) {
          updateLocation(sku, value.toString());
          //print(locationScanRes);
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
        _location = int.parse(data[0]['prd_location']) as String;
        _quant = int.parse(data[0]['prd_quantidade']);
        _imagePath =
            "http://www.tiven.com.br/crud/images/" + data[0]['prd_pic1'];
      });
    }
  }

  Future<void> scanBarcodeNormal(int idx) async {
    String barcodeScanRes = '';
    final snackBar = SnackBar(
      backgroundColor: Colors.blueGrey[300],
      content: Text('Todos foram capturados'),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Fechar',
        onPressed: () {
          // código para desfazer a ação!
        },
      ),
      duration: Duration(seconds: 2),
    );
    // Platform messages may fail, so we use a try/catch for all exceptions.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);
      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
        if (barcodeScanRes.length == 14) {
          //_newquant = int.parse(barcodeScanRes.substring(0, 1));
          barcodeScanRes = '${barcodeScanRes.substring(1, 13)}';
          setState(() {});
        } else if (barcodeScanRes.length == 13) {
          if (barcodeScanRes.toString() == widget.repos[idx].ean.toString()) {
            setState(
              () {},
            );
          }
        } else if (barcodeScanRes.length <= 8) {
          if (barcodeScanRes.toString() == widget.repos[idx].sku.toString()) {
            setState(
              () {
                setQty(
                    http.Client(),
                    widget.repos[idx].sku,
                    widget.repos[idx].ean,
                    widget.repos[idx].title,
                    widget.repos[idx].address,
                    '1');
              },
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (kDebugMode) {
          print(barcodeScanRes);
        }
      }
    } catch (e) {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }
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
                  placeholder: 'assets/load.gif',
                  image: '$_url${widget.repos[idx].sku}.jpg',
                ),

                // Image.network(
                //   _url + widget.repos[idx].sku + '.jpg',
                //   height: 250,
                //   width: 250,
                //   fit: BoxFit.cover,
                // ),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                  side: WidgetStateProperty.all(
                    BorderSide.lerp(
                        BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.white,
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
                child: Text('Fechar',
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
              Text(
                widget.repos[idx].sku.toString(),
                style: TextStyle(
                  fontSize: 28,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 5
                    ..color = Colors.black,
                ),
              ),
              // Solid text as fill.
              Text(
                widget.repos[idx].sku.toString(),
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
