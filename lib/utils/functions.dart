bool isValidSku(String input) {
  RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
  return input.isNotEmpty && regex.hasMatch(input);
}

bool isValidAddress_old(String input) {
  // Permite letras, números, "-", e " "
  RegExp regex = RegExp(r'[^a-zA-Z0-9-\s]');
  // Conta quantos "-" existem na string
  int dashCount = '-'.allMatches(input).length;
  return input.isNotEmpty && regex.hasMatch(input) && dashCount == 4;
}

bool isValidAddress(String input) {
  // Permite letras, números, hífen E ESPAÇOS
  RegExp invalidChars = RegExp(r'[^a-zA-Z0-9-\s]'); // \s = espaços

  // Conta quantos "-" existem
  int dashCount = '-'.allMatches(input).length;

  // Validação:
  return input.isNotEmpty &&
      dashCount == 4 &&
      !invalidChars.hasMatch(input); // NÃO tem caracteres inválidos
}
