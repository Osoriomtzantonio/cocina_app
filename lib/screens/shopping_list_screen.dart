import 'package:flutter/material.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════
// ShoppingListScreen — lista de compras con checkboxes
//
// Los ítems se agregan desde RecipeDetailScreen.
// El usuario puede marcar, desmarcar y eliminar ítems.
// ══════════════════════════════════════════════════════════════

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _service = ShoppingListService();

  List<ShoppingItem> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final items = await _service.obtenerLista();
    if (mounted) setState(() { _items = items; _cargando = false; });
  }

  // ── MARCAR/DESMARCAR ─────────────────────────────────────────────
  Future<void> _toggle(int index) async {
    await _service.toggleComprado(index);
    _cargar();
  }

  // ── ELIMINAR ÍTEM ─────────────────────────────────────────────────
  Future<void> _eliminar(int index) async {
    await _service.eliminarItem(index);
    _cargar();
  }

  // ── LIMPIAR COMPRADOS ─────────────────────────────────────────────
  Future<void> _limpiarComprados() async {
    final comprados = _items.where((i) => i.comprado).length;
    if (comprados == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ítems marcados como comprados')),
      );
      return;
    }
    await _service.limpiarComprados();
    _cargar();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$comprados ítem${comprados != 1 ? "s" : ""} eliminado${comprados != 1 ? "s" : ""}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  // ── LIMPIAR TODO ──────────────────────────────────────────────────
  Future<void> _limpiarTodo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar lista'),
        content: const Text('¿Eliminar todos los ingredientes de la lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar todo',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _service.limpiarTodo();
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separamos comprados de pendientes para mostrar los pendientes primero
    final pendientes = _items.where((i) => !i.comprado).toList();
    final comprados  = _items.where((i) =>  i.comprado).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _items.isEmpty
              ? 'Lista de compras'
              : 'Lista (${pendientes.length} pendiente${pendientes.length != 1 ? "s" : ""})',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (v) {
                if (v == 'comprados') _limpiarComprados();
                if (v == 'todo')      _limpiarTodo();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'comprados',
                  child: Row(children: [
                    Icon(Icons.done_all, size: 18),
                    SizedBox(width: 8),
                    Text('Limpiar comprados'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'todo',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar todo',
                        style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _items.isEmpty
              ? _buildVacia()
              : _buildLista(pendientes, comprados),
    );
  }

  // ── LISTA CON SECCIONES ───────────────────────────────────────────
  Widget _buildLista(
      List<ShoppingItem> pendientes, List<ShoppingItem> comprados) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [

        // ── SECCIÓN PENDIENTES ────────────────────────────────────
        if (pendientes.isNotEmpty) ...[
          _buildEncabezadoSeccion(
              '${pendientes.length} por comprar', AppColors.primary),
          const SizedBox(height: 8),
          ...pendientes.map((item) {
            final index = _items.indexOf(item);
            return _buildItemCard(item, index);
          }),
        ],

        // ── SECCIÓN COMPRADOS ─────────────────────────────────────
        if (comprados.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildEncabezadoSeccion(
              '${comprados.length} comprado${comprados.length != 1 ? "s" : ""}',
              AppColors.textSecondary),
          const SizedBox(height: 8),
          ...comprados.map((item) {
            final index = _items.indexOf(item);
            return _buildItemCard(item, index);
          }),
        ],
      ],
    );
  }

  // ── ENCABEZADO DE SECCIÓN ─────────────────────────────────────────
  Widget _buildEncabezadoSeccion(String titulo, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── TARJETA DE ÍTEM ───────────────────────────────────────────────
  Widget _buildItemCard(ShoppingItem item, int index) {
    return Dismissible(
      key: Key('$index-${item.nombre}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _eliminar(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.comprado
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: item.comprado
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          // Checkbox personalizado con color naranja
          leading: GestureDetector(
            onTap: () => _toggle(index),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.comprado ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.comprado
                      ? AppColors.primary
                      : AppColors.grey200,
                  width: 2,
                ),
              ),
              child: item.comprado
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            item.nombre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: item.comprado
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: item.comprado
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: item.cantidad.isNotEmpty
              ? Text(
                  item.cantidad,
                  style: TextStyle(
                    fontSize: 12,
                    color: item.comprado
                        ? AppColors.textHint
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: Icon(Icons.close,
                size: 18,
                color: item.comprado
                    ? AppColors.textHint
                    : AppColors.textSecondary),
            onPressed: () => _eliminar(index),
          ),
          onTap: () => _toggle(index),
        ),
      ),
    );
  }

  // ── LISTA VACÍA ───────────────────────────────────────────────────
  Widget _buildVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Tu lista está vacía',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8),
          Text(
            'Abre una receta y toca\n"Agregar a lista de compras"',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}
