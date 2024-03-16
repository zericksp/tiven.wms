import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class QuantityDialog extends StatefulWidget {
  final String title;
  const QuantityDialog({super.key, required this.title});

  @override
  // ignore: library_private_types_in_public_api
  _QuantityDialogState createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  String quantity = '0'; // Valor inicial como string

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Quantidade"),
          SpinBox(
            min: 0,
            max: 200,
            value: double.parse(quantity),
            onChanged: (value) {
              setState(() {
                quantity = value.toStringAsFixed(0); // Atualiza o valor de quantidade
              });
            },
          ),
          // Calculadora de números
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 números por linha
              childAspectRatio: 1.0, // Mantém o formato quadrado
            ),
            itemCount: 10, // Números de 0 a 9
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Atualiza a quantidade concatenando o número
                    quantity += '$index';
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
          },
          child: Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            // Retorna o valor de quantidade se for maior que 0
            if (double.parse(quantity) > 0) {
              Navigator.of(context).pop(double.parse(quantity)); // Fecha o diálogo e retorna o valor
            } else {
              Navigator.of(context).pop(); // Fecha o diálogo sem retorno se for 0
            }
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}

// Para chamar o diálogo e obter o valor:
Future<double?> showQuantityDialog(BuildContext context, String title) async {
  double? selectedQuantity = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return QuantityDialog(title: title);
    },
  );
  
  return selectedQuantity; // Retorna o valor selecionado ou null
}
