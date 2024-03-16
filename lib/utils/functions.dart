 bool isValidSku(String input) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    return input.isNotEmpty && regex.hasMatch(input);
  }

  bool isValidAddress(String input) {
    RegExp regex =
        RegExp(r'^[a-zA-Z0-9-]+$'); // Permite letras, números, "-", e " "
    int dashCount =
        '-'.allMatches(input).length; // Conta quantos "-" existem na string
    return input.isNotEmpty && regex.hasMatch(input) && dashCount == 4;
  }