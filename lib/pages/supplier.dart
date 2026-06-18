import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Building {
  String id;
  String name;
  String place;

  Building({required this.id, required this.name, required this.place});
}

class Supplier extends StatefulWidget {
  Supplier({Key? key}) : super(key: key);

  @override
  _SupplierState createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  Widget appBarTitle = Text(
    "Fornecedores",
    style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = Icon(
    Icons.search,
    color: Colors.orange,
  );
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();

  late List<Building> _list;
  late List<Building> _Supplier;

  late bool _IsSearching;
  String _searchText = "";

  _SupplierState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
          _buildSupplier();
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
          _buildSupplier();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    init();
  }

  void init() {
    _list = [];

    _list.add(
      Building(
        id: "1",
        name: "LF",
        place: "Future",
      ),
    );
    _list.add(
      Building(
        id: "2",
        name: "MO",
        place: "Moas",
      ),
    );

    _list.add(
      Building(
        id: "3",
        name: "GG",
        place: "Geguton",
      ),
    );

    _list.add(
      Building(
        id: "4",
        name: "AR",
        place: "Arthi",
      ),
    );

    _list.add(
      Building(
        id: "5",
        name: "LY",
        place: "Lyor",
      ),
    );

    _list.add(
      Building(
        id: "6",
        name: "PM",
        place: "Paramount",
      ),
    );

    _list.add(
      Building(
        id: "7",
        name: "DC",
        place: "Di Carlo",
      ),
    );

    _list.add(
      Building(
        id: "8",
        name: "FM",
        place: "Forma",
      ),
    );

    _list.add(
      Building(
        id: "9",
        name: "Ou",
        place: "Ou",
      ),
    );

    _list.add(
      Building(
        id: "10",
        name: "Yo",
        place: "Yoi",
      ),
    );

    _list.add(
      Building(
        id: "1",
        name: "LF",
        place: "Future",
      ),
    );

    _list.add(
      Building(
        id: "3",
        name: "ED",
        place: "ElaDecora",
      ),
    );
    _list.add(
      Building(
        id: "4",
        name: "LF",
        place: "Future",
      ),
    );
    _list.add(
      Building(
        id: "5",
        name: "BR",
        place: "Brinox",
      ),
    );
    _list.add(
      Building(
        id: "6",
        name: "AR",
        place: "Arthi",
      ),
    );
    _list.add(
      Building(
        id: "7",
        name: "LC",
        place: "LeCreuset",
      ),
    );
    _list.add(
      Building(
        id: "8",
        name: "AC",
        place: "Dicarlo",
      ),
    );
    _list.add(
      Building(
        id: "9",
        name: "LY",
        place: "Lyor",
      ),
    );
    _list.add(
      Building(
        id: "10",
        name: "GG",
        place: "Geguton",
      ),
    );
    _list.add(
      Building(
        id: "11",
        name: "TR",
        place: "Tramontina",
      ),
    );
    _list.add(
      Building(
        id: "12",
        name: "RJ",
        place: "Rojemac",
      ),
    );
    _list.add(
      Building(
        id: "13",
        name: "PN",
        place: "Paramount",
      ),
    );
    _list.add(
      Building(
        id: "14",
        name: "MT",
        place: "Mart",
      ),
    );
    _list.add(
      Building(
        id: "15",
        name: "HA",
        place: "Hara'",
      ),
    );
    _list.add(
      Building(
        id: "16",
        name: "HA",
        place: "Hara2",
      ),
    );
    _list.add(
      Building(
        id: "17",
        name: "FU",
        place: "FullFit",
      ),
    );
    _list.add(
      Building(
        id: "18",
        name: "OU",
        place: "OU",
      ),
    );
    _list.add(
      Building(
        id: "19",
        name: "UR",
        place: "Urban",
      ),
    );
    _list.add(
      Building(
        id: "20",
        name: "AL",
        place: "Alleanza",
      ),
    );
    _list.add(
      Building(
        id: "21",
        name: "PB",
        place: "PortoBrasil",
      ),
    );
    _list.add(
      Building(
        id: "22",
        name: "WM",
        place: "WeMakeDesign",
      ),
    );
    _list.add(
      Building(
        id: "23",
        name: "MM",
        place: "Mimo",
      ),
    );
    _list.add(
      Building(
        id: "24",
        name: "BD",
        place: "BTCDecor",
      ),
    );
    _list.add(
      Building(
        id: "25",
        name: "EL",
        place: "Electrolux",
      ),
    );
    _list.add(
      Building(
        id: "26",
        name: "HK",
        place: "Hauskraft",
      ),
    );
    _list.add(
      Building(
        id: "27",
        name: "OX",
        place: "Oxford",
      ),
    );
    _list.add(
      Building(
        id: "28",
        name: "ZE",
        place: "Zein",
      ),
    );
    _list.add(
      Building(
        id: "29",
        name: "FM",
        place: "Forma",
      ),
    );
    _list.add(
      Building(
        id: "30",
        name: "SC",
        place: "Scalla",
      ),
    );
    _list.add(
      Building(
        id: "31",
        name: "UM",
        place: "Umbra",
      ),
    );
    _list.add(
      Building(
        id: "32",
        name: "DF",
        place: "DaniFernandes",
      ),
    );
    _list.add(
      Building(
        id: "33",
        name: "GW",
        place: "GreensWet",
      ),
    );
    _list.add(
      Building(
        id: "34",
        name: "YO",
        place: "YOI",
      ),
    );
    _list.add(
      Building(
        id: "35",
        name: "KA",
        place: "KItchenAid",
      ),
    );
    _list.add(
      Building(
        id: "36",
        name: "OK",
        place: "OIKOS",
      ),
    );
    _list.add(
      Building(
        id: "37",
        name: "KD",
        place: "Kouda",
      ),
    );
    _list.add(
      Building(
        id: "45",
        name: "HK",
        place: "HAUSKRAFT",
      ),
    );
    _list.add(
      Building(
        id: "38",
        name: "MK",
        place: "Mabruk",
      ),
    );
    _list.add(
      Building(
        id: "39",
        name: "NW",
        place: "NSW",
      ),
    );
    _list.add(
      Building(
        id: "40",
        name: "CC",
        place: "Copa&Cia",
      ),
    );
    _list.add(
      Building(
        id: "41",
        name: "GB",
        place: "GoodsBR",
      ),
    );
    _list.add(
      Building(
        id: "42",
        name: "SJ",
        place: "StJames",
      ),
    );
    _list.add(
      Building(
        id: "43",
        name: "ET",
        place: "Etilux",
      ),
    );
    _list.add(
      Building(
        id: "44",
        name: "JT",
        place: "Jolitex",
      ),
    );
    _list.add(
      Building(
        id: "45",
        name: "EC",
        place: "Entrecasa",
      ),
    );
    _list.add(
      Building(
        id: "46",
        name: "ED",
        place: "Érica",
      ),
    );
    _list.add(
      Building(
        id: "47",
        name: "CI",
        place: "CIM",
      ),
    );
    _list.add(
      Building(
        id: "48",
        name: "BF",
        place: "BelaFlor",
      ),
    );
    _list.add(
      Building(
        id: "49",
        name: "TC",
        place: "TokdaCasa",
      ),
    );
    _list.add(
      Building(
        id: "50",
        name: "UZ",
        place: "UZ",
      ),
    );
    _list.add(
      Building(
        id: "51",
        name: "GM",
        place: "Germer",
      ),
    );
    _list.add(
      Building(
        id: "52",
        name: "MS",
        place: "M.Shop",
      ),
    );
    _list.add(
      Building(
        id: "53",
        name: "DU",
        place: "DULER",
      ),
    );
    _list.add(
      Building(
        id: "54",
        name: "CF",
        place: "Ceraflame",
      ),
    );
    _list.add(
      Building(
        id: "55",
        name: "LV",
        place: "Lenvie",
      ),
    );
    _list.add(
      Building(
        id: "56",
        name: "FE",
        place: "Fernet",
      ),
    );
    _list.add(
      Building(
        id: "57",
        name: "DM",
        place: "DiMurano",
      ),
    );
    _list.add(
      Building(
        id: "58",
        name: "KT",
        place: "Karsten",
      ),
    );
    _list.add(
      Building(
        id: "59",
        name: "MH",
        place: "MaiHome",
      ),
    );
    _list.add(
      Building(
        id: "60",
        name: "JM",
        place: "Jomafe",
      ),
    );
    _list.add(
      Building(
        id: "61",
        name: "TS",
        place: "Trussardi",
      ),
    );
    _list.add(
      Building(
        id: "62",
        name: "PL",
        place: "Plasútil",
      ),
    );
    _list.add(
      Building(
        id: "63",
        name: "LM",
        place: "Limoeiro",
      ),
    );
    _list.add(
      Building(
        id: "64",
        name: "SP",
        place: "SilverPlastics",
      ),
    );
    _list.add(
      Building(
        id: "65",
        name: "RP",
        place: "Ribeiro&Pavani",
      ),
    );
    _list.add(
      Building(
        id: "66",
        name: "VF",
        place: "VillagioDasFlores",
      ),
    );
    _list.add(
      Building(
        id: "67",
        name: "BE",
        place: "Belchior",
      ),
    );

    _Supplier = _list;
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.black,
        key: key,
        appBar: buildBar(context) as AppBar,
        body: GridView.builder(
            itemCount: _Supplier.length,
            itemBuilder: (context, index) {
              return Uiitem(_Supplier[index]);
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            )

            /* GridView.count(
        crossAxisCount: 3,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        childAspectRatio: 8.0 / 9.0,
        children: _IsSearching ? _buildSupplier() : _buildList(),
      ),*/
            //drawer: Navigationdrawer(),
            ));
  }

  List<Building> _buildList() {
    return _list; //_list.map((contact) =>  Uiitem(contact)).toList();
  }

  List<Building> _buildSupplier() {
    if (_searchText.isEmpty) {
      return _Supplier =
          _list; //_list.map((contact) =>  Uiitem(contact)).toList();
    } else {
      /*for (int i = 0; i < _list.length; i++) {
        String name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _Supplier.add(name);
        }
      }*/

      _Supplier = _list
          .where((element) =>
              element.name.toLowerCase().contains(_searchText.toLowerCase()) ||
              element.place.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
      if (kDebugMode) {
        print('${_Supplier.length}');
      }
      return _Supplier; //_Supplier.map((contact) =>  Uiitem(contact)).toList();
    }
  }

  Widget buildBar(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: appBarTitle,
        iconTheme: IconThemeData(color: Colors.orange),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (actionIcon.icon == Icons.search) {
                  actionIcon = Icon(
                    Icons.close,
                    color: Colors.orange,
                  );
                  appBarTitle = TextField(
                    controller: _searchQuery,
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    decoration: InputDecoration(
                        hintText: "Buscar ...",
                        hintStyle: TextStyle(color: Colors.white)),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
        ]);
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      actionIcon = Icon(
        Icons.search,
        color: Colors.orange,
      );
      appBarTitle = Text(
        "Fornecedores",
        style: TextStyle(color: Colors.black),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

class Uiitem extends StatelessWidget {
  final Building building;

  Uiitem(this.building);

  final url = 'https://tiven.com.br/production/images/suppliers/';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.2),
      margin: EdgeInsets.fromLTRB(5, 3, 5, 3),
      elevation: 10.0,
      child: InkWell(
        splashColor: Colors.grey,
        onTap: () {
          print(building.place);
          Navigator.pop(context, building);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18.0 / 10.0,
              child: Image.network(
                '$url${building.id}.png',
                fit: BoxFit.scaleDown,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6.0, 8.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    building.name,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 0.0),
                  Text(
                    building.place,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
