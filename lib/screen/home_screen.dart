import 'package:clima_app/models/clima.dart';
import 'package:clima_app/services/clima_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instância responsável pelas requisições HTTP.
  final ClimaService _servico = ClimaService();

  // Guarda a operação assíncrona de busca.
  // late Future<double> _temperatura;
  late Future<Clima> _clima;

  @override
  void initState() {
    super.initState();

    // Iniciamos a consulta uma vez ao abrir a tela.
    // _temperatura = _servico.buscarTemperatura();
    _clima = _servico.buscarClima();
  }

  void _atualizar() {
    setState(() {
      // _temperatura = _servico.buscarTemperatura();
      _clima = _servico.buscarClima();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaApp'),
        actions: [
          // Botão para executar a função atualizar.
          Tooltip(
            message: 'Atualizar Clima',
            child: IconButton(
              onPressed: _atualizar,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),

      body: FutureBuilder<Clima>(
        future: _clima,
        builder: (context, snapshot) {
          // Enquanto a resposta não chega, mostra o progresso.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // hasError: o Future terminou com uma exceção.
          if (snapshot.hasError) {
            // Recupera o erro retornado pelo serviço.
            final erro = snapshot.error;

            // Verifica se o erro é uma ClimaException.
            final mensagem = erro is ClimaException
                ? erro.mensagem
                : 'Ocorreu um erro inesperado.';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 48),

                    const SizedBox(height: 16),

                    const Text('Não foi possível consultar o clima'),

                    const SizedBox(height: 8),

                    Text(mensagem, textAlign: TextAlign.center),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _atualizar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // final temperatura = snapshot.data;
          final clima = snapshot.data;

          if (clima == null) {
            return const Center(child: Text('Dados de clima indisponíveis.'));
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.thermostat, size: 60),

                const Text('São Paulo'),

                Text(
                  '${clima.temperatura.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 36),
                ),

                Text(
                  'Sensação: '
                  '${clima.sensacaoTermica.toStringAsFixed(1)} °C',
                ),

                Text('Umidade: ${clima.umidade}%'),

                Text('Vento: ${clima.vento.toStringAsFixed(1)} km/h'),
              ],
            ),
          );
        },
      ),
    );
  }
}
