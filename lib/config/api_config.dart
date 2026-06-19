// Configuração de API - fácil trocar entre localhost e produção
class ApiConfig {
  // Mude para true para testar em localhost
  static const bool useLocalhost = false;

  // URLs base
  static const String localhostUrl = 'http://127.0.0.1/tiven';
  static const String productionUrl = 'https://www.tiven.com.br/crud';

  // URL base dinâmica
  static String get baseUrl => useLocalhost ? localhostUrl : productionUrl;

  // Endpoints
  static String get loginUrl => '$baseUrl/Login.php';
  static String get registerUrl => '$baseUrl/Register.php';
  // Adicione mais endpoints conforme necessário
}
