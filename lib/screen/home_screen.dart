import 'package:clima_app/models/clima.dart';
import 'package:clima_app/services/clima_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cidadeController = TextEditingController(
    text: 'São Paulo',
  );

  // Instância responsável pelas requisições HTTP.
  final ClimaService _servico = ClimaService();

  // Guarda a operação assíncrona de busca.
  // late Future<double> _temperatura;
  late Future<Clima> _clima;

  // Nome exbido acima das informações meteorológicas. Inicialmente, São Paulo.
  String _cidadeExibida = 'São Paulo';

  @override
  void initState() {
    super.initState();

    // Iniciamos a consulta uma vez ao abrir a tela.
    // _temperatura = _servico.buscarTemperatura();
    _clima = _servico.buscarClima(_cidadeExibida);
  }

  // void _atualizar() {
  //   setState(() {
  //     // _temperatura = _servico.buscarTemperatura();
  //     _clima = _servico.buscarClima(_cidadeExibida);
  //   });
  // }

  // Executando a busca com o texto digitado pela primeira vez.
  void _pesquisar() {
    // trim evita() para evitar espaços em branco na busca.
    final nome = _cidadeController.text.trim();

    setState(() {
      _cidadeExibida = nome;

      // Um novo Future faz o FutureBuilder reconstruir a tela com os novos dados.
      _clima = _servico.buscarClima(nome);
    });
  }

  @override
  void dispose() {
    _cidadeController.dispose();
    // libera is recursoi do controller quando a tela é destruída.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaApp'),
        actions: [
          // Botão para executar a função atualizar.
          IconButton(
            onPressed: () {
              setState(() {
                _clima = _servico.buscarClima(_cidadeExibida);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar clima',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _cidadeController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _pesquisar(),
              decoration: const InputDecoration(
                labelText: 'Cidade',
                hintText: 'Ex: Campinas',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _pesquisar,
              label: const Text('Pesquisar'),
              icon: const Icon(Icons.search),
            ),

            const SizedBox(height: 20),

            // expanded oferece o espaço restante à area de dados.
            Expanded(
              child: FutureBuilder<Clima>(
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
                              onPressed: _pesquisar,
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
                    return const Center(
                      child: Text('Dados de clima indisponíveis.'),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thermostat, size: 60),

                        Text('Cidade:'),

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
            ),
          ],
        ),
      ),
    );
  }
}
