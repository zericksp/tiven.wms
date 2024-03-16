// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => new _RegisterState();
}

class _RegisterState extends State<Register> {
  // final ThemeData _CeTheme = _buildTheme();


  void onCreatedAccount() {
    var alert = new AlertDialog(
      title: new Text('Info'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('Voce criou nova conta.'),
          ],
        ),
      ),
      actions: <Widget>[
        new TextButton(
          child: new Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
        context: context, builder: (_) => new Text('Voce criou nova conta.'));
  }

  var _usernameController = new TextEditingController();
  var _firstnameController = new TextEditingController();
  var _lastnameController = new TextEditingController();
  var _genderController = new TextEditingController();
  var _passwordController = new TextEditingController();

  void _addData() {
    var url = "http://www.tiven.com.br/crud/NewUser.php";

    http.post(Uri.parse(url), body: {
      "username": _usernameController.text,
      "firstname": _firstnameController.text,
      "gender": _genderController.text,
      "lastname": _lastnameController.text,
      "password": _passwordController.text
    });
    onCreatedAccount();
    //print(_adresseController.text);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(),
      body: new Padding(
        padding: const EdgeInsets.only(
            left: 16.0, top: 30.0, right: 16.0, bottom: 16.0),
        child: ListView(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Usuário : ", hintText: " Nomde de usuário "),
                controller: _usernameController,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Nome : ", hintText: " Primeiro nome "),
                controller: _firstnameController,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Sexo : ", hintText: " Masc/Fem "),
                controller: _genderController,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.remove_red_eye),
              title: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Senha : ", hintText: "Senha para acesso "),
                controller: _passwordController,
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            new ButtonBarTheme(
              data: ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent),
              child: new ButtonBar(
                children: <Widget>[
                  new TextButton.icon(
                    label: Text(
                      'Voltar ',
                      textScaler: TextScaler.linear(2.0),
                    ),
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      //_UpdateData(widget.idUser, _nom.text, _pseudo.text, _prenom.text, _numTel.text);
                    },
                  ),
                  new TextButton.icon(
                    onPressed: () {
                      _addData();
                    },
                    icon: Icon(Icons.add),
                    label: Text(
                      "Registrar",
                      textScaler: TextScaler.linear(2.0),
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
