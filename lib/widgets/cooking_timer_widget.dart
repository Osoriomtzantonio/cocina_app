import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════
// CookingTimerWidget — cronómetro de cuenta regresiva
//
// El usuario elige los minutos con + / - y luego inicia el timer.
// Muestra una barra de progreso circular y el tiempo restante.
// Al terminar muestra un mensaje y vibra (si el dispositivo lo soporta).
// ══════════════════════════════════════════════════════════════

class CookingTimerWidget extends StatefulWidget {
  const CookingTimerWidget({super.key});

  @override
  State<CookingTimerWidget> createState() => _CookingTimerWidgetState();
}

class _CookingTimerWidgetState extends State<CookingTimerWidget>
    with SingleTickerProviderStateMixin {

  // ── ESTADO ────────────────────────────────────────────────────────
  int  _minutosSeleccionados = 5;   // tiempo inicial por defecto
  int  _segundosRestantes    = 0;   // se asigna al iniciar
  bool _corriendo            = false;
  bool _terminado            = false;
  Timer? _timer;

  // Para la animación del progreso circular
  late AnimationController _animCtrl;
  late Animation<double>    _progreso;

  int get _totalSegundos => _minutosSeleccionados * 60;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = _totalSegundos;
    _animCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSegundos),
    );
    _progreso = Tween<double>(begin: 1.0, end: 0.0).animate(_animCtrl);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── INICIAR TIMER ─────────────────────────────────────────────────
  void _iniciar() {
    if (_corriendo) return;
    setState(() {
      _corriendo  = true;
      _terminado  = false;
      _segundosRestantes = _totalSegundos;
    });

    // Reiniciar animación
    _animCtrl.duration = Duration(seconds: _totalSegundos);
    _animCtrl.forward(from: 0.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundosRestantes <= 1) {
        t.cancel();
        setState(() {
          _segundosRestantes = 0;
          _corriendo         = false;
          _terminado         = true;
        });
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  // ── PAUSAR / REANUDAR ─────────────────────────────────────────────
  void _pausarReanudar() {
    if (_corriendo) {
      _timer?.cancel();
      _animCtrl.stop();
      setState(() => _corriendo = false);
    } else {
      _animCtrl.forward();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_segundosRestantes <= 1) {
          t.cancel();
          setState(() {
            _segundosRestantes = 0;
            _corriendo         = false;
            _terminado         = true;
          });
        } else {
          setState(() => _segundosRestantes--);
        }
      });
      setState(() => _corriendo = true);
    }
  }

  // ── REINICIAR ─────────────────────────────────────────────────────
  void _reiniciar() {
    _timer?.cancel();
    _animCtrl.reset();
    setState(() {
      _corriendo         = false;
      _terminado         = false;
      _segundosRestantes = _totalSegundos;
    });
  }

  // ── CAMBIAR MINUTOS ───────────────────────────────────────────────
  void _cambiarMinutos(int delta) {
    if (_corriendo) return;
    final nuevo = _minutosSeleccionados + delta;
    if (nuevo < 1 || nuevo > 120) return;
    setState(() {
      _minutosSeleccionados = nuevo;
      _segundosRestantes    = nuevo * 60;
      _terminado            = false;
    });
    _animCtrl.reset();
  }

  // ── FORMATO mm:ss ─────────────────────────────────────────────────
  String get _tiempoFormateado {
    final m = _segundosRestantes ~/ 60;
    final s = _segundosRestantes  % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── TÍTULO ────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text('Timer de cocina',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),

          const SizedBox(height: 20),

          // ── SELECTOR DE MINUTOS (solo cuando no está corriendo) ────
          if (!_corriendo && !_terminado)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBotonMinuto(-5,  '−5'),
                const SizedBox(width: 8),
                _buildBotonMinuto(-1,  '−1'),
                const SizedBox(width: 16),
                Text('$_minutosSeleccionados min',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                _buildBotonMinuto(1,  '+1'),
                const SizedBox(width: 8),
                _buildBotonMinuto(5,  '+5'),
              ],
            ),

          const SizedBox(height: 20),

          // ── RELOJ CIRCULAR ────────────────────────────────────────
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fondo gris
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    color: AppColors.grey200,
                  ),
                ),
                // Progreso animado
                AnimatedBuilder(
                  animation: _progreso,
                  builder: (_, __) => SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _corriendo || _terminado
                          ? _progreso.value
                          : 1.0,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: _terminado
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                // Tiempo en el centro
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _terminado ? '¡Listo!' : _tiempoFormateado,
                      style: TextStyle(
                        fontSize: _terminado ? 22 : 32,
                        fontWeight: FontWeight.bold,
                        color: _terminado
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (_terminado)
                      const Text('⏰',
                          style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── BOTONES DE CONTROL ────────────────────────────────────
          if (_terminado)
            // Solo botón reiniciar cuando termina
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(Icons.replay),
                label: const Text('Nuevo timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            Row(
              children: [
                // Botón iniciar o pausar/reanudar
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _corriendo ? _pausarReanudar : _iniciar,
                    icon: Icon(
                      _corriendo ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(
                      _corriendo ? 'Pausar' : 'Iniciar',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_corriendo || _segundosRestantes < _totalSegundos) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _reiniciar,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.replay,
                        color: AppColors.primary),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // ── BOTÓN PARA CAMBIAR MINUTOS ────────────────────────────────────
  Widget _buildBotonMinuto(int delta, String etiqueta) {
    return GestureDetector(
      onTap: () => _cambiarMinutos(delta),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          etiqueta,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
