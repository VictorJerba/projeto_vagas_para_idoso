import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'model/problema.dart';
import 'dao/problema_dao.dart';
import 'services/cep_service.dart';
import 'model/cep.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vagas Idoso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

// Classe que define como é uma vaga no sistema
class VagaFicticia {
  final LatLng posicao;
  final String tipo; // 'comum' ou 'idoso'
  final String status; // 'livre' ou 'ocupada'
  final String endereco;

  VagaFicticia({required this.posicao, required this.tipo, required this.status, required this.endereco});
}

// ==========================================
// TELA 1: PRINCIPAL (COM OPENSTREETMAP E VAGAS)
// ==========================================
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _subscription;

  // Sua posição inicial
  LatLng _posicaoAtual = const LatLng(-26.2337955, -52.6846242);

  // Lista de vagas espalhadas próximas a você
  final List<VagaFicticia> _vagas = [
    VagaFicticia(posicao: const LatLng(-26.233500, -52.684500), tipo: 'comum', status: 'livre', endereco: 'Rua Caramuru, 120m'),
    VagaFicticia(posicao: const LatLng(-26.234000, -52.684800), tipo: 'idoso', status: 'livre', endereco: 'Rua Guarani, 200m'),
    VagaFicticia(posicao: const LatLng(-26.233900, -52.684300), tipo: 'comum', status: 'ocupada', endereco: 'Rua Tocantins, 50m'),
    VagaFicticia(posicao: const LatLng(-26.233600, -52.684900), tipo: 'idoso', status: 'ocupada', endereco: 'Rua Tapir, 150m'),
    VagaFicticia(posicao: const LatLng(-26.233200, -52.684200), tipo: 'comum', status: 'livre', endereco: 'Av. Tupi, 300m'),
  ];

  @override
  void initState() {
    super.initState();
    _pedirPermissaoEMonitorar();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _pedirPermissaoEMonitorar() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return;
    }

    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _posicaoAtual = LatLng(position.latitude, position.longitude);
      _mapController.move(_posicaoAtual, 17.0); // Zoom um pouco mais perto
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position pos) {
      setState(() {
        _posicaoAtual = LatLng(pos.latitude, pos.longitude);
        _mapController.move(_posicaoAtual, 17.0);
      });
    });
  }

  // Abre a janela de detalhes inspirada no seu Figma
  void _mostrarDetalhesVaga(VagaFicticia vaga) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 24),
                Icon(
                  vaga.tipo == 'idoso' ? Icons.accessible : Icons.local_parking,
                  color: vaga.status == 'ocupada' ? Colors.red : (vaga.tipo == 'idoso' ? Colors.blue : Colors.green),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  vaga.status == 'ocupada' ? 'Vaga Ocupada' : 'Vaga Disponível',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  vaga.tipo == 'idoso' ? 'Exclusiva para Idosos' : 'Vaga Comum',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(vaga.endereco, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar para o Mapa', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  // === INTEGRAÇÃO COM A API (VIACEP) ===
  void _mostrarDialogBuscaCep(BuildContext context) {
    final cepController = TextEditingController();
    bool carregando = false;
    String resultado = '';

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Consultar Local da Vaga'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: cepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'CEP (somente números)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  if (carregando) const CircularProgressIndicator(),
                  if (!carregando && resultado.isNotEmpty) Text(resultado, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
                ElevatedButton(
                  onPressed: () async {
                    if (cepController.text.isEmpty) return;
                    setStateDialog(() { carregando = true; resultado = ''; });
                    try {
                      final service = CepService();
                      final Cep cepObj = await service.findCepAsObject(cepController.text);
                      setStateDialog(() {
                        resultado = '📍 Endereço:\n${cepObj.logradouro}\n${cepObj.localidade} - ${cepObj.uf}';
                      });
                    } catch (e) {
                      setStateDialog(() => resultado = '❌ Erro: CEP não encontrado.');
                    } finally {
                      setStateDialog(() => carregando = false);
                    }
                  },
                  child: const Text('Buscar API'),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Vagas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ÁREA DO MAPA OPEN SOURCE
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _posicaoAtual,
                initialZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vagas.idoso',
                ),
                MarkerLayer(
                  markers: [
                    // Renderiza as Vagas Fictícias
                    ..._vagas.map((vaga) {
                      Color corVaga = vaga.status == 'ocupada' ? Colors.red : (vaga.tipo == 'idoso' ? Colors.blue : Colors.green);
                      IconData iconeVaga = vaga.tipo == 'idoso' ? Icons.accessible : Icons.local_parking;

                      return Marker(
                        point: vaga.posicao,
                        width: 45, height: 45,
                        child: GestureDetector(
                          onTap: () => _mostrarDetalhesVaga(vaga),
                          child: Container(
                            decoration: BoxDecoration(
                              color: corVaga,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Icon(iconeVaga, color: Colors.white, size: 24),
                          ),
                        ),
                      );
                    }),

                    // Renderiza a Sua Posição Atual (Bolinha Azul com borda)
                    Marker(
                      point: _posicaoAtual,
                      width: 30, height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PAINEL DE BOTÕES (MANTIDO)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                      icon: const Icon(Icons.cloud_download, color: Colors.white),
                      label: const Text('BUSCAR ENDEREÇO VAGA (API)', style: TextStyle(color: Colors.white)),
                      onPressed: () => _mostrarDialogBuscaCep(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      label: const Text('MEUS ALERTAS (CRUD)', style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaMeusAlertas())),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaReportar())),
                      child: const Text('ALERTAR PROBLEMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TELA 2: REPORTAR PROBLEMA (CREATE) - INTACTO
// ==========================================
class TelaReportar extends StatelessWidget {
  const TelaReportar({super.key});

  void _salvarProblema(BuildContext context, String tipoProblema) async {
    final problema = Problema(tipo: tipoProblema, dataReporte: DateTime.now(), resolvido: false);
    await ProblemaDao().salvar(problema);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$tipoProblema salvo!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O que aconteceu?')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _botaoProblema(context, '🚧 ENTULHO NA VAGA', Colors.orange[800]!),
            const SizedBox(height: 16),
            _botaoProblema(context, '🕳️ BURACO NA ROTA', Colors.orange[800]!),
            const Spacer(),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('VOLTAR'))
          ],
        ),
      ),
    );
  }

  Widget _botaoProblema(BuildContext context, String texto, Color cor) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: cor),
        onPressed: () => _salvarProblema(context, texto),
        child: Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

// ==========================================
// TELA 3: MEUS ALERTAS (READ, UPDATE, DELETE) - INTACTO
// ==========================================
class TelaMeusAlertas extends StatefulWidget {
  const TelaMeusAlertas({super.key});
  @override
  State<TelaMeusAlertas> createState() => _TelaMeusAlertasState();
}

class _TelaMeusAlertasState extends State<TelaMeusAlertas> {
  final _dao = ProblemaDao();
  List<Problema> _problemas = [];

  @override
  void initState() {
    super.initState();
    _carregarProblemas();
  }

  void _carregarProblemas() async {
    final lista = await _dao.listar();
    setState(() => _problemas = lista);
  }

  void _alternarResolvido(Problema problema) async {
    problema.resolvido = !problema.resolvido;
    await _dao.salvar(problema);
    _carregarProblemas();
  }

  void _excluirProblema(int id) async {
    await _dao.excluir(id);
    _carregarProblemas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Alertas (Offline)')),
      body: _problemas.isEmpty
          ? const Center(child: Text('Nenhum dado salvo localmente.'))
          : ListView.builder(
        itemCount: _problemas.length,
        itemBuilder: (context, index) {
          final prob = _problemas[index];
          return ListTile(
            title: Text(prob.tipo, style: TextStyle(decoration: prob.resolvido ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
            subtitle: Text(prob.dataFormatada),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.check_circle, color: prob.resolvido ? Colors.green : Colors.grey), onPressed: () => _alternarResolvido(prob)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _excluirProblema(prob.id!)),
              ],
            ),
          );
        },
      ),
    );
  }
}