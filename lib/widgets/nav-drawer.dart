import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'linkbar',
              style: TextStyle(color: Colors.grey, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/cover.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.barcode_reader,),
            title: Text('Leitor de Barras', style: TextStyle(color: Colors.grey),),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Separação', style: TextStyle(color: Colors.grey),),
            onTap: () => Navigator.pushNamed(context, '/Picking'),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Conferência Cega', style: TextStyle(color: Colors.grey),),
            onTap: () => Navigator.pushNamed(context, '/BlindConference'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações', style: TextStyle(color: Colors.grey),),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Consulta SKU/EAN', style: TextStyle(color: Colors.grey),),
            onTap: () => Navigator.pushNamed(context, '/Search'),
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('SKU/EAN - Voice', style: TextStyle(color: Colors.grey),),
            onTap: () => Navigator.pushNamed(context, '/SearchVoice'),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout', style: TextStyle(color: Colors.grey),),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
