import 'package:http/http.dart' as http;

class Config {
  static const appIcon = "assets/logo.png";
  static const appErr = 'assets/img_mic.png';
  static const appWarn = 'assets/instr_mic.png';
}

class SetScan{

  static Future setScan(qrcode,  barcode) async {
    var response = await http.get(
        Uri.parse(
        "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${qrcode.toString()}&VALUE=${barcode.toString()}"),
      headers: {"Accept": "application/json"});
    print(qrcode);
    return response.body;
  }

  static Future setScanReturn(qrcode, key) async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${qrcode.toString()}&VALUE=$key"),
        headers: {"Accept": "application/json"});
    print(qrcode);
    return response.body;
  }
} 