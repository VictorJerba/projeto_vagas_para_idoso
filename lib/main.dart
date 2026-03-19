import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vagas Idoso',
      debugShowCheckedModeBanner: false, // Tira a faixa de "debug" do canto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

// Tela 1
class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vagas Acessíveis',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 28),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Espaço que simula o mapa
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  '[ MAPA AQUI ]\nExibindo vagas próximas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.black54),
                ),
              ),
            ),
          ),
          // Botão Grande para Alertar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 90, // Altura grande para facilitar o toque
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Ação de ir para a próxima tela
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaReportar()),
                  );
                },
                child: const Text(
                  'ALERTAR PROBLEMA',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tela 2: Reportar Problemas

class TelaReportar extends StatelessWidget {
  const TelaReportar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'O que aconteceu?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botões de problemas baseados no seu TCC
            _botaoProblema('🚧 ENTULHO NA VAGA', Colors.orange[800]!),
            const SizedBox(height: 16),
            _botaoProblema('🕳️ BURACO NA ROTA', Colors.orange[800]!),
            const SizedBox(height: 16),
            _botaoProblema('🚗 CARRO NA RAMPA', Colors.orange[800]!),

            const Spacer(), // Empurra o botão de voltar para o final

            // Botão de Voltar
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Ação de voltar para o mapa
                  Navigator.pop(context);
                },
                child: const Text(
                  'VOLTAR PARA O MAPA',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para padronizar os botões grandes de alerta
  Widget _botaoProblema(String texto, Color cor) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {

        },
        child: Text(
          texto,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}