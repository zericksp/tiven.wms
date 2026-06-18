import 'dart:async';
import 'dart:convert';
import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tiven/utils/getData.dart';
import 'package:tiven/utils/functions.dart';
import 'package:tiven/widgets/beeps.dart';
import 'package:tiven/widgets/dialogMoveAddress.dart';
import 'package:tiven/widgets/nav-drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:mysql1/mysql1.dart';

// ============================================================================
// OTIMIZAÇÕES REALIZADAS:
// ============================================================================
// 1. Constantes extraídas para evitar recriação
// 2. ConnectionSettings como singleton
// 3. Debounce nos TextFields para evitar chamadas excessivas
// 4. Cache de imagens melhorado
// 5. Remoção de setState desnecessários
// 6. Lazy loading de recursos
// 7. Melhor gestão de memória
// 8. Código duplicado refatorado
// ============================================================================

class UpdateProd extends StatelessWidget {
  const UpdateProd({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ============================================================================
  // CONSTANTES (melhor performance)
  // ============================================================================
  static const String _imageBaseUrl = 'https://www.tiven.com.br/crud/images/';
  static const String _blingApiUrl = 'https://www.bling.com.br/Api/v3/';
  static const String _clientId = '5ec82041fae60a71485134ad93e576357f746eb7';
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const Duration _focusDelay = Duration(milliseconds: 200);

  // Singleton para ConnectionSettings
  static final _dbSettings = ConnectionSettings(
    host: 'www.tiven.com.br',
    port: 3306,
    user: 'eladec62_tbs',
    password: 'Pedimu\$-2019',
    db: 'eladec62_tbs',
  );

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  late final TextEditingController _scanController;
  late final TextEditingController _scanAddController;
  late final FocusNode _focusNodeItem;
  late final FocusNode _focusNodeAddress;
  late final FocusNode _focusNodeNewAddress;

  Timer? _debounceTimer;

  String _id = '';
  String _barcode = '';
  String _title = '';
  String _location = '';
  String _lastCode = '';
  String _lastAddress = '';
  String _sku = '';

  String _imagePath = '${_imageBaseUrl}cover.jpg';

  bool _isChecked = false;
  bool _isLoading = false;

  // ============================================================================
  // LIFECYCLE
  // ============================================================================
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadQrcode();
  }

  void _initializeControllers() {
    _scanController = TextEditingController();
    _scanAddController = TextEditingController();
    _focusNodeItem = FocusNode();
    _focusNodeAddress = FocusNode();
    _focusNodeNewAddress = FocusNode();

    // Listeners otimizados
    _focusNodeItem.addListener(_onItemFocusChanged);
    _focusNodeAddress.addListener(_onAddressFocusChanged);
  }

  void _onItemFocusChanged() {
    if (_focusNodeItem.hasFocus) {
      _scanController.clear();
      _hideKeyboard();
    }
  }

  void _onAddressFocusChanged() {
    if (_focusNodeAddress.hasFocus) {
      _scanAddController.clear();
      _hideKeyboard();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scanController.dispose();
    _scanAddController.dispose();
    _focusNodeItem.dispose();
    _focusNodeAddress.dispose();
    _focusNodeNewAddress.dispose();
    super.dispose();
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
  void _hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _loadQrcode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      prefs.getInt('qrcode');
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playSound(int soundIndex, {int duration = 500}) {
    FlutterBeepPlayer.playSound(soundIndex: soundIndex, duration: duration);
  }

  // ============================================================================
  // DEBOUNCED HANDLERS (evita chamadas excessivas)
  // ============================================================================
  void _onItemChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => _processItemScan(value));
  }

  void _onAddressChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => _processAddressScan(value));
  }

  // ============================================================================
  // BUSINESS LOGIC - REFATORADO
  // ============================================================================
  Future<void> _processItemScan(String code) async {
    if (!isValidSku(code)) {
      _playSound(40);
      _scanController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      _barcode = code;
      await _fetchProductData();

      if (_sku.length <= 3) {
        _playSound(91);
        _scanController.clear();
      } else {
        _playSound(code == _lastCode ? 51 : 57,
            duration: code == _lastCode ? 150 : 1000);
        _lastCode = code;

        Future.delayed(_focusDelay, () {
          if (mounted) _focusNodeAddress.requestFocus();
        });
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao processar item: $e');
      _playSound(91);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processAddressScan(String address) async {
    if (!isValidAddress(address)) {
      _playSound(40);
      _scanController.clear();
      return;
    }
    final cleanAddress = address.replaceAll(' ', '').replaceAll('-', '');
    _location = cleanAddress;

    if (cleanAddress.length != 6) {
      _playSound(2, duration: 250);
      return;
    }

    _playSound(cleanAddress == _lastAddress ? 51 : 57,
        duration: cleanAddress == _lastAddress ? 150 : 1000);
    _lastAddress = cleanAddress;

    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted && cleanAddress.length >= 6) {
      final quantity = await showQuantityDialog(
          context, _isChecked ? 'Movimentar' : 'Endereçar');

      if (quantity != null && quantity > 0) {
        await _updateProduct(quantity);
      }
    }

    Future.delayed(_focusDelay, () {
      if (mounted) _focusNodeItem.requestFocus();
    });
  }

  // ============================================================================
  // DATABASE OPERATIONS - OTIMIZADO
  // ============================================================================
  Future<void> _fetchProductData() async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_dbSettings);

      final results = await conn.query(
        '''SELECT prd_id, prd_codigo, prd_descricao, prd_gtin, prd_localizacao 
           FROM tbl_produtos 
           WHERE prd_codigo = ? OR prd_gtin = ?
           LIMIT 1''',
        [_barcode, _barcode],
      );

      if (results.isEmpty) {
        await _fetchFromBling();
        return;
      }

      final row = results.first;
      if (mounted) {
        setState(() {
          _id = row['prd_id']?.toString() ?? '';
          _sku = row['prd_codigo'] ?? '';
          _title = row['prd_descricao'] ?? '';
          _barcode = row['prd_gtin']?.toString() ?? '';
          _location = row['prd_localizacao'] ?? 'N/A';
          _imagePath = '$_imageBaseUrl${row['prd_codigo']}.jpg';
        });
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar produto: $e');
      _resetProductData();
    } finally {
      await conn?.close();
    }
  }

  Future<void> _fetchFromBling() async {
    try {
      final token = await getToken(_clientId);
      final response = await http.get(
        Uri.parse('${_blingApiUrl}produtos?codigo=$_barcode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final produto = data['data']?[0];

        if (produto != null && mounted) {
          setState(() {
            _id = produto['id']?.toString() ?? '';
            _sku = produto['codigo']?.toString() ?? '';
            _title = produto['nome']?.toString() ?? '';
            _location = 'N/A';
            _imagePath = '$_imageBaseUrl${produto['codigo']}.jpg';
          });
        }
      } else {
        _resetProductData();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar do Bling: $e');
      _resetProductData();
    }
  }

  void _resetProductData() {
    if (mounted) {
      setState(() {
        _id = '';
        _sku = '';
        _title = '';
        _location = '';
        _imagePath = '${_imageBaseUrl}notregistered.png';
      });
    }
  }

  Future<void> _updateProduct(double quantity) async {
    if (_sku.isEmpty || _location.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // CRÍTICO: Chama o PHP que já tem toda a lógica de negócio
      // incluindo atualização no Bling
      await _updateProd(_id, _barcode, _sku, _location, quantity.toInt());

      if (mounted) {
        _showSnackbar('Item atualizado com sucesso!', Colors.teal.shade200);
        _clearInputs();
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao atualizar produto: $e');
      if (mounted) {
        _showSnackbar('Erro: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Chama o PHP updateProduct.php que já tem toda lógica:
  /// - Atualiza banco local baseado no primeiro caractere do endereço
  /// - Atualiza estoque no Bling
  /// - Atualiza localização no Bling
  Future<String> _updateProd(String id, String barcode, String sku,
      String address, int quantity) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.129/tiven.com.br/crud/updateProduct.php?'
            'BARCODE=$barcode&'
            'SKU=$sku&'
            'ADDRESS=$address&'
            'QUANTITY=$quantity'),
        headers: {"Accept": "application/json"},
      ).timeout(const Duration(seconds: 200));

      if (kDebugMode) {
        print('📌 PHP Response: ${response.body}');
      }

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1 || data['success'] == true) {
          return 'Sucesso';
        }
      }

      throw Exception('Falha na atualização');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao chamar PHP: $e');
      rethrow;
    }
  }

  void _clearInputs() {
    _scanController.clear();
    _scanAddController.clear();
    setState(() {
      _title = '';
      _sku = '';
      _location = '';
    });
  }

  // ============================================================================
  // BARCODE SCANNER
  // ============================================================================
  Future<void> _scanBarcode(bool isAddress) async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );

      if (result.isNotEmpty && result != '-1' && mounted) {
        if (isAddress) {
          _scanAddController.text = result;
          await _processAddressScan(result);
        } else {
          _scanController.text = result;
          await _processItemScan(result);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao escanear: $e');
    }
  }

// ============================================================================
  // QRCODE SCANNER
  // ============================================================================
  Future<void> _scanQRcode(bool isAddress) async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.QR,
      );

      if (result.isNotEmpty && result != '-1' && mounted) {
        if (isAddress) {
          _scanAddController.text = result;
          await _processAddressScan(result);
        } else {
          _scanController.text = result;
          await _processItemScan(result);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao escanear: $e');
    }
  }

  // ============================================================================
  // UI BUILD - OTIMIZADO
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      drawer: NavDrawer(),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isChecked ? 'Movimentar' : 'Endereçar',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 80),
          Image.asset('assets/images/logo.png',
              height: 26, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Divider(color: Colors.grey),
          _buildProductImage(),
          const Divider(color: Colors.grey),
          _buildProductTitle(),
          _buildItemField(),
          const SizedBox(height: 20),
          _buildAddressField(),
          const SizedBox(height: 20),
          if (_isChecked) _buildNewAddressField(),
          if (!_isChecked) const SizedBox(height: 48),
          const SizedBox(height: 20),
          _buildToggleSwitch(),
          const Text(
            'Altere entre Endereçar e Movimentar',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              _barcode,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(offset: Offset(1.5, 1.5), color: Colors.black26)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      alignment: const Alignment(0.80, 0.80),
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: _imagePath,
            fit: BoxFit.fill,
            cacheKey: _sku,
            memCacheHeight: 200,
            memCacheWidth: 200,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Colors.white,
              radius: 80,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Colors.red,
              radius: 80,
              child: Image.asset('assets/images/nopic.png'),
            ),
          ),
        ),
        if (_sku.isNotEmpty) _buildProductBadge(),
      ],
    );
  }

  Widget _buildProductBadge() {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white10),
        color: Colors.white54,
      ),
      child: Text(
        '$_sku\n$_location',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      _title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        height: 2,
        fontSize: 15,
        color: Colors.white,
        shadows: [
          Shadow(offset: Offset(-0.5, -0.5), color: Colors.grey),
          Shadow(offset: Offset(0.5, -0.5), color: Colors.grey),
          Shadow(offset: Offset(0.5, 0.5), color: Colors.grey),
          Shadow(offset: Offset(-0.5, 0.5), color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildItemField() {
    return TextField(
      focusNode: _focusNodeItem,
      controller: _scanController,
      keyboardType: TextInputType.none,
      autofocus: true,
      onChanged: _onItemChanged,
      onTap: _hideKeyboard,
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Item',
        labelStyle: const TextStyle(color: Colors.grey),
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.barcode_reader, color: Colors.grey, size: 24),
          onPressed: () => _scanBarcode(false),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.grey, size: 24),
          onPressed: () {
            _scanController.clear();
            _focusNodeItem.requestFocus();
          },
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextField(
      focusNode: _focusNodeAddress,
      controller: _scanAddController,
      keyboardType: TextInputType.none,
      onChanged: _onAddressChanged,
      onTap: _hideKeyboard,
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Endereço',
        labelStyle: const TextStyle(color: Colors.grey),
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.barcode_reader, color: Colors.grey, size: 24),
          onPressed: () => _scanQRcode(true),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.grey, size: 24),
          onPressed: () {
            _scanAddController.clear();
            _focusNodeAddress.requestFocus();
          },
        ),
      ),
    );
  }

  Widget _buildNewAddressField() {
    return TextField(
      focusNode: _focusNodeNewAddress,
      controller: _scanController,
      keyboardType: TextInputType.none,
      onTap: _hideKeyboard,
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        labelText: 'Novo Endereço',
        labelStyle: TextStyle(color: Colors.grey),
        isDense: true,
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        prefixIcon: Icon(Icons.barcode_reader, color: Colors.grey, size: 24),
        suffixIcon: Icon(Icons.delete_rounded, color: Colors.grey, size: 24),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCheckBox(
            value: _isChecked,
            shouldShowBorder: true,
            borderColor: Colors.blueAccent,
            checkedFillColor: Colors.blueAccent,
            uncheckedFillColor: Colors.blueGrey,
            borderRadius: 6,
            borderWidth: 1,
            checkBoxSize: 35,
            onChanged: (val) => setState(() => _isChecked = val),
          ),
          const SizedBox(width: 8),
          Text(
            _isChecked ? 'Movimentar' : 'Endereçar',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
