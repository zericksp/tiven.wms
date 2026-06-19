# Guia de Testes - Localhost vs Produção

## 🔧 Como Testar em Localhost

### 1. **Configurar Flutter para Localhost**

Abra: `lib/config/api_config.dart`

```dart
// Mude para true para testar em localhost
static const bool useLocalhost = true;  // ← MUDE PARA true

// URLs base
static const String localhostUrl = 'http://127.0.0.1/tiven';
static const String productionUrl = 'https://www.tiven.com.br/crud';
```

### 2. **Configurar Servidor PHP Local**

Você precisa de um servidor local (XAMPP, Wamp, etc) rodando:

```bash
# Localização dos arquivos:
C:\xampp\htdocs\tiven\  ← Raiz
  ├── crud/
  │   ├── Login.php
  │   ├── connect.php
  │   └── ... outros arquivos
  └── config/
```

**URL para testar:**
```
http://127.0.0.1/tiven/crud/Login.php
```

### 3. **Atualizar Arquivo Login.php**

Se não fez ainda, atualize o `Login.php` para receber JSON POST:

```php
<?php
require_once '../connect.php';

header('Content-Type: application/json');

// Recebe dados do POST como JSON (mais seguro que GET)
$data = json_decode(file_get_contents("php://input"), true) ?? [];
$user = $data['user'] ?? '';
$password = $data['password'] ?? '';

// ... resto do código
```

### 4. **Testar no Flutter**

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔄 Fluxo de Teste

### Localhost (Testes)
```
1. useLocalhost = true
2. URL = http://127.0.0.1/tiven/crud/Login.php
3. Testar localmente sem internet
4. Testar com banco de dados local
```

### Produção (Deploy)
```
1. useLocalhost = false
2. URL = https://www.tiven.com.br/crud/Login.php
3. Usar dados reais do servidor
4. Usar banco de dados de produção
```

---

## 🌐 Adicionar Mais Endpoints

Para adicionar novos endpoints, edite `api_config.dart`:

```dart
class ApiConfig {
  static const bool useLocalhost = false;
  
  static const String localhostUrl = 'http://127.0.0.1/tiven';
  static const String productionUrl = 'https://www.tiven.com.br/crud';
  
  static String get baseUrl => useLocalhost ? localhostUrl : productionUrl;
  
  // Login
  static String get loginUrl => '$baseUrl/Login.php';
  
  // Adicione aqui:
  static String get registerUrl => '$baseUrl/Register.php';
  static String get profileUrl => '$baseUrl/Profile.php';
  static String get productsUrl => '$baseUrl/Products.php';
  // ... etc
}
```

**Depois use no código:**

```dart
// Em vez de:
Uri.parse("https://www.tiven.com.br/crud/Login.php")

// Use:
Uri.parse(ApiConfig.loginUrl)
```

---

## ✅ Verificação

- [x] `useLocalhost = false` (padrão para produção)
- [x] Altere para `true` quando testar localmente
- [x] Login.php atualizado para receber POST JSON
- [x] Banco de dados local com usuários de teste
- [x] Build do Flutter compila sem erros

---

## 🐛 Troubleshooting

### Erro: "Failed to connect to localhost"
- Verifique se XAMPP/Wamp está rodando
- Teste no navegador: `http://127.0.0.1/tiven/crud/Login.php`
- Verifique firewall/antivírus

### Erro: "Invalid JSON"
- Login.php está procurando $_GET em vez de $_POST
- Use o código PHP corrigido acima

### Erro: "Connection refused"
- Servidor não está rodando
- Inicie o XAMPP/Wamp
- Verifique a porta (padrão é 80)

---

## 📝 Checklist de Antes do Deploy

Antes de fazer push para produção:

- [ ] `useLocalhost = false` (não esqueça!)
- [ ] Testar com URL de produção
- [ ] Verificar se servidor está online
- [ ] Testar login com dados reais
- [ ] Testar em diferentes dispositivos
- [ ] Remover prints de debug (usar logger)

---

**Dica**: Use comentários no código para lembrar:

```dart
// ⚠️ MUDE PARA FALSE ANTES DO DEPLOY!
static const bool useLocalhost = true;
```

