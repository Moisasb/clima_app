
import 'dart:io';

// Serviço que busca informações do clima na internet.
import 'dart:convert';

// Permite reconhecer quando uma operação ultrapassa o tempo limite definido.
import 'dart:async';

// Biblioteca externa usada para fazer requisições HTTP.
import 'package:clima_app/models/clima.dart';
import 'package:http/http.dart' as http;

// Exceção personalizada para erros no serviço de clima.
class ClimaException implements Exception {
  final String mensagem;

  // Construtor que recebe a mensagem de erro.
  const ClimaException(this.mensagem);

  // Sobrescreve o método toString para exibir a mensagem de erro.
  @override
  // Retorna a mensagem de erro quando a exceção é convertida em string.
  String toString() => mensagem;
}

// Reúne a lógica de comunicação com a API.
class ClimaService {
  // Future<double>: o resultado será um número decimal,
  // mas chegará no futuro, após a resposta da internet.
  Future<double> buscarTemperatura() async {
    // Endereço com as coordenadas de São Paulo.
    // current=temperature_2m solicita a temperatura atual.
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=-23.55&longitude=-46.63'
      '&current=temperature_2m,apparent_temperature,'
      'relative_humidity_2m,wind_speed_10m'
      '&timezone=America%2FSao_Paulo',
    );

    // Espera a resposta sem travar a interface.
    // Timeout evita aguardar indefinidamente.
    final resposta = await http.get(url).timeout(
      const Duration(seconds: 12),
    );

    // 200 significa que a consulta HTTP foi bem-sucedida.
    if (resposta.statusCode != 200) {
      // Lança o erro para a interface poder informar a falha.
      throw Exception('Erro HTTP: ${resposta.statusCode}');
    }

    // JsonDecode transforma o texto JSON em dados Dart.
    // Map<String, dynamic> indica um objeto JSON.
    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;

    // current é um objeto dentro do JSON recebido.
    final atual = dados['current'] as Map<String, dynamic>;

    // num aceita números inteiros ou decimais.
    // toDouble() garante o tipo double prometido no Future.
    final temperatura = atual['temperature_2m'] as num;

    return temperatura.toDouble();
  }

  // Busca todas as informações atuais do clima.
  Future<Clima> buscarClima() async {
    // Endereço com as coordenadas de São Paulo.
    // Solicita temperatura, sensação térmica, umidade e vento.
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=-23.55&longitude=-46.63'
      '&current=temperature_2m,apparent_temperature,'
      'relative_humidity_2m,wind_speed_10m'
      '&timezone=America%2FSao_Paulo',
    );

    try {
      // Espera a resposta sem travar a interface.
      // Timeout evita aguardar indefinidamente.
      final resposta = await http.get(url).timeout(
        const Duration(seconds: 12),
      );

      // 200 significa que a consulta HTTP foi bem-sucedida.
      if (resposta.statusCode != 200) {
        throw const ClimaException(
          'O serviço de clima está indisponível. Tente novamente.',
        );
      }

      // JsonDecode transforma o texto JSON em dados Dart.
      // Map<String, dynamic> indica um objeto JSON.
      final dados = jsonDecode(resposta.body);

      if (dados is! Map<String, dynamic>) {
        throw const ClimaException('Resposta inesperada da API.');
      }

      // current é um objeto dentro do JSON recebido.
      final atual = dados['current'];

      if (atual is! Map<String, dynamic>) {
        throw const ClimaException('Dados atuais indisponíveis.');
      }

      // O modelo faz a conversão de chaves JSON em campos Dart.
      return Clima.fromJson(atual);

    } on ClimaException {
      // Preserva a mensagem que criamos lá em cima.
      rethrow;
    } on SocketException {
      // Sem rede, DNS indisponível ou conexão recusada.
      throw const ClimaException(
        'Sem conexão com a internet. Verifique sua rede.',
      );
      // TimeoutException é lançada quando a resposta demora demais.
    } on TimeoutException {
      throw ClimaException('A consulta demorou demais. Tente novamente.');
    
    } on http.ClientException {
      // outros problemas reportados pelo cliente
      throw const ClimaException('Não foi possível conectar o servidor ao clima.'
      );
    } on FormatException {
      // JsonDecode não conseguiu interpretar a resposta
      throw const ClimaException('Resposta inválida da API.');
    } on TypeError {
      // algum campo esperado não estava no JSON
      throw const ClimaException(
      'Os Dados de clima estão incompletos ou inválidos.');
    }
  }
} 