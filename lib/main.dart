import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blackjack INAC Pro',
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: const BlackjackGame(),
    );
  }
}

class BlackjackGame extends StatefulWidget {
  const BlackjackGame({Key? key}) : super(key: key);

  @override
  State<BlackjackGame> createState() => _BlackjackGameState();
}

class _BlackjackGameState extends State<BlackjackGame> {
  // VARIABLES DE ESTADO REALES
  String pantallaActual = 'MENU'; // MENU, APUESTA, JUEGO, FIN
  int credits = 1000;
  int bet = 0;
  List<int> playerValues = [];
  List<int> dealerValues = [];
  String resultMessage = '';
  bool juegoTerminado = false;

  // RUTAS DE IMÁGENES SEGURAS
  static const String assetBase = '/assets/images/';
  final String fondoHangar = assetBase + 'hangar.png'; 
  final String cardBack = assetBase + 'carta_tapada.png';

  // Mapeo para simular cartas reales (As, cartas numéricas, y figuras)
  final List<int> mazo = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11];

  int calcularPuntos(List<int> mano) {
    int total = mano.fold(0, (sum, item) => sum + item);
    int aces = mano.where((v) => v == 11).length;
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    return total;
  }

  void iniciarApuesta() => setState(() => pantallaActual = 'APUESTA');

  void comenzarJuego(int cantidadApostada) {
    if (cantidadApostada > credits) return;
    setState(() {
      bet = cantidadApostada;
      credits -= cantidadApostada;
      juegoTerminado = false;
      
      // Repartir cartas iniciales (valores numéricos aleatorios)
      playerValues = [_sacarCarta(), _sacarCarta()];
      dealerValues = [_sacarCarta(), _sacarCarta()];
      
      pantallaActual = 'JUEGO';
      
      if (calcularPuntos(playerValues) == 21) {
        evaluarGanador();
      }
    });
  }

  int _sacarCarta() {
    final random = Random();
    return mazo[random.nextInt(mazo.length)];
  }

  // BOTÓN PEDIR
  void playerHit() {
    if (juegoTerminado) return;
    setState(() {
      playerValues.add(_sacarCarta());
      if (calcularPuntos(playerValues) > 21) {
        juegoTerminado = true;
        pantallaActual = 'FIN';
        resultMessage = '¡Te pasaste! Perdiste \$$bet';
      }
    });
  }

  // BOTÓN REDOBLAR (Double Down)
  void playerDoubleDown() {
    if (juegoTerminado || credits < bet) return;
    setState(() {
      credits -= bet; // Restamos la misma cantidad otra vez
      bet *= 2;       // Duplicamos la apuesta
      playerValues.add(_sacarCarta()); // Recibe una Sola carta más
      juegoTerminado = true;
      
      if (calcularPuntos(playerValues) > 21) {
        pantallaActual = 'FIN';
        resultMessage = '¡Te pasaste al redoblar! Perdiste \$$bet';
      } else {
        _turnoDeLaBanca();
      }
    });
  }

  // BOTÓN PLANTARSE
  void playerStand() {
    if (juegoTerminado) return;
    _turnoDeLaBanca();
  }

  void _turnoDeLaBanca() {
    setState(() {
      juegoTerminado = true;
      // La banca pide carta obligao hasta tener 17 o más
      while (calcularPuntos(dealerValues) < 17) {
        dealerValues.add(_sacarCarta());
      }
      evaluarGanador();
    });
  }

  void evaluarGanador() {
    int puntosJugador = calcularPuntos(playerValues);
    int puntosBanca = calcularPuntos(dealerValues);

    setState(() {
      pantallaActual = 'FIN';
      if (puntosJugador > 21) {
        resultMessage = 'Perdiste \$$bet';
      } else if (puntosBanca > 21) {
        resultMessage = '¡La banca se pasó! Ganaste \$$bet';
        credits += bet * 2;
      } else if (puntosJugador > puntosBanca) {
        resultMessage = '¡Ganaste! +\$$bet';
        credits += bet * 2;
      } else if (puntosJugador < puntosBanca) {
        resultMessage = 'Perdiste \$$bet';
      } else {
        resultMessage = 'Empate (Devolución)';
        credits += bet;
      }
    });
  }

  void reiniciarJuego() => setState(() { pantallaActual = 'MENU'; bet = 0; playerValues.clear(); dealerValues.clear(); });

  // TRADUCTOR DE VALOR A NOMBRE DE ARCHIVO PNG
  String _obtenerRutaCarta(int valor, bool esBanca, int indice) {
    if (esBanca && !juegoTerminado && indice == 0) {
      return cardBack; // Muestra carta tapada si la banca no jugó
    }
    // Mapeo simple de tus nombres de archivos según el valor extraído
    if (valor == 11 || valor == 1) return assetBase + 'as_espadas.png';
    if (valor == 10) return assetBase + 'rey_basto.png';
    return assetBase + 'cinco_oro.png'; // Comodín para valores chicos
  }

  ButtonStyle proButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0D47A1),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget safeImage(String path, {double height = 110}) {
    return Image.asset(
      path,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Card(
          color: Colors.grey.shade900,
          child: SizedBox(
            height: height,
            width: height * 0.7,
            child: const Center(
              child: Text('🃏', style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(fondoHangar), fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.55),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _construirPantalla(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirPantalla() {
    switch (pantallaActual) {
      case 'MENU': return _pantallaMenu();
      case 'APUESTA': return _pantallaApuesta();
      case 'JUEGO': return _pantallaJuego();
      case 'FIN': return _pantallaFin();
      default: return _pantallaMenu();
    }
  }

  Widget _pantallaMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('BLACKJACK INAC', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Text('Simulador de Vuelo v2', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
        const SizedBox(height: 50),
        ElevatedButton(onPressed: iniciarApuesta, style: proButtonStyle(), child: const Text('INGRESAR AL HANGAR')),
      ],
    );
  }

  Widget _pantallaApuesta() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('CRÉDITOS: \$$credits', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        const Text('CANTIDAD A APOSTAR', style: TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: credits >= 100 ? () => comenzarJuego(100) : null, style: proButtonStyle(), child: const Text('\$100')),
            const SizedBox(width: 15),
            ElevatedButton(onPressed: credits >= 500 ? () => comenzarJuego(500) : null, style: proButtonStyle(), child: const Text('\$500')),
          ],
        ),
      ],
    );
  }

  Widget _pantallaJuego() {
    int pJugador = calcularPuntos(playerValues);
    int pBanca = juegoTerminado ? calcularPuntos(dealerValues) : calcularPuntos([dealerValues[1]]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('APUESTA EN CURSO: \$$bet', style: const TextStyle(fontSize: 20, color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // BANCA
        Text('BANCA (Puntos: $pBanca)', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dealerValues.asMap().entries.map((entry) {
            return safeImage(_obtenerRutaCarta(entry.value, true, entry.key));
          }).toList(),
        ),
        
        const SizedBox(height: 30),
        
        // JUGADOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: playerValues.asMap().entries.map((entry) {
            return safeImage(_obtenerRutaCarta(entry.value, false, entry.key));
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text('TU MANO (Puntos: $pJugador)', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
        
        const SizedBox(height: 40),

        // PANEL DE ACCIONES AJUSTADO
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(onPressed: playerHit, style: proButtonStyle(), child: const Text('PEDIR')),
            ElevatedButton(
              onPressed: (credits >= bet) ? playerDoubleDown : null, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white), 
              child: const Text('REDOBLAR'),
            ),
            ElevatedButton(onPressed: playerStand, style: proButtonStyle(), child: const Text('PLANTARSE')),
            ElevatedButton(
              onPressed: reiniciarJuego, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900, foregroundColor: Colors.white), 
              child: const Text('RETIRARSE'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pantallaFin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(resultMessage, style: const TextStyle(fontSize: 32, color: Colors.yellowAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 15),
        Text('Mano Jugador: ${calcularPuntos(playerValues)} vs Banca: ${calcularPuntos(dealerValues)}', style: const TextStyle(fontSize: 16, color: Colors.white60)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: reiniciarJuego, style: proButtonStyle(), child: const Text('VOLVER AL MENU')),
      ],
    );
  }
}