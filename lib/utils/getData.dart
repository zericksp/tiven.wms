import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart';
import 'package:tiven/widgets/snackBar.dart';

final settings = ConnectionSettings(
  host: 'www.tiven.com.br', // Substitua pelo IP ou domínio do seu servidor
  port: 3306, // Porta padrão do MySQL
  user: 'eladec62_tbs',
  password: 'Pedimu\$-2019',
  db: 'eladec62_tbs',
);
int tried = 0;
int code = 0; // Código de resposta HTTP
int timeToTry = 1; // Tempo em segundos para esperar antes de tentar novamente

Future<String> getToken(String appId) async {
  MySqlConnection? conn;
  try {
    // Conectar ao banco de dados
    conn = await MySqlConnection.connect(settings);

    // Chamar a procedure armazenada
    var results = await conn.query('CALL prc_getBlingToken(?)', [appId]);

    // Retorna o token se houver resultado
    if (results.isNotEmpty) {
      return results.first['accessToken'] as String;
    } else {
      return "Nenhum resultado encontrado.";
    }
  } catch (e) {
    throw Exception("Erro no banco de dados: $e");
  } finally {
    // Garante que a conexão será fechada
    await conn?.close();
  }
}

Future<String> updateAddressStock(
    BuildContext context, String location, String sku) async {
  MySqlConnection? conn;
  String response = "";

  try {
    conn = await MySqlConnection.connect(settings);
    if (kDebugMode) {
      print("✅ Conectado ao banco MySQL!");
    }
    if (kDebugMode) {
      print("📌 Dados recebidos -> Location: $location | SKU: $sku");
    }
    // Query SQL agora atualiza localização
    String query = '''
      UPDATE tbl_produtos 
      SET prd_localizacao = ? 
      WHERE prd_codigo = ?
    ''';

    var result = await conn.query(query, [location, sku]);
    if (kDebugMode) {
      print("📌 Query executada: $query");
    }
    if (result.affectedRows == 0) {
      if (kDebugMode) {
        print(
            "⚠️ Nenhuma linha foi atualizada. Verifique os valores informados.");
      }
      showSnackbar(context,
          "Nenhuma linha foi atualizada. Verifique os valores.", Colors.red);
      response = "Item: $sku - Localização [$location] não foi atualizado.\n";
    } else {
      if (kDebugMode) {
        print("✅ ${result.affectedRows} linha(s) atualizada(s)!");
      }
      showSnackbar(context, "Item atualizado com sucesso!", Colors.orange);
      response =
          "Item: $sku - Localização [$location] atualizado com sucesso.\n";
    }
  } catch (e, stacktrace) {
    if (kDebugMode) {
      print("❌ Erro ao executar a operação: $e");
      print(stacktrace);
    }
    showSnackbar(context, "Erro ao atualizar produto: $e", Colors.red);
    response = "Item: $sku - Localização [$location] atualizado com sucesso.\n";
  } finally {
    if (conn != null) {
      await conn.close();
      if (kDebugMode) {
        print("🔌 Conexão fechada com o banco.");
      }
    }
  }
  return response;
}

Future<String> changeItemQtyAddress(
    BuildContext context, String location, String sku, int qty) async {
  MySqlConnection? conn;
  String response = "";

  try {
    conn = await MySqlConnection.connect(settings);
    if (kDebugMode) {
      print("✅ Conectado ao banco MySQL!");
    }
    if (kDebugMode) {
      print(
          "📌 Dados recebidos -> Location: $location | SKU: $sku | Qty: $qty");
    }
    // Query SQL agora atualiza localização e quantidade
    String query = '''
      UPDATE tbl_produtos 
      SET prd_localizacao = ?, prd_quantidade = ? 
      WHERE prd_codigo = ?
    ''';

    var result = await conn.query(query, [location, qty, sku]);
    if (kDebugMode) {
      print("📌 Query executada: $query");
    }
    if (result.affectedRows == 0) {
      if (kDebugMode) {
        print(
            "⚠️ Nenhuma linha foi atualizada. Verifique os valores informados.");
      }
      showSnackbar(context,
          "Nenhuma linha foi atualizada. Verifique os valores.", Colors.red);
      response =
          "Item: $sku - Qty [$qty] e Localização [$location] não foi atualizado.\n";
    } else {
      if (kDebugMode) {
        print("✅ ${result.affectedRows} linha(s) atualizada(s)!");
      }
      showSnackbar(context, "Item atualizado com sucesso!", Colors.orange);
      response =
          "Item: $sku - Qty [$qty] e Localização [$location] atualizado com sucesso.\n";
    }
  } catch (e, stacktrace) {
    if (kDebugMode) {
      print("❌ Erro ao executar a operação: $e");
      print(stacktrace);
      response =
          "Item: $sku - Qty [$qty] e Localização [$location] não foi atualizado.\n";
    }
    showSnackbar(context, "Erro ao atualizar produto: $e", Colors.red);
  } finally {
    if (conn != null) {
      await conn.close();
      if (kDebugMode) {
        print("🔌 Conexão fechada com o banco.");
      }
    }
  }
  return response;
}

Future<String> getProductByCode(String itemCode, String token) async {
  var requestDB = http.Request(
      'GET',
      Uri.parse(
          'https://www.tiven.com.br/crud/getProductByCode.php?CODE=$itemCode'));

  // Envia a requisição e aguarda a resposta
  http.StreamedResponse response = await requestDB.send();
  timeToTry = timeToTry * 2; // Dobra o tempo de espera a cada tentativa

  // Se a resposta for bem-sucedida, processa os dados
  if (response.statusCode == 200) {
    code = 200;
    if (kDebugMode) {
      final responseBody = await response.stream.bytesToString();
      print(responseBody);
      return responseBody;
    }
  } else {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Cookie': 'PHPSESSID=qp1pntfav25l6phnd0bc4hulq6'
    };
    var request = http.Request('GET',
        Uri.parse("https://www.bling.com.br/Api/v3/produtos?codigo=$itemCode"));

    request.headers.addAll(headers);
    code = 0;
    tried = 1;
    while (tried < 5 && code != 200) {
      // Aguarda 1 segundo antes de tentar novamente
      await Future.delayed(Duration(seconds: timeToTry));
      tried++;

      if (kDebugMode) {
        print("Tentativa: $tried");
      }
      if (kDebugMode) {
        print("Tentando novamente em $timeToTry segundos...");
      }
      // Envia a requisição e aguarda a resposta
      http.StreamedResponse response = await request.send();
      timeToTry = timeToTry * 2; // Dobra o tempo de espera a cada tentativa

      // Se a resposta for bem-sucedida, processa os dados
      if (response.statusCode == 200) {
        code = 200;
        if (kDebugMode) {
          final responseBody = await response.stream.bytesToString();
          print(responseBody);
          return responseBody;
        }
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
        return Future.error(
            "Failed to fetch product: ${response.reasonPhrase}");
      }
    }
  }
  throw Exception("Unexpected error occurred while fetching product.");
}

Future<void> insDailyProd(BuildContext context, sku, title, barcode) async {
  MySqlConnection? conn;
  int qty = 1;
  try {
    conn = await MySqlConnection.connect(settings);

    String query = '''
      INSERT INTO tbl_daily_produced_products 
      (prd_codigo, prd_descricao, prd_quantidade, prd_gtin)
      VALUES (?, ?, ?, ?)
    ''';

    await conn.query(query, [sku, title, qty, barcode]);

    // Exibir Snackbar de sucesso (Laranja)
    showSnackbar(context, "Produto inserido com sucesso!", Colors.orange);
  } catch (e) {
    // Exibir Snackbar de erro (Vermelho)
    showSnackbar(context, "Erro ao inserir produto: $e", Colors.red);
  } finally {
    await conn?.close();
  }
}
