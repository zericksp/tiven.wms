import 'dart:convert';
import 'package:http/http.dart' as http;

class Config {
  static const appIcon = "assets/logo.png";
  static const appErr = 'assets/img_mic.png';
  static const appWarn = 'assets/instr_mic.png';
}

class SetScan{

  static Future setScan(_qrcode,  _barcode) async {
    var response = await http.get(
        Uri.parse(
        "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=${_barcode.toString()}"),
      headers: {"Accept": "application/json"});
    print(_qrcode);
    return response.body;
  }

  static Future setScanReturn(_qrcode, _key) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=${_key}"),
        headers: {"Accept": "application/json"});
    print(_qrcode);
    return response.body;
  }
} 