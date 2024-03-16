import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

//import http package manually

class HeaderRows extends StatelessWidget {
  final String title;
  final String text;
  final Color color;
  final Color bordercolor;

  const HeaderRows(
      {Key? key,
      required this.title,
      required this.text,
      required this.color,
      required this.bordercolor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: bordercolor, width: 1),
              borderRadius: BorderRadius.circular(4)),
          width: MediaQuery.of(context).size.width - 10,
          margin: EdgeInsets.all(2.0),
          child: Row(
            children: <Widget>[
              AutoSizeText(
                (title +
                    ' : ' +
                    text
                        // .toString()
                        // .substring(
                        //   0,
                        //   text.length > 34 ? 34 : text.length,
                        // )
                        .toString()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DropDownStores extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DropDownStores();
  }
}

class _DropDownStores extends State<DropDownStores> {
  late String countryname, message;
  late bool error;
  var data;

  List<String> countries = ["Brasil", "México", "Argentina"];
  //we make list of strings with the name of countries

  String dataurl = "http://192.168.0.112/test/Market_list.php";
  // do not use http://localhost/ for your local machine, Android emulation do not recognize localhost
  // insted use your local ip address or your live URL,
  // hit "ipconfig" on Windows or "ip a" on Linux to get IP Address

  @override
  void initState() {
    error = false;
    message = "";
    countryname = "Brasil"; //default country
    super.initState();
  }

  Future<void> getMarket() async {
    var res = await http.post(
        Uri.parse(dataurl + "?country=" + Uri.encodeComponent(countryname)));
    //attache countryname on parameter country in url
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        if (data["error"]) {
          //check fi there is any error from server.
          error = true;
          message = data["errmsg"];
        }
      });
    } else {
      //there is error
      setState(() {
        error = true;
        message = "Error during fetching data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Market List"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          padding: EdgeInsets.all(30),
          child: Column(children: <Widget>[
            Container(
              //wrapper for Country list
              child: DropdownButton(
                isExpanded: true,
                value: countryname,
                hint: Text("Selecione O Market Place"),
                items: countries.map((countryone) {
                  return DropdownMenuItem(
                    child: Text(countryone), //label of item
                    value: countryone, //value of item
                  );
                }).toList(),
                onChanged: (value) {
                  countryname = value.toString(); //change the country name
                  getMarket(); //get Market list.
                },
              ),
            ),
            Container(
              //wrapper for Market list
              margin: EdgeInsets.only(top: 30),
              child: error
                  ? Text(message)
                  : data == null
                      ? Text("Escolha a Loja")
                      : MarketList(),
              //if there is error then show error message,
              //else check if data is null,
              //if not then show Market list,
            )
          ]),
        ));
  }

  Widget MarketList() {
    //widget function for Market list
    List<MarketOne> Marketlist = List<MarketOne>.from(data["data"].map((i) {
      return MarketOne.fromJSON(i);
    })); //searilize Marketlist json data to object model.

    return DropdownButton(
        hint: Text("Select Market"),
        isExpanded: true,
        items: Marketlist.map((MarketOne) {
          return DropdownMenuItem(
            child: Text(MarketOne.Marketname),
            value: MarketOne.Marketname,
          );
        }).toList(),
        onChanged: (value) {
          print("Selected Market is $value");
        });
  }
}

//model class to searilize country list JSON data.
class MarketOne {
  String id, countryname, Marketname;
  MarketOne(
      {required this.id, required this.countryname, required this.Marketname});

  factory MarketOne.fromJSON(Map<String, dynamic> json) {
    return MarketOne(
        id: json["Market_id"],
        countryname: json["country_name"],
        Marketname: json["Market_name"]);
  }
}

class pdfLabel {
  final pdf = pw.Document();
  var pw1 = pw.BarcodeWidget(
      data: "demo", barcode: pw.Barcode.qrCode(), width: 100, height: 50);
}

class ElevatedButtons extends StatelessWidget {
  final double height;
  final Widget obj;

  ElevatedButtons({
    Key? key,
    required this.height,
    required this.obj,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
        height: this.height,
        child:ElevatedButton(
                onPressed: () async {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                    side: const BorderSide(
                  width: 1.0,
                  color: Colors.grey,
                )),
                child: obj)
    );
  }
}
