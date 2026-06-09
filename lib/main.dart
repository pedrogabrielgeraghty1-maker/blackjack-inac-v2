import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackjack INAC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BlackjackInacScreen(),
    );
  }
}

class BlackjackInacScreen extends StatefulWidget {
  const BlackjackInacScreen({super.key});

  @override
  State<BlackjackInacScreen> createState() => _BlackjackInacScreenState();
}

class _BlackjackInacScreenState extends State<BlackjackInacScreen> {
  int saldo = 1000;
  int apuestaActual = 0;
  bool apuestaConfirmada = false;
  bool juegoTerminado = false;
  int puntosJugador = 15;
  int puntosDealer = 10;
  int premioRecibido = 0;

  void agregarFicha(int valor) {
    if (apuestaConfirmada) return;
    if (saldo >= valor && (apuestaActual + valor) <= 1000) {
      setState(() {
        apuestaActual += valor;
        saldo -= valor;
      });
    }
  }

  void deshacerApuesta() {
    if (apuestaConfirmada) return;
    setState(() {
      saldo += apuestaActual;
      apuestaActual = 0;
    });
  }

  void confirmarApuesta() {
    if (apuestaActual >= 10) {
      setState(() {
        apuestaConfirmada = true;
        juegoTerminado = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050B1A), Color(0xFF101F42)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado: Logo y Saldo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.style, color: Colors.red, size: 30),
                        SizedBox(width: 8),
                        Text(
                          'BLACKJACK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF162A54),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        '\$$saldo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Zona Central Dinámica (Cambia según el estado del juego)
              if (!apuestaConfirmada) ...[
                // PANTALLA 1: HAZ TU APUESTA
                const Text(
                  '═ HAZ TU APUESTA ═',
                  style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                // Fichas de apuestas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.reply, color: Colors.grey),
                      onPressed: deshacerApuesta,
                    ),
                    _buildFicha(1, Colors.grey.shade300, Colors.black),
                    _buildFicha(5, Colors.red, Colors.white),
                    _buildFicha(10, Colors.blue, Colors.white),
                    _buildFicha(20, Colors.yellow.shade700, Colors.black),
                    _buildFicha(25, Colors.green, Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$$apuestaActual',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Mínimo: \$10 | Máximo: \$1,000',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: confirmarApuesta,
                  child: const Text('LISTO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                // Fondo de Hangar (.png)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/hangar_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ] else if (apuestaConfirmada && !juegoTerminado) ...[
                // PANTALLA 2: TU DECISIÓN
                const Text(
                  'BLACKJACK PAYS 3 TO 2\nDealer must draw to 16 and stand on all 17s',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                ),
                const Spacer(),
                const Text(
                  'TU DECISIÓN',
                  style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBotonAccion(Icons.lightbulb_outline, 'ESTRATEGIA'),
                    _buildBotonAccion(Icons.looks_two, 'DOBLAR'),
                    _buildBotonAccion(Icons.add_circle_outline, 'PEDIR'),
                    _buildBotonAccion(Icons.stop_circle_outlined, 'PLANTARSE'),
                    _buildBotonAccion(Icons.flag_outlined, 'RENDIRSE'),
                  ],
                ),
                const Spacer(),
                // Cartas en juego y Avión de fondo (.png)
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/airplane_sky.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 40,
                        child: Row(
                          children: [
                            _buildCarta('Q', 'S'),
                            const SizedBox(width: 8),
                            _buildCarta('5', 'D'),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(10)),
                          child: Text('$puntosJugador', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // PANTALLA 3: RESULTADO FINAL (PERDIÓ / GANÓ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        _buildCarta('K', 'H'),
                        _buildCarta('9', 'H'),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                          child: const Text('PIERDE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('HAS RECIBIDO:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('\$$premioRecibido', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Tu apuesta total: \$$apuestaActual', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          const Text('Toca en cualquier parte\npara continuar...', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                        ],
                      ),
                    )
                  ],
                ),
                const Spacer(),
              ],

              const Spacer(),

              // Footer Institucional INAC CIATA
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                color: Colors.black.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'INAC CIATA',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.flight_takeoff, color: Colors.grey, size: 16),
                    ),
                    Text(
                      'VOLAR ES NUESTRO DESTINO',
                      style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFicha(int valor, Color fondo, Color texto) {
    return GestureDetector(
      onTap: () => agregarFicha(valor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: fondo,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: fondo,
            child: Text(
              '$valor',
              style: TextStyle(color: texto, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonAccion(IconData icono, String etiqueta) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF1E293B),
          child: Icon(icono, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          etiqueta,
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCarta(String valor, String palo) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
      ),
      child: Center(
        child: Text(
          valor,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}