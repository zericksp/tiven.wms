import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tiven/pages/expedition.dart';
import 'package:tiven/pages/items.dart';

class Orders extends StatefulWidget {
  final String idUser;

  const Orders({super.key, required this.idUser});

  @override
  _OrdersState createState() => _OrdersState(user: idUser.toString());
}

class _OrdersState extends State<Orders> {
  late final String title, user, qty;

  _OrdersState({required this.user});

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Orders';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: OrdersPage(title: appTitle, user: user, qty: qty),
    );
  }
}

class OrdersPage extends StatefulWidget {
  final String title, user;
  final String qty;

  const OrdersPage(
      {super.key, required this.title, required this.user, required this.qty});

  @override
  _OrdersPageState createState() => _OrdersPageState(usr: user);
}

class _OrdersPageState extends State<OrdersPage> {
  String _value = "0";
  late int _qty = 0;
  late String _usr;
  late String loja;
  late String nLoja;
  late String nClient;
  late String pedido;
  late String entrada;
  late String title, usr;

  _OrdersPageState({required this.usr});

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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  onChanged: (String? value) {
                    setState(
                      () {
                        _value = value.toString();
                        _qty = _qty;
                        _usr = _usr;
                      },
                    );
                  },
                  value: _value,
                  items: <DropdownMenuItem<String>>[
                    // Geral
                    DropdownMenuItem(
                      value: '0',
                      child: Text(
                        'Selecione a Loja',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Casa Premium
                    // Mercadolivre
                    DropdownMenuItem(
                        value: '203239645',
                        child: Container(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            'Casa Premium Mercadolivre',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        )),

                    // ********  Eladecora  ********
                    // B2w
                    DropdownMenuItem(
                      value: '203392836',
                      child: Text(
                        'Eladecora B2W',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),

                    // Magalu
                    DropdownMenuItem(
                        value: '203350868',
                        child: Text(
                          'Eladecora Magalu',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // Mercadolivre
                    DropdownMenuItem(
                        value: '203338810',
                        child: Text(
                          'Eladecora MercadoLivre',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // Site
                    DropdownMenuItem(
                      value: '203361398',
                      child: Text(
                        'Eladecora Site',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),

                    // *******  Prime House  **********
                    // Mercadolivre
                    DropdownMenuItem(
                        value: '203422641',
                        child: Text(
                          'Prime House MercadoLivre',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // ********  Vip Capas  ********
                    // Amazon
                    DropdownMenuItem(
                      value: '203366504',
                      child: Text(
                        'Vip Capas Amazon',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),

                    // B2w
                    DropdownMenuItem(
                        value: '203251309',
                        child: Text(
                          'Vip Capas B2W',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // Magalu
                    DropdownMenuItem(
                        value: '203313304',
                        child: Text(
                          'Vip Capas Magalu',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // MercadoLivre
                    DropdownMenuItem(
                        value: '203239615',
                        child: Text(
                          'Vip Capas MercadoLivre',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // Olist
                    DropdownMenuItem(
                        value: '203400519',
                        child: Text(
                          'Vip Capas Olist',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),

                    // Site
                    DropdownMenuItem(
                      value: '203410386',
                      child: Text(
                        'Vip Capas Site',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),

                    // Via varejo
                    DropdownMenuItem(
                        value: 'viavarejo-Vip Capas',
                        child: Text(
                          'Vip Via',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black),
                        )),
                  ],
                  dropdownColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<Order>>(
          future: fetchOrders(http.Client(), usr, _value.toString(), 'false'),
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
                return PhotosList(order: snapshot.data!, user: usr);
              } else {
                _qty = 0;
                return Center(child: CircularProgressIndicator());
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() {
    Completer<Null> completer = Completer<Null>();
    _qty = _qty;
    return completer.future;
  }
}

class PhotosList extends StatefulWidget {
  final List<Order> order;
  String user;

  PhotosList({super.key, required this.order, required this.user});

  @override
  _PhotosListState createState() => _PhotosListState(usr: user);
}

class _PhotosListState extends State<PhotosList> {
  _PhotosListState({required this.usr});

  String usr;
  late bool saved;

  Null get child => null;
  final String _url = "https://www.tiven.com.br/crud/images/";
  final String _sku = "";
  int captured = 0;
  late var data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.order.isEmpty ? 0 : widget.order.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Container(
              color: Colors.white10,
              alignment: Alignment.center,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Column(
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/images/logosys.png',
                            image: widget.order[index].thumbnailMarketUrl,
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      onTap: () {
                        _showDialog(context, index);
                      },
                      title: Container(
                        width: 20.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                    widget.order[index].nOrder
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
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
                                    '(${widget.order[index].total})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    //launch(data[index]["link"],
                                    //    forceWebView: false);
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Expedition(
                                          idUser: usr,
                                          nOrder: widget.order[index].nOrder
                                              .toString(),
                                          nStore: widget.order[index].nStore
                                              .toString(),
                                          store: widget.order[index].store
                                              .toString(),
                                          market: widget.order[index].market
                                              .toString(),
                                          idxOrder: index.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/scanorder.png',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: SizedBox(
                        width: 20.0,
                        height: 35.0,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(
                            '[${widget.order[index].items}] : ${strToLines(widget.order[index].products.toString())}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: SizedBox(
                            height: 40,
                            width: 50,
                            child: Expanded(
                              flex: 1,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/logosys.png',
                                image: widget.order[index].thumbnailStoreUrl,
                                height: 40,
                                width: 40,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: SizedBox(
                            height: 40,
                            width: 100,
                            child: Expanded(
                              flex: 2,
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
                                child: Text(DateFormat.yMd().format(
                                    DateTime.parse(widget.order[index].ordDate
                                        .toString()))),
                                // shape: new RoundedRectangleBorder(
                                //     borderRadius:
                                //         new BorderRadius.circular(7.0),
                                //     side: BorderSide(
                                //         color: Colors.grey.shade50)),
                                // textColor: Colors.black,
                                onPressed: () => (widget.order[index].items),
                                //launch(data[index]["link"],
                                //    forceWebView: false);
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: SizedBox(
                            height: 25,
                            child: Expanded(
                              flex: 6,
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
                                  widget.order[index].nClient.substring(
                                    0,
                                    widget.order[index].nClient.length <= 20
                                        ? widget.order[index].nClient.length
                                        : 20,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                // shape: new RoundedRectangleBorder(
                                //   borderRadius:
                                //       new BorderRadius.circular(3.0),
                                //   side:
                                //       BorderSide(color: Colors.grey.shade50),
                                // ),

                                onPressed: () {
                                  // scanBarcodeNormal(index);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
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

  String strToLines(products) {
    String newString = '';
    LineSplitter ls = LineSplitter();
    List<String> lines = ls.convert(products);

    print("---Result---");
    for (var i = 0; i < lines.length; i++) {
      newString = '$newString${lines[i]}\r\n';
    }
    return newString;
  }

  void _showDialog(context, idx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          titleTextStyle: TextStyle(color: Colors.white),
          content: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/load.gif',
                  image: '$_url${widget.order[idx].store}.jpg',
                ),

                // Image.network(
                //   _url + widget.orders[idx].sku + '.jpg',
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
                child: Text(widget.order[idx].store.toString(),
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

  void snacksaved() {
    SnackBar(
      backgroundColor: saved
          ? Colors.blueAccent[300]
          : Colors.redAccent.withValues(alpha: 0.9),
      content: saved
          ? Text("Ocorrência com $_sku registrada com sucesso!")
          : Text("Ocorrência com $_sku não registrada!"),
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
    return double.tryParse(s) != null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('data', data));
  }
}
