import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LastProducedWidget extends StatefulWidget {
  final String title, idUser;

  // Removed unnecessary `username` parameter
  const LastProducedWidget(
      {super.key,
      required this.title,
      required this.idUser,
      required String username});

  @override
  _LastProducedWidgetState createState() => _LastProducedWidgetState();
}

class _LastProducedWidgetState extends State<LastProducedWidget> {
  List<dynamic> dados = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchDados();
  }

  Future<void> fetchDados() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.tiven.com.br/bling/getLastDailyProduced.php'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          dados = jsonData["data"] ?? [];
          isLoading = false; // Stop loading once data is fetched
        });
      } else {
        throw Exception('Erro ao carregar os dados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados: $e');
      }
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 500, // Ensure it has a height constraint
        child: lastItems(),
      ),
    );
  }

  Widget lastItems() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (dados.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum item encontrado",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: dados.length,
      itemBuilder: (context, index) {
        final product = dados[index];

        return Container(
          color: index.isEven ? Colors.black : Colors.grey[800],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: ListTile(
            title: Text(
              product["prd_descricao"] ?? "Sem descrição",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              "Quantidade: ${product["total_quantidade"] ?? '0'}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              "Código: ${product["prd_codigo"] ?? '-'}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
