import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/items.dart';

class Vtex extends StatefulWidget {
  final String idUser, title, username;

  Vtex(
      {Key? key,
      required this.title,
      required this.idUser,
      required this.username})
      : super(key: key);

  @override
  _VtexState createState() => _VtexState(title, idUser);
}

class _VtexState extends State<Vtex> {
  final String title, idUser;

  _VtexState(this.title, this.idUser);

  @override
  Widget build(BuildContext context) {
    final appTitle = 'Vtex';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: ThemeData.from(colorScheme: ColorScheme.light()),
      title: appTitle,
      home: VtexPage(title: appTitle, user: idUser),
    );
  }
}

class VtexPage extends StatefulWidget {
  late final String title, user;

  VtexPage({Key? key, title, user}) : super(key: key);

  @override
  _VtexPageState createState() => _VtexPageState(title: title, usr: user);
}

class _VtexPageState extends State<VtexPage> {
  String _value = '1';
  final String _status = 'NFe';
  String _courier = '1';
  final bool _checkbox = false;
  int _qty = 0;
  late String _usr;
  late final String title, usr;
  bool blFetch = false;

  _VtexPageState({required this.title, required this.usr});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 50,
        leading: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: <Widget>[
              Container(
                child: Text('Tiven'),
              ),
            ],
          ),
        ),
        leadingWidth: 60,
        title: Row(
          children: <Widget>[
            Container(
              width: 160,
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
                        blFetch = (_value.toString() != '1' && _courier != '1');
                        _usr = _usr;
                        _qty = _qty;
                      },
                    );
                  },
                  value: _value,
                  items: <DropdownMenuItem<String>>[
                    // Geral
                    DropdownMenuItem(
                      child: Text(
                        'Loja',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      value: '1',
                    ),

                    // ********  Eladecora  ********
                    // Site
                    DropdownMenuItem(
                      child: Text(
                        'Eladecora Site',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white70),
                      ),
                      value: '203522646',
                    ),

                    // Amazon
                    DropdownMenuItem(
                      child: Text(
                        'Eladecora Amazon',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white70),
                      ),
                      value: '203591279',
                    ),

                    // B2w
                    DropdownMenuItem(
                      child: Text(
                        'Eladecora B2W',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white70),
                      ),
                      value: '203392836',
                    ),

                    // Magalu
                    DropdownMenuItem(
                        child: Text(
                          'Eladecora Magalu',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white70),
                        ),
                        value: '203350868'),

                    // Mercadolivre
                    DropdownMenuItem(
                        child: Text(
                          'Eladecora MLB',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white70),
                        ),
                        value: '203423957'),
                  ],
                  dropdownColor: Colors.black12,
                ),
              ),
            ),
            Container(
              width: 158,
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
                        blFetch = (_value.toString() != '1' && _courier != '1');
                        _usr = _usr;
                        _qty = _qty;
                      },
                    );
                  },
                  value: _courier,
                  items: <DropdownMenuItem<String>>[
                    // Geral
                    DropdownMenuItem(
                      child: Text(
                        'Transportadora ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                        ),
                      ),
                      value: '1',
                    ),
                    // ********  Eladecora  ********
                    // Site
                    DropdownMenuItem(
                      child: Text(
                        'Retira Loja',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      value: 'Loja',
                    ),

                    // Loggi
                    DropdownMenuItem(
                      child: Text(
                        'Loggi',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 252, 255)),
                      ),
                      value: 'Loggi',
                    ),

                    //
                    DropdownMenuItem(
                      child: Text(
                        'Mandae',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      value: 'Mandae',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      value: 'Total',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Correios',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      value: 'Sedex',
                    ),
                  ],
                  dropdownColor: Color.fromARGB(255, 34, 31, 31),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: (_value == '1' && _courier == '1')
            ? Container()
            : (_value == '1' && _courier != '1')
                ? RefreshIndicator(
                    child: FutureBuilder<List<Photo>>(
                      future: fetchVwEdItems(usr, _checkbox,
                          _value.toString(), _courier.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.grey));
                        } else {
                          if (snapshot.hasData) {
                            _qty = snapshot.data!.length;
                            _onRefresh();
                            return PhotosList(
                                photos: snapshot.data!, user: usr);
                          } else {
                            _qty = 0;
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Colors.grey));
                          }
                        }
                      },
                    ),
                    onRefresh: _onRefresh,
                  )
                : RefreshIndicator(
                    child: FutureBuilder<List<Photo>>(
                      future: fetchEdItems(usr, _checkbox,
                          _value.toString(), _courier.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.grey));
                        } else {
                          if (snapshot.hasData) {
                            _qty = snapshot.data!.length;
                            _onRefresh();
                            return PhotosList(
                                photos: snapshot.data!, user: usr);
                          } else {
                            _qty = 0;
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Colors.grey));
                          }
                        }
                      },
                    ),
                    onRefresh: _onRefresh,
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

  late String _scanLocation;
  late String _location;
  String usr;
  late bool saved;

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
  late bool _notFound, _badLabel, _urgRepo;
  final bool _obs = false;
  var data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.photos.length <= 0 ? 0 : widget.photos.length,
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
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
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
                                      color: Color.fromARGB(255, 253, 253, 253),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: TextButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 0, 0),
                                    minimumSize: Size(30, 36),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    // shape: new RoundedRectangleBorder(
                                    //   borderRadius:
                                    //       new BorderRadius.circular(3.0)),
                                  ),
                                  onPressed: () {
                                    //launch(data[index]["link"],
                                    //    forceWebView: false);
                                  },
                                  child: Text(
                                    widget.photos[index].qty +
                                        " (" +
                                        widget.photos[index].captured +
                                        ')',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextButton(
                                onPressed: () {
                                  // scanBarcodeNormal(index);
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
                      subtitle: Row(
                        children: [
                          Container(
                            width: 40.0,
                            height: 55.0,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: AutoSizeText(
                                //capitalize(
                                widget.photos[index].courier
                                    .split(" ")
                                    .elementAt(0)
                                    .toLowerCase()
                                //)
                                ,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.orange,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(-1.0, 0.0),
                                      blurRadius: 2.0,
                                      color: Colors.black87,
                                    ),
                                    Shadow(
                                        offset: Offset(0.0, -0.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                    Shadow(
                                        offset: Offset(1.0, 0.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                    Shadow(
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                  ],
                                ),
                                maxLines: 1,
                              ),
                              // Text(
                              //   capitalize(
                              //       widget.photos[index].title.toLowerCase()),
                              //   style: TextStyle(
                              //     fontSize: 15,
                              //     color: Colors.grey,
                              //   ),
                              // ),
                            ),
                          ),
                          Container(
                            width: 220.0,
                            height: 55.0,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: AutoSizeText(
                                //capitalize(
                                widget.photos[index].title.toLowerCase()
                                //)
                                ,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(-1.0, 0.0),
                                      blurRadius: 2.0,
                                      color: Colors.black87,
                                    ),
                                    Shadow(
                                        offset: Offset(0.0, -0.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                    Shadow(
                                        offset: Offset(1.0, 0.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                    Shadow(
                                        offset: Offset(0.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Colors.black87),
                                  ],
                                ),
                                maxLines: 3,
                              ),
                              // Text(
                              //   capitalize(
                              //       widget.photos[index].title.toLowerCase()),
                              //   style: TextStyle(
                              //     fontSize: 15,
                              //     color: Colors.grey,
                              //   ),
                              // ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () {
                                  scanBarcodeNormal(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  alignment: AlignmentGeometry.lerp(
                                      Alignment.center, Alignment.center, 5),
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(100, 60),
                                  maximumSize: Size(100, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(6.0),
                                    side: BorderSide(
                                        color:
                                            Colors.grey.withValues(alpha: 0.5)),
                                  ),
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
                          flex: 4,
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
                                fontSize: 14,
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
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Color.fromARGB(255, 194, 157, 47)),
                                backgroundColor: WidgetStateProperty.all<Color>(
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
                                textAlign: TextAlign.center,
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
                                maxLines: 3,
                              ),
                              onPressed: () =>
                                  scanBarcodeLocation(widget.photos[index].sku),
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
    String barcodeScanRes = '';
    int intCaptured = 1;
    // Platform messages may fail, so we use a try/catch for all exceptions.
    try {
      // scan barrcode from external source
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.BARCODE);

      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
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
        print(barcodeScanRes);
        if (widget.photos[idx].captured == widget.photos[idx].qty) {
          setState(
            () {
              widget.photos.removeAt(idx);
            },
          );
        }
      }
    } catch (e) {
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
          : 'Todos ${widget.photos[idx].title} foram capturados'),
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
                                      "Sem Local", false);
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
                                    Text("Sem Local")
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
