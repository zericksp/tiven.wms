import 'dart:convert';
import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tiven/pages/conference.dart';
import 'package:tiven/pages/daily_prod.dart';
import 'package:tiven/pages/inventory.dart';
import 'package:tiven/pages/labels.dart';
import 'package:tiven/pages/orders.dart';
import 'package:tiven/pages/picking.dart';
import 'package:tiven/pages/picking_nfe.dart';
import 'package:tiven/pages/repos.dart';
import 'package:tiven/pages/returns.dart';
import 'package:tiven/pages/splash.dart';
import 'package:tiven/pages/updproduct.dart';
import 'package:tiven/pages/vipcapas.dart';
import 'package:tiven/pages/vtex.dart';
import 'package:tiven/utils/next_screen_dart';
import 'package:tiven/widgets/lastProduced.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Categorias de cor
// ─────────────────────────────────────────────────────────────────────────────
enum MenuCategory {
  receiving,
  picking,
  fiscal,
  returns,
  company,
  production,
  support,
}

extension MenuCategoryStyle on MenuCategory {
  Color get accent {
    switch (this) {
      case MenuCategory.receiving:
        return const Color(0xFF4A9EFF);
      case MenuCategory.picking:
        return const Color(0xFF4ECB71);
      case MenuCategory.fiscal:
        return const Color(0xFFFFBB33);
      case MenuCategory.returns:
        return const Color(0xFFFF5252);
      case MenuCategory.company:
        return const Color(0xFFAB7EFF);
      case MenuCategory.production:
        return const Color(0xFF26C6DA);
      case MenuCategory.support:
        return const Color(0xFF78909C);
    }
  }

  Color get bg => accent.withValues(alpha: 0.08);
  Color get glow => accent.withValues(alpha: 0.25);
  String get displayLabel {
    switch (this) {
      case MenuCategory.receiving:
        return 'Recebimento';
      case MenuCategory.picking:
        return 'Colheita';
      case MenuCategory.fiscal:
        return 'Fiscal';
      case MenuCategory.returns:
        return 'Devolução';
      case MenuCategory.company:
        return 'Empresas';
      case MenuCategory.production:
        return 'Produção';
      case MenuCategory.support:
        return 'Suporte';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modelo
// ─────────────────────────────────────────────────────────────────────────────
class MenuItemConfig {
  final String id;
  final IconData icon;
  final String label;
  final String sublabel;
  final MenuCategory category;
  final Widget Function(BuildContext) pageBuilder;

  const MenuItemConfig({
    required this.id,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.category,
    required this.pageBuilder,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.title, required this.data});
  final String title;
  final List<String> data;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Menu',
        theme: ThemeData(
            primarySwatch: Colors.grey, primaryColor: Colors.deepOrange),
        home: MenuPage(title: title, data: data),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// MenuPage
// ─────────────────────────────────────────────────────────────────────────────
class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title, required this.data});
  final String title;
  final List<String> data;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = {};

  // Lista de 14 itens (índices 0–13)
  late List<MenuItemConfig> _items;
  bool _editMode = false;

  // ScrollController compartilhado entre ReorderableBuilder e GridView
  final _scrollController = ScrollController();
  final _gridKey = GlobalKey();

  static const _prefsKey = 'menu_order_v4';

  // ── Catálogo padrão — 14 itens, índices 0 a 13 ───────────────────────────
  List<MenuItemConfig> get _catalog => [
        MenuItemConfig(
          // 0
          id: 'conferir',
          icon: Icons.assignment_turned_in_outlined,
          label: 'Conferir', sublabel: 'Recebimento',
          category: MenuCategory.receiving,
          pageBuilder: (_) => Conference(
              idUser: widget.data[0], user: widget.data[1], photos: []),
        ),
        MenuItemConfig(
          // 1
          id: 'colheita_lote',
          icon: Icons.add_shopping_cart_sharp,
          label: 'Colheita', sublabel: 'Por Lote',
          category: MenuCategory.picking,
          pageBuilder: (_) =>
              Picking(title: widget.title, idUser: widget.data[0]),
        ),
        MenuItemConfig(
          // 2
          id: 'reposicao',
          icon: Icons.autorenew,
          label: 'Reposição', sublabel: 'Separados',
          category: MenuCategory.picking,
          pageBuilder: (_) => Repositing(
              idUser: widget.data[0],
              username: widget.data[1],
              title: 'Reposição'),
        ),
        MenuItemConfig(
          // 3
          id: 'endereco',
          icon: Icons.location_on_outlined,
          label: 'Endereço', sublabel: 'Localização',
          category: MenuCategory.receiving,
          pageBuilder: (_) => UpdateProd(),
        ),
        MenuItemConfig(
          // 4
          id: 'colheita_nfe',
          icon: Icons.shopping_cart_checkout,
          label: 'Colheita', sublabel: 'Discreta NFe',
          category: MenuCategory.picking,
          pageBuilder: (_) => Picking_Nfe(title: '', username: widget.data[1]),
        ),
        MenuItemConfig(
          // 5
          id: 'colheita_pedido',
          icon: Icons.shopping_cart_outlined,
          label: 'Colheita', sublabel: 'Discreta Pedido',
          category: MenuCategory.picking,
          pageBuilder: (_) =>
              Picking(title: widget.title, idUser: widget.data[0]),
        ),
        MenuItemConfig(
          // 6
          id: 'nota_fiscal',
          icon: Icons.article_outlined,
          label: 'Nota Fiscal', sublabel: 'Emissão',
          category: MenuCategory.fiscal,
          pageBuilder: (_) => Orders(idUser: widget.data[0]),
        ),
        MenuItemConfig(
          // 7
          id: 'balanco',
          icon: Icons.all_inclusive_sharp,
          label: 'Balanço', sublabel: 'Geral',
          category: MenuCategory.fiscal,
          pageBuilder: (_) => Inventory(idUser: widget.data[0]),
        ),
        MenuItemConfig(
          // 8
          id: 'devolucao',
          icon: Icons.undo_rounded,
          label: 'Devolução', sublabel: 'Fabricante',
          category: MenuCategory.returns,
          pageBuilder: (_) => Returns(idUser: widget.data[0], user: ''),
        ),
        MenuItemConfig(
          // 9
          id: 'ajuda',
          icon: Icons.help_center_outlined,
          label: 'Ajuda', sublabel: 'Manual e dicas',
          category: MenuCategory.support,
          pageBuilder: (_) => LastProducedWidget(
              title: 'Manual',
              username: widget.data[1],
              idUser: widget.data[0]),
        ),
        MenuItemConfig(
          // 10
          id: 'eladecora',
          icon: Icons.store_outlined,
          label: 'Eladecora', sublabel: 'Separação',
          category: MenuCategory.company,
          pageBuilder: (_) =>
              Vtex(username: widget.data[1], idUser: widget.data[0], title: ''),
        ),
        MenuItemConfig(
          // 11
          id: 'vipcapas',
          icon: Icons.cases_outlined,
          label: 'Vip Capas', sublabel: 'Separação',
          category: MenuCategory.company,
          pageBuilder: (_) =>
              Vipcapas(idUser: widget.data[0], username: widget.data[1]),
        ),
        MenuItemConfig(
          // 12
          id: 'etiquetas',
          icon: Icons.label_outline,
          label: 'Etiquetas', sublabel: 'Emissão',
          category: MenuCategory.fiscal,
          pageBuilder: (_) => Labels(title: 'Etiquetas', key: null, text: ''),
        ),
        MenuItemConfig(
          // 13
          id: 'producao',
          icon: Icons.content_cut_outlined,
          label: 'Produção', sublabel: 'Do Dia',
          category: MenuCategory.production,
          pageBuilder: (_) => DailyProd(),
        ),
      ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _items = List.from(_catalog);
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await Future.wait([_initPlatformState(), _loadOrder()]);
    _checkTrigger();
    _incrementQrcode();
  }

  // ── Persistência ──────────────────────────────────────────────────────────
  Future<void> _loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final savedIds = List<String>.from(json.decode(raw));
      final byId = {for (final i in _catalog) i.id: i};
      final reordered =
          savedIds.where(byId.containsKey).map((id) => byId[id]!).toList();
      final savedSet = savedIds.toSet();
      for (final item in _catalog) {
        if (!savedSet.contains(item.id)) reordered.add(item);
      }
      if (mounted) setState(() => _items = reordered);
    } catch (_) {}
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, json.encode(_items.map((e) => e.id).toList()));
  }

  // ── Device info / trigger / qrcode ───────────────────────────────────────
  void _checkTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasTrigger;
    if (prefs.containsKey('trigger')) {
      hasTrigger = prefs.getBool('trigger') ?? false;
    } else {
      hasTrigger = await _fetchTrigger(
          _deviceData['brand'] ?? '', _deviceData['model'] ?? '');
      await prefs.setBool('trigger', hasTrigger);
    }
    if (mounted) setState(() {});
  }

  Future<bool> _fetchTrigger(String brand, String model) async {
    try {
      final r = await http.post(
        Uri.parse('https://tiven.com.br/picking/checkTriggerDevice.php'),
        body: {'brand': brand, 'model': model},
      );
      if (r.statusCode == 200) return json.decode(r.body)['hasTrigger'] == true;
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return false;
  }

  Future<void> _incrementQrcode() async =>
      (await SharedPreferences.getInstance()).setInt('qrcode', 0);

  Future<void> _initPlatformState() async {
    Map<String, dynamic> d = {};
    try {
      if (kIsWeb) {
        d = _webInfo(await _deviceInfoPlugin.webBrowserInfo);
      } else {
        d = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _androidInfo(await _deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS => _iosInfo(await _deviceInfoPlugin.iosInfo),
          TargetPlatform.linux => _linuxInfo(await _deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            _windowsInfo(await _deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS => _macInfo(await _deviceInfoPlugin.macOsInfo),
          _ => {'Error': 'Platform not supported'},
        };
      }
    } on PlatformException {
      d = {'Error': 'Failed'};
    }
    if (!mounted) return;
    setState(() => _deviceData = d);
  }

  Map<String, dynamic> _androidInfo(AndroidDeviceInfo b) => {
        'brand': b.brand,
        'model': b.model,
        'manufacturer': b.manufacturer,
        'version.sdkInt': b.version.sdkInt,
        'version.release': b.version.release,
        'device': b.device,
        'isPhysicalDevice': b.isPhysicalDevice,
        'board': b.board,
        'bootloader': b.bootloader,
        'display': b.display,
        'fingerprint': b.fingerprint,
        'hardware': b.hardware,
        'host': b.host,
        'id': b.id,
        'product': b.product,
        'name': b.name,
        'supported32BitAbis': b.supported32BitAbis,
        'supported64BitAbis': b.supported64BitAbis,
        'supportedAbis': b.supportedAbis,
        'tags': b.tags,
        'type': b.type,
        'systemFeatures': b.systemFeatures,
        'isLowRamDevice': b.isLowRamDevice,
      };
  Map<String, dynamic> _iosInfo(IosDeviceInfo d) => {
        'name': d.name,
        'systemName': d.systemName,
        'systemVersion': d.systemVersion,
        'model': d.model,
        'modelName': d.modelName,
        'isPhysicalDevice': d.isPhysicalDevice,
      };
  Map<String, dynamic> _linuxInfo(LinuxDeviceInfo d) =>
      {'name': d.name, 'version': d.version, 'prettyName': d.prettyName};
  Map<String, dynamic> _webInfo(WebBrowserInfo d) =>
      {'browserName': d.browserName.name, 'userAgent': d.userAgent};
  Map<String, dynamic> _macInfo(MacOsDeviceInfo d) => {
        'computerName': d.computerName,
        'model': d.model,
        'modelName': d.modelName,
      };
  Map<String, dynamic> _windowsInfo(WindowsDeviceInfo d) => {
        'computerName': d.computerName,
        'productName': d.productName,
        'buildNumber': d.buildNumber,
        'numberOfCores': d.numberOfCores,
        'systemMemoryInMegabytes': d.systemMemoryInMegabytes,
        'userName': d.userName,
        'majorVersion': d.majorVersion,
        'minorVersion': d.minorVersion,
        'platformId': d.platformId,
        'csdVersion': d.csdVersion,
        'servicePackMajor': d.servicePackMajor,
        'servicePackMinor': d.servicePackMinor,
        'suitMask': d.suitMask,
        'productType': d.productType,
        'reserved': d.reserved,
        'buildLab': d.buildLab,
        'buildLabEx': d.buildLabEx,
        'digitalProductId': d.digitalProductId,
        'displayVersion': d.displayVersion,
        'editionId': d.editionId,
        'installDate': d.installDate,
        'productId': d.productId,
        'registeredOwner': d.registeredOwner,
        'releaseId': d.releaseId,
        'deviceId': d.deviceId,
      };

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', false);
    if (mounted) setState(() {});
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:32451300');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _showExitDialog() async => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.only(top: 20),
            backgroundColor: Colors.grey.shade900.withValues(alpha: 0.95),
            title: const Text('Tiven',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            content: const SizedBox(
              height: 70,
              child: Center(
                child: Text('Deseja realmente sair?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ),
            actions: [
              _dialogBtn(Icons.cancel_presentation, 'Cancelar',
                  () => Navigator.of(ctx).pop()),
              _dialogBtn(Icons.exit_to_app_rounded, 'Sair', () {
                nextScreenReplace(context, SplashScreen());
                _logout();
              }),
            ],
          ),
        ),
      );

  Widget _dialogBtn(IconData icon, String label, VoidCallback onPressed) =>
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(icon, color: Colors.grey, size: 22),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
            ),
          ),
          label: Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          onPressed: onPressed,
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final deviceLabel = _deviceData.keys.length >= 20
        ? '${_deviceData['manufacturer']?.toString().toUpperCase()} — '
            '${_deviceData['model']?.toString().toUpperCase()}'
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 11,
            spawnMinSpeed: 11.0,
            particleCount: 70,
            spawnMaxSpeed: 22,
            minOpacity: 0.2,
            opacityChangeRate: 0.25,
            spawnOpacity: 0.2,
            maxOpacity: 0.2,
            baseColor: Colors.grey.shade400,
            image: const Image(image: AssetImage('assets/images/logo50p.png')),
          ),
        ),
        vsync: this,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    children: [
                      _buildHeader(deviceLabel),
                      const SizedBox(height: 4),
                      if (_editMode) _buildLegend(),
                      Expanded(child: _buildGrid()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(String? deviceLabel) => Row(
        children: [
          if (deviceLabel != null)
            Expanded(
              child: Text(
                deviceLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey.shade200,
                  letterSpacing: 0.5,
                  shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
            )
          else
            const Spacer(),
          GestureDetector(
            onTap: () async {
              if (_editMode) await _saveOrder();
              setState(() => _editMode = !_editMode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _editMode
                    ? Colors.deepOrange.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _editMode
                      ? Colors.deepOrange.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _editMode ? Icons.check_rounded : Icons.dashboard_customize,
                    size: 13,
                    color: _editMode ? Colors.deepOrange : Colors.white60,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _editMode ? 'Salvar ordem' : 'Reorganizar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _editMode ? Colors.deepOrange : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  // ── Legenda de categorias ─────────────────────────────────────────────────
  Widget _buildLegend() => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MenuCategory.values
                .map((cat) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cat.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cat.accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: cat.accent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cat.displayLabel,
                            style: TextStyle(
                                fontSize: 12,
                                color: cat.accent,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      );

  // ── Grid reordenável ──────────────────────────────────────────────────────
  //
  // ReorderableBuilder gerencia todo o drag-and-drop internamente.
  // Cada filho PRECISA de Key única — usamos Key(item.id).
  // onReorder recebe uma função que aplica direto na lista _items.
  // enableDraggable é falso no modo normal (evita long-press acidental).
  //
  Widget _buildGrid() {
    // Gera os widgets filhos — Key obrigatória em cada um
    final children = _items
        .map((item) => _MenuButton(
              key: Key(item.id), // ← Key estável pelo ID
              config: item,
              editMode: _editMode,
              onTap: _editMode
                  ? null
                  : () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: item.pageBuilder)),
            ))
        .toList();

    return ReorderableBuilder(
      // key: ValueKey(_editMode), // reseta o estado interno ao trocar de modo
      scrollController: _scrollController,
      enableDraggable: _editMode, // drag só no modo edição
      enableLongPress: true, // segura para iniciar o drag
      longPressDelay: const Duration(milliseconds: 300),
      onReorder: (ReorderedListFunction reorder) {
        // reorder() aplica a reordenação na lista e retorna a nova lista
        setState(() {
          _items = reorder(_items) as List<MenuItemConfig>;
        });
      },
      // BoxDecoration do card enquanto está sendo arrastado
      dragChildBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      builder: (children) => GridView(
        key: _gridKey,
        controller: _scrollController,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 colunas
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          childAspectRatio: 2.6, // mesma proporção das versões anteriores
        ),
        children: children,
      ),
      children: children,
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(children: [
            const Text('tiven',
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontWeight: FontWeight.w100)),
            const SizedBox(width: 22),
            Image.asset('assets/images/logoVt.png', width: 18, height: 18),
          ]),
        ),
      );

  // ── Drawer ────────────────────────────────────────────────────────────────
  Widget _buildDrawer() => Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://www.pedimus.com.br/home/img/rick.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Usuário : ${widget.data[0]}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('Nome : ${widget.data[1]}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('Sobrenome : ${widget.data[2]}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),
          _tile('Seu perfil', Icons.person_outline, () {}),
          _tile('Seu contrato', Icons.description_outlined, () {}),
          _tile('Ligar para suporte', Icons.phone_outlined, _launchPhone),
          const Divider(color: Colors.white12),
          _tile('Sobre nós', Icons.info_outline, () {}),
          const Divider(color: Colors.white12),
          _tile('Sair', Icons.logout, _showExitDialog, color: Colors.redAccent),
        ]),
      );

  ListTile _tile(String t, IconData i, VoidCallback f, {Color? color}) =>
      ListTile(
        leading: Icon(i, color: color ?? Colors.white60, size: 20),
        title: Text(t,
            style: TextStyle(color: color ?? Colors.white70, fontSize: 13)),
        onTap: f,
        dense: true,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuButton — botão individual com glassmorphism e sombras no texto
// ─────────────────────────────────────────────────────────────────────────────
class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required super.key,
    required this.config,
    required this.editMode,
    required this.onTap,
  });

  final MenuItemConfig config;
  final bool editMode;
  final VoidCallback? onTap;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.config.category.accent;
    final cat = widget.config.category;

    final buttonContent = ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          color: cat.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accent.withValues(alpha: widget.editMode ? 0.6 : 0.35),
            width: widget.editMode ? 1.2 : 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: cat.glow,
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Ícone com fundo colorido
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(widget.config.icon, color: accent, size: 22),
                  ),
                  const SizedBox(width: 10),

                  // Textos com sombra para legibilidade
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.config.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 6,
                              ),
                              Shadow(
                                color: accent.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.config.sublabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: accent.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.7),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Handle visual no modo edição
                  if (widget.editMode)
                    Icon(Icons.drag_indicator_rounded,
                        color: accent.withValues(alpha: 0.5), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Modo edição: sem GestureDetector para não bloquear o LongPressDraggable
    // do ReorderableBuilder — qualquer GestureDetector na frente vence a
    // arena de gestos e o drag nunca inicia.
    if (widget.editMode) {
      return buttonContent;
    }

    if (widget.editMode) return buttonContent; // ← sem gesto

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: buttonContent,
    );
  }
}
