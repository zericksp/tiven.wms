import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:animated_background/animated_background.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiven/pages/inventory.dart';
import 'package:tiven/pages/picking_nfe.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/pages/labels.dart';
import 'package:tiven/pages/orders.dart';
import 'package:tiven/pages/picking.dart';
import 'package:tiven/pages/repos.dart';
import 'package:tiven/pages/splash.dart';
import 'package:tiven/pages/updproduct.dart';
import 'package:tiven/pages/vipcapas.dart';
import 'package:tiven/pages/daily_prod.dart';
import 'package:tiven/pages/vtex.dart';
import 'package:tiven/widgets/lastProduced.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiven/utils/next_screen_dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tiven/pages/returns.dart';
import 'conference.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({
    super.key,
    required this.title,
    required this.data,
    // required this.idUser, required this.username,required this.firstname,
    // required this.lastname, required this.provider, required this.picture, required this.email,
  });
  final String title;
  List<String> data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Menu",
      theme: ThemeData(
          primarySwatch: Colors.grey, primaryColor: Colors.deepOrange),
      home: MenuPage(title: title, data: data),
    );
  }
}

// ignore: must_be_immutable
class MenuPage extends StatefulWidget {
  List<String> data = [];
  String title;

  MenuPage({
    super.key,
    required this.title,
    required this.data,
    // required this.idUser,
    // required this.username,
    // required this.firstname,
    // required this.lastname,
    // required this.provider,
    // required this.picture,
    // required this.email,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  _launchURL() async {
    const url = 'tel:32451300';
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Não foi possível efetuar a chamada';
    }
  }

  late var data;
  final int _qrcode = 0;
  late final int _scanQRcode = 0;
  late String qrcodeScanRes = "";
  String _barcode = "";
  double width = 0;
  double height = 0;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _initialize(); // Chama a função sem `await`
    incrementQrcode();
  }

  void _initialize() async {
    await initPlatformState(); // Agora pode usar `await`
    checkTrigger(); // Chama a verificação do scanner depois
  }

  /// Função para buscar no banco MySQL se o modelo tem scanner com gatilho
  Future<bool> fetchTriggerFromDatabase(String brand, String model) async {
    const String apiUrl = "https://tiven.com.br/picking/checkTriggerDevice.php";
    // const String apiUrl = "localhost/tiven.com.br/picking/checkTriggerDevice.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'brand': brand, 'model': model},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasTrigger'] ==
            true; // JSON esperado: {"hasTrigger": true/false}
      } else {
        if (kDebugMode) {
          print("Erro ao acessar o banco: ${response.statusCode}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro na requisição: $e");
      }
      return false;
    }
  }

  /// Obtém se o dispositivo tem scanner armazenado no SharedPreferences
  Future<bool> getHasTrigger() async {
    bool blStored = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Recupera o valor e verifica se é um booleano
    var storedValue = prefs.get('trigger');
    if (storedValue == true) {
      blStored = true; // Retorna o valor correto se for um bool
    } else if (storedValue == false) {
      blStored = false;
    }
    return blStored;
  }

  /// Define no SharedPreferences se o dispositivo tem scanner
  Future<void> setHasTrigger(bool blTrigger) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trigger', blTrigger);
    if (mounted) {
      setState(() {}); // Atualiza a UI se o widget ainda estiver ativo
    }
  }

  /// Verifica se o dispositivo tem scanner, buscando no SharedPreferences ou na API
  void checkTrigger() async {
    // setHasTrigger(false); // Reseta o valor para false
    bool blTrigger = false;
    // Verifica se a chave existe antes de acessar
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('trigger')) {
      blTrigger = await getHasTrigger();
    } else {
      // Consulta o banco de dados MySQL
      blTrigger = await fetchTriggerFromDatabase(
        _deviceData['brand'] ?? '',
        _deviceData['model'] ?? '',
      );
      await setHasTrigger(blTrigger);
    }
  }

  /// Obtém as informações do dispositivo
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
            _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            },
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'name': build.name,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'isiOSAppOnMac': data.isiOSAppOnMac,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  // }

  Future setScan() async {
    var response = await http.get(
        Uri.parse(
            "http://www.tiven.com.br/crud/prc_setScanByMachine.php?MACHINE=${_qrcode.toString()}&VALUE=${_barcode.toString()}"),
        headers: {"Accept": "application/json"});
    if (kDebugMode) {
      print(_scanQRcode);
    }
    if (response.contentLength! >= 100) {
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson['result'];
        _barcode = data[0]['scn_value'];
      });
    } else {
      setState(() {
        _barcode = _barcode;
      });
    }
  }

  //set local qrcode
  incrementQrcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setInt('qrcode', int.tryParse(qrcodeScanRes) ?? 0);
      },
    );
  }

  Future<Future<String?>> _showDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          contentPadding: EdgeInsets.only(top: 20.0),
          shadowColor: Colors.white,
          backgroundColor: Colors.black,
          title: Text(
            'Tiven ',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          content: SizedBox(
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    textAlign: TextAlign.center,
                    'Deseja realmente sair?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.cancel_presentation,
                  color: Colors.grey,
                  size: 25.0,
                ),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    alignment: AlignmentGeometry.lerp(
                        Alignment.center, Alignment.center, 5),
                    backgroundColor: Colors.black,
                    minimumSize: Size(100, 50),
                    maximumSize: Size(140, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey.withValues(alpha: 0.5),
                        width: 0.2,
                      ),
                    ),
                    shadowColor: Colors.grey,
                    elevation: 8),
                label: Text(
                  "Cancelar",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.grey,
                  size: 25.0,
                ),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    alignment: AlignmentGeometry.lerp(
                        Alignment.center, Alignment.center, 5),
                    backgroundColor: Colors.black,
                    minimumSize: Size(100, 50),
                    maximumSize: Size(140, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey.withValues(alpha: 0.5),
                        width: 0.2,
                      ),
                    ),
                    shadowColor: Colors.grey,
                    elevation: 8),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sair',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  nextScreenReplace(context, SplashScreen());
                  logout();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('logged', false);
    setState(
      () {
        prefs.setBool('logged', false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.9;
    height = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'tiven',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w100),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Image.asset(
                    'assets/images/logoVt.png',
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 65.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                "https://www.pedimus.com.br/home/img/rick.png"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Usuário : ${widget.data[0].toString()}"),
                            Text("Nome : ${widget.data[1]}"),
                            Text("Sobrenome : ${widget.data[2]}"),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              title: Text('Seu perfil'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Seu contrato'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Chamar Serviço ao Cliente'),
              onTap: () {
                _launchURL();
              },
            ),
            Divider(),
            ListTile(
              title: Text('Sobre nós'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Text('Sair'),
              onTap: () {
                _showDialog();
              },
            ),
          ],
        ),
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
              spawnMaxRadius: 11,
              spawnMinSpeed: 11.00,
              particleCount: 70,
              spawnMaxSpeed: 22,
              minOpacity: 0.2,
              opacityChangeRate: 0.25,
              spawnOpacity: 0.2,
              maxOpacity: 0.2,
              baseColor: Colors.grey,
              image: Image(
                image: AssetImage(
                  'assets/images/logo50p.png',
                ),
              )),
        ),
        vsync: this,
        child: Center(
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.ease,
            height: MediaQuery.of(context).size.height * 0.95,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1), // added
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.5),
                    width: 0.5), // added
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500.withValues(alpha: 0.1),
                    offset: Offset(4.0, 4.0),
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                ]),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _deviceData.keys.length >= 20
                        ? '${_deviceData['manufacturer']?.toUpperCase()} - ${_deviceData['model']?.toUpperCase()}'
                        : 'No Data to show',
                    style: TextStyle(
                      inherit: true,
                      height: 1,
                      fontSize: 12.0,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                            // bottomLeft
                            offset: Offset(-0.5, -0.5),
                            color: Colors.blueGrey[100]!),
                        Shadow(
                            // bottomRight
                            offset: Offset(0.5, -0.5),
                            color: Colors.blueGrey[100]!),
                        Shadow(
                            // topRight
                            offset: Offset(0.5, 0.5),
                            color: Colors.blueGrey[100]!),
                        Shadow(
                            // topLeft
                            offset: Offset(-0.5, 0.5),
                            color: Colors.blueGrey[100]!),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Conferir \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Recebimento",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Conference(
                                  idUser: widget.data[0],
                                  user: widget.data[1],
                                  photos: [],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.add_shopping_cart_sharp,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "  Colheita   \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Por Lote",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext? context) => Picking(
                                  title: widget.title,
                                  idUser: widget.data[0],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.autorenew,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Reposição    \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Separados",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Repositing(
                                  username: widget.data[1],
                                  title: '',
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Endereço    \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Localização",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => UpdateProd(
                                    // idUser: int.parse(this.widget.data[0]),
                                    // qrCode: _qrcode,
                                    ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Colheita     \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 2,
                                ),
                                Text(
                                  "Discreta NFe",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                // Picking_Nfe
                                builder: (BuildContext context) => Picking_Nfe(
                                  title: '',
                                  username: widget.data[1],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.add_shopping_cart_sharp,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Colheita\r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 2,
                                ),
                                Text(
                                  "Discreta Pedido",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext? context) => Picking(
                                  title: widget.title,
                                  idUser: widget.data[0],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.article_outlined,
                                color: Colors.grey,
                                size: 30.0,
                              ),
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  alignment: AlignmentGeometry.lerp(
                                      Alignment.center, Alignment.center, 5),
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(width * 0.45, height * 0.1),
                                  maximumSize: Size(width * 0.45, height * 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      width: 0.2,
                                    ),
                                  ),
                                  shadowColor: Colors.grey,
                                  elevation: 8),
                              label: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "Nota Fiscal\r",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "Emissão",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                var route = MaterialPageRoute(
                                  builder: (BuildContext context) => Orders(
                                    idUser: widget.data[0],
                                  ),
                                );
                                Navigator.of(context).push(route);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.all_inclusive_sharp,
                                color: Colors.grey,
                                size: 30.0,
                              ),
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  alignment: AlignmentGeometry.lerp(
                                      Alignment.center, Alignment.center, 5),
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(width * 0.45, height * 0.1),
                                  maximumSize: Size(width * 0.45, height * 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      width: 0.2,
                                    ),
                                  ),
                                  shadowColor: Colors.grey,
                                  elevation: 8),
                              label: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "Balanço\r",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "Geral",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                var route = MaterialPageRoute(
                                  builder: (BuildContext context) => Inventory(
                                    idUser: widget.data[0],
                                  ),
                                );
                                Navigator.of(context).push(route);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.insights_sharp,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Devolução\r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Fabricante",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Returns(
                                  idUser: widget.data[0],
                                  user: '',
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.help_center_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Ajuda\r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Manual e dicas",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade700,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                // Picking_Nfe
                                builder: (BuildContext context) =>
                                    LastProducedWidget(
                                  title: 'Manual',
                                  username: widget.data[1],
                                  idUser: widget.data[0],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 8),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Eladecora     \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Separação",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Vtex(
                                  username: widget.data[1],
                                  idUser: widget.data[0],
                                  title: '',
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.exit_to_app_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 10),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Vip Capas     \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Separação",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Vipcapas(
                                  idUser: widget.data[0],
                                  username: widget.data[1],
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.exit_to_app_outlined,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 10),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Etiquetas     \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Emissão",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => Labels(
                                  title: "Teste",
                                  key: null,
                                  text: '',
                                ),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.content_cut_outlined,
                              color: Colors.grey,
                              size: 25.0,
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center, Alignment.center, 5),
                                backgroundColor: Colors.black,
                                minimumSize: Size(width * 0.45, height * 0.1),
                                maximumSize: Size(width * 0.45, height * 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    width: 0.2,
                                  ),
                                ),
                                shadowColor: Colors.grey,
                                elevation: 10),
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "Produção     \r",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Do Dia",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                builder: (BuildContext context) => DailyProd(),
                              );
                              Navigator.of(context).push(route);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
