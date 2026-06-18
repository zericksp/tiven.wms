// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // final ThemeData _CeTheme = _buildTheme();


  void onCreatedAccount() {
    var alert = AlertDialog(
      title: Text('Info'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Voce criou nova conta.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
        context: context, builder: (_) => Text('Voce criou nova conta.'));
  }

  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, top: 30.0, right: 16.0, bottom: 16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Usuário : ", hintText: " Nomde de usuário "),
                controller: _usernameController,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Nome : ", hintText: " Primeiro nome "),
                controller: _firstnameController,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                decoration: InputDecoration(
                    labelText: "Sexo : ", hintText: " Masc/Fem "),
                controller: _genderController,
              ),
            ),
            ListTile(
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
            ButtonBarTheme(
              data: ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent),
              child: ButtonBar(
                children: <Widget>[
                  TextButton.icon(
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
                  TextButton.icon(
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
