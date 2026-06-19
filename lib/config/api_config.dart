// Configuração de API - fácil trocar entre localhost e produção
class ApiConfig {
  // Mude para true para testar em localhost
  static const bool useLocalhost = true;

  // URLs base
  static const String localhostUrl = 'http://172.16.8.3/tiven.com.br';
  static const String productionUrl = 'https://www.tiven.com.br';

  // URL base dinâmica
  static String get baseUrl => useLocalhost ? localhostUrl : productionUrl;

  // Endpoints
  static String get loginUrl => '$baseUrl/Login.php';
  static String get registerUrl => '$baseUrl/Register.php';
  // Adicione mais endpoints conforme necessário
}
