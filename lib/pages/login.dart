import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tiven/pages/menu.dart';
import 'package:tiven/pages/new_account.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:tiven/utils/next_screen_dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _pseudoController = TextEditingController();
  final _passwordController = TextEditingController();
  late String title,
      int,
      username,
      firstname,
      lastname,
      provider,
      picture,
      email;

  var data;
  bool _enabledPwd = false;
  bool _enabledSend = false;

  var _isSecured = true;

  //**************** Get Login Connection && Data ************************/
  // ignore: missing_return

  //*********************Alert Dialog Empty Required Fields******************************/
  void onSignedInEmptyFields(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          titleTextStyle: TextStyle(fontSize: 15, color: Colors.white),
          backgroundColor: Colors.grey.shade900,
          elevation: 8,
          title: Stack(
            children: [
              Image.asset(
                'assets/images/bckgrnd.jpg',
                fit: BoxFit.contain,
              ),
              Container(
                color: Colors.black,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                Navigator.of(context).pop();
                              });
                            },
                            label: Text("Voltar"),
                            icon: Icon(Icons.exit_to_app),
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(Colors.grey),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //*********************Alert Dialog Pseudo******************************/
  void onSignedInErrorPassword() {
    AlertDialog(
      title: Text("Erro ao acessar"),
      content: Text(
          "Ocorreu um erro com a senha ao acessar. Favor tentar novamente."),
    );
    showDialog(
        context: context,
        builder: (_) => Text(
            "Ocorreu um erro com acesso do usuário. Favor tentar novamente."));
  }

  //********************Alert Dialog Pseudo******************************/
  void onSignedInErrorPseudo() {
    var alert = AlertDialog(
      title: Text("Erro ao acessar"),
      content: Text(
          "Ocorreu um erro com acesso do usuário. Favor tentar novamente."),
    );
    showDialog(
        context: context,
        builder: (_) => Text(
            "Ocorreu um erro com acesso do usuário. Favor tentar novamente."));
  }

  //******************* Check Data ****************************/
  Future<void> VerifData(String pseudo, String password, var data) async {
    var content = Utf8Encoder().convert(password);
    var md5 = crypto.md5;

    var digest = md5.convert(content);
    password = hex.encode(digest.bytes);
    if (data['username'] == pseudo || data['userEmail'] == pseudo) {
      List<String> logg = [
        data['user_id'].toString() ?? '0',
        data['username'] ?? '',
        data['first_name'] ?? '',
        data['last_name'] ?? '',
        data['userEmail'] ?? '',
        'database',
        data['picture'] ?? '',
      ];
      var route = MaterialPageRoute(
        builder: (BuildContext context) => MenuPage(
          title: '',
          data: logg,
        ),
        // firstname: data['first_name']!,
        // lastname: data['last_name']!,
        // username: data['username']!,
        // email: data['email']!,
        // provider: 'database',
        // picture: data['picture']!,
        // ),
      );

      saveSharedData();

      setState(() {
        // _pseudoController.text = '';
        // _passwordController.text = '';
      });
      Navigator.of(context).push(route);
    }
  }

  Future<void> saveSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('logged', true);
    prefs.setString('idUser', data['user_id'].toString());
    prefs.setString('firstname', data['first_name']);
    prefs.setString('lastname', data['last_name']);
    prefs.setString('userName', data['username']);
    prefs.setString('email', data['userEmail']);
    prefs.setString('provider', 'database');
    prefs.setString('picture', data['picture'] ?? '');

    setState(
      () {
        prefs.setBool('logged', true);
      },
    );
  }

  void handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreenReplace(
        context,
        MenuScreen(
          title: '',
          data: data,
          // idUser: int.parse(data['user_id']),
          // username: data['username'] ?? '',
          // firstname: data['first_name'] ?? '',
          // lastname: data['last_name'] ?? '',
          // provider: 'database',
          // picture: data['picture'] ?? '',
          // email: data['userEmail'] ?? ''
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Material(
            color: Colors.black,
            elevation: 2,
            shadowColor: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: advert(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: logo(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: pseudo(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: password(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    cancelButton(),
                    SizedBox(width: 10),
                    loginButton(),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                createaccount(context),
              ],
            ),
          ),
        ),
      ),
    );
    /******************* advertisiment ************************/
    /******************* LOGO ************************/
  }

  Row advert() {
    return Row(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                'assets/images/logo.png',
              ),
              alignment: Alignment.topLeft,
            ),
          ),
        ),
        Text(
          "tiven",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Center logo() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height
                ? MediaQuery.of(context).size.height / 5
                : MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height
                ? MediaQuery.of(context).size.height / 5
                : MediaQuery.of(context).size.width / 5,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                style: BorderStyle.solid,
                strokeAlign: BorderSide.strokeAlignInside,
                color: Color.fromARGB(255, 255, 100, 0).withValues(alpha: 0.9),
                width: 1,
              ),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(6.0),
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage('assets/images/log.gif')),
            ),
          ),
        ],
      ),
    );
  }
  /*******************************************************/

  /// **************** TextField Pseudo******************************
  Container pseudo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(6.0),
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 36, 37, 41),
          Color.fromARGB(255, 15, 3, 3),
        ]),
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress, // 👈 teclado de e-mail
        autofillHints: const [AutofillHints.email],
        enableSuggestions: true,
        autocorrect: false,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          floatingLabelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          labelText: "usuário",
          labelStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.5),
            fontSize: 18,
          ),
          filled: true,
          fillColor: Colors.black,
          hintText: "Nome de usuário",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 124, 120, 120), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.5), width: 1.0),
          ),
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
            decorationStyle: TextDecorationStyle.wavy,
            color:
                const Color.fromARGB(255, 158, 158, 158).withValues(alpha: 0.5),
            fontSize: 14,
          ),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.account_box_outlined,
              color: Colors.white38,
            ),
          ),
        ),
        controller: _pseudoController,
        onChanged: (value) {
          setState(() {
            _enabledPwd = (value.toString().length > 4);
          });
        },
      ),
    );
  }

  /************************************************************/

  /// ****************** TextField Password *****************************
  Container password() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.black.withValues(alpha: 0.3),
      child: TextFormField(
        enabled: _enabledPwd,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          floatingLabelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          labelText: "Senha",
          labelStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.black,
          hintText: "Senha de acesso",
          hintStyle: TextStyle(
            decorationStyle: TextDecorationStyle.wavy,
            color: Colors.grey.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          // helperText: 'Senha de acesso',
          // helperStyle:
          //     TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 11),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 124, 120, 120), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.5), width: 1.0),
          ),
          suffixIcon: GestureDetector(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isSecured = !_isSecured;
                });
              },
              icon: Icon(
                Icons.lock_outline,
                color: Colors.grey.shade700,
              ),
            ),
            onLongPressStart: (_) async {
              setState(() {
                _isSecured = false;
              });
            },
            onLongPressCancel: () {
              //cancelPress();
            },
            onLongPressEnd: (_) {
              setState(() {
                _isSecured = true;
              });
            },
          ),
        ),
        obscureText: _isSecured,
        controller: _passwordController,
        onChanged: (value) => _enabledSend = value.toString().length > 4,
      ),
    );
  }

  /****************************************************/
  /// ******************* Button Login***************************************
  Column createaccount(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            var route = MaterialPageRoute(
              builder: (BuildContext context) => Register(),
            );
            Navigator.of(context).push(route);
          },
          icon: Icon(
            Icons.lock,
            color: Colors.grey,
            size: 24,
          ),
          tooltip: 'Recuperar Senha',
          highlightColor: Colors.blue[900],
          hoverColor: Colors.green,
          focusColor: Colors.blue,
          splashColor: Colors.yellow,
          disabledColor: Colors.amber,
          iconSize: 48,
        ),
        Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

/*************************************************/

/// ******************Button Cancel **********************
  ElevatedButton cancelButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.5),
          alignment:
              AlignmentGeometry.lerp(Alignment.center, Alignment.center, 2),
          backgroundColor: Colors.black,
          minimumSize: Size(120, 40),
          maximumSize: Size(120, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          shadowColor: Colors.grey,
          elevation: 8),
      child: AutoSizeText(
        'Cancelar',
        style: TextStyle(fontSize: 20),
        maxLines: 1,
      ),
      //Text('Cancelar'),
      onPressed: () async {
        _passwordController.clear();
        _pseudoController.clear();
        // Perform some action
        SnackBar(
          content: Text("Login Cancelado"),
          backgroundColor: Colors.deepOrange,
        );
      },
    );
  }

  /// ******************* Button Login***************************************
  ElevatedButton loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.5),
          alignment:
              AlignmentGeometry.lerp(Alignment.center, Alignment.center, 5),
          backgroundColor: Colors.black,
          minimumSize: Size(120, 40),
          maximumSize: Size(120, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          shadowColor: Colors.grey,
          elevation: 8),
      child: AutoSizeText(
        'Entrar',
        style: TextStyle(fontSize: 20),
        maxLines: 1,
      ),
      onPressed: () async {
        if (_enabledSend == false) {
          return; // Melhor que 'null'
        }

        if (_pseudoController.text.isEmpty &&
            _passwordController.text.isEmpty) {
          onSignedInEmptyFields("Os campos usuário e senha são necessários");
          return;
        }

        if (_pseudoController.text.isEmpty) {
          onSignedInEmptyFields("O campo usuário é necessário");
          return;
        }

        if (_passwordController.text.isEmpty) {
          onSignedInEmptyFields("O campo senha é necessário");
          return;
        }
        // Fazer login
        var response =
            await login(_pseudoController.text, _passwordController.text);

        if (response["code"] == 1) {
          var user = response["user"];
          String userId = user["user_id"].toString() ?? '';
          String username = user["username"] ?? '';

          setState(() {
            data = response['user'];
          });

          // AQUI: data agora está disponível para usar
          await VerifData(
              _pseudoController.text, _passwordController.text, data);

          // Mostrar SnackBar de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login realizado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Mostrar erro
          if (kDebugMode) {
            print("Erro: ${response["message"]}");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro: ${response["message"]}"),
              backgroundColor: Colors.red,
            ),
          );
          onSignedInErrorPassword();
        }
      },
    );
  }

  Future<Map<String, dynamic>> login(String pseudo, String password) async {
    final response = await http.post(
      Uri.parse("https://www.tiven.com.br/crud/Login.php"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "user": pseudo,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"code": "0", "message": "Erro na comunicação com o servidor"};
    }
  }
}
