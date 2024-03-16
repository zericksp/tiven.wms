import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:strings/strings.dart';
import 'package:tiven/pages/items.dart';

class Expedition extends StatefulWidget {
  final String idUser, nOrder, store, nStore, market, idxOrder;

  Expedition(
      {Key? key,
      required this.idUser,
      required this.nOrder,
      required this.store,
      required this.nStore,
      required this.market,
      required this.idxOrder})
      : super(key: key);

  @override
  _ExpeditionState createState() => _ExpeditionState(
      user: idUser,
      nOrder: nOrder,
      store: store,
      nStore: nStore,
      market: market,
      idxOrder: idxOrder);
}

class _ExpeditionState extends State<Expedition> {
  late String title;
  final String user, nOrder, store, nStore, market, idxOrder;

  _ExpeditionState(
      {required this.user,
      required this.nOrder,
      required this.store,
      required this.nStore,
      required this.market,
      required this.idxOrder});

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Expedition';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: ExpeditionPage(
          title: appTitle,
          user: user,
          nOrder: nOrder,
          store: store,
          nStore: nStore,
          market: market,
          idxOrder: idxOrder),
    );
  }
}

class ExpeditionPage extends StatefulWidget {
  final String title, user, nOrder, store, nStore, market, idxOrder;

  ExpeditionPage(
      {Key? key,
      required this.title,
      required this.user,
      required this.nOrder,
      required this.store,
      required this.nStore,
      required this.market,
      required this.idxOrder})
      : super(key: key);

  @override
  _ExpeditionPageState createState() => _ExpeditionPageState(
      usr: user,
      nOrder: nOrder,
      store: store,
      nStore: nStore,
      market: market,
      idxOrder: idxOrder);
}

class _ExpeditionPageState extends State<ExpeditionPage> {
  String _value = "0";
  int _qty = 0;
  late String title, _usr;
  final String usr, nOrder, store, nStore, market, idxOrder;

  _ExpeditionPageState(
      {required this.usr,
      required this.nOrder,
      required this.store,
      required this.nStore,
      required this.market,
      required this.idxOrder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        toolbarHeight: 30,
        leading: Center(
          child: Text(
            _qty <= 0 ? "" : _qty.toString(),
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        leadingWidth: 40,
        title: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    width: 1.0, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        child: FutureBuilder<List<NFe>>(
          future: fetchNFe(http.Client(), usr, nOrder, nStore),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                _qty = snapshot.data!.length;
                _onRefresh();
                return PhotosList(
                    nfe: snapshot.data!,
                    user: usr,
                    nOrder: nOrder,
                    nStore: nStore);
              } else {
                _qty = 0;
                return Center(child: CircularProgressIndicator());
              }
            }
          },
        ),
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    Timer timer = Timer(Duration(seconds: 2), () {
      completer.complete();
    });
    _qty = _qty;
    return completer.future;
  }
}

class PhotosList extends StatefulWidget {
  final List<NFe> nfe;
  String user, nOrder, nStore;

  PhotosList(
      {Key? key,
      required this.nfe,
      required this.user,
      required this.nOrder,
      required this.nStore})
      : super(key: key);

  @override
  _PhotosListState createState() =>
      _PhotosListState(usr: user, nOrder: nOrder, nStore: nStore);
}

class _PhotosListState extends State<PhotosList> {
  _PhotosListState(
      {required this.usr, required this.nOrder, required this.nStore});

  late String _scanLocation;
  late String Nfe;
  late String _store;
  String nOrder;
  String nStore;
  late DateTime _date;
  String usr;
  late bool saved;

  get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";
  String _scanBarcode = 'Desconhecido';
  String _title = "";
  int _barcode = 0;
  String _sku = "";
  int captured = 0;
  int _quant = 0;
  int _quant2 = 0;
  int _quant3 = 0;
  int _quantot = 0;
  var data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.nfe.length <= 0 ? 0 : widget.nfe.length,
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
                          image: widget.nfe[index].thumbnailUrl,
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
                                      widget.nfe[index].sku +
                                          '\n' +
                                          widget.nfe[index].ean,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      scanBarcodeNormal(index);
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
                                      widget.nfe[index].qty +
                                          " (" +
                                          widget.nfe[index].captured +
                                          ')',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: double.parse(
                                                      widget.nfe[index].qty) >
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
                        subtitle: Container(
                          width: 20.0,
                          height: 55.0,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              widget.nfe[index].title.toLowerCase(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(0),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //           Text(
                      //           capitalize(widget.nfe[index].nClient.toLowerCase()),
                      //           style: TextStyle(
                      //             fontSize: 15,
                      //             color: Colors.blueAccent,
                      //           ),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //     ],
                      //   ),
                      // ),
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

  Future<void> scanBarcodeNormal(int idx) async {
    String barcodeScanRes;
    int _intCaptured = 1;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // scan barrcode from external source
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);

      // check if scanner captured valid code found
      if (barcodeScanRes.toString() == widget.nfe[idx].ean.toString() ||
          barcodeScanRes.toString() == widget.nfe[idx].sku.toString()) {
        if (_intCaptured <=
            (int.parse(widget.nfe[idx].qty) -
                    int.parse(widget.nfe[idx].captured)) +
                1) {
          setState(
            () {
              widget.nfe[idx].captured =
                  (int.parse(widget.nfe[idx].captured) + _intCaptured)
                      .toString();
              //       setQty(
              //           http.Client(),
              //           widget.nfe[idx].sku,
              //           widget.nfe[idx].ean,
              //           widget.nfe[idx].title,
              //           widget.nfe[idx].address,
              //           '1');
            },
          );
        }
      }
      print(barcodeScanRes);
      if (widget.nfe[idx].captured == widget.nfe[idx].qty) {
        setState(() {
          widget.nfe.removeAt(idx);
          if (widget.nfe.length == 0) {
            setPicked(http.Client(), usr, nOrder, nStore, '1');
            Navigator.pop(context);
          }
        });
      }
    } on PlatformException {
      barcodeScanRes = 'Falha ao verificar versão da plataforma.';
    }

    final snackBar = SnackBar(
      backgroundColor: // int.parse(widget.nfe[idx].qty) -
          // int.parse(widget.nfe[idx].captured) >
          //0
          // ?
          Colors.blueAccent[300],
      // : Colors.redAccent.withValues(alpha:0.9)

      content: Text(double.parse(widget.nfe[idx].qty) ==
              0 //widget.nfe[idx].captured
          ? widget.nfe[idx].qty +
              " - " +
              widget.nfe[idx].title.toString() +
              ' capturados'
          : 'Todos ' + widget.nfe[idx].title.toString() + ' foram capturados'),
      action: SnackBarAction(
        textColor:
            double.parse(widget.nfe[idx].qty) == 0 //widget.nfe[idx].captured
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
                  placeholder: 'assets/load.gif',
                  image: _url + widget.nfe[idx].sku + '.jpg',
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
                child: Text(widget.nfe[idx].sku.toString(),
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

  snacksaved() {
    final snackbar = SnackBar(
      backgroundColor: saved
          ? Colors.blueAccent[300]
          : Colors.redAccent.withValues(alpha: 0.9),
      content: saved
          ? Text("Ocorrência com " + _sku + " registrada com sucesso!")
          : Text("Ocorrência com " + _sku + " não registrada!"),
      action: SnackBarAction(
        textColor: saved ? Colors.black : Colors.white,
        label: 'Fechar',
        onPressed: () {
          // código para desfazer a ação!
        },
      ),
      duration: Duration(seconds: 3),
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
