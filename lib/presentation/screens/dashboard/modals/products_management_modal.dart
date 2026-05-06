/// Modal para gestionar equipos (productos).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../providers/auth_provider.dart';

class ProductsManagementModal extends StatefulWidget {
  const ProductsManagementModal({super.key});

  @override
  State<ProductsManagementModal> createState() =>
      _ProductsManagementModalState();
}

class _ProductsManagementModalState extends State<ProductsManagementModal> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  final List<Map<String, dynamic>> _estados = const [
    {"idx": 0, "id": 1, "nombre": "disponible"},
    {"idx": 1, "id": 2, "nombre": "no_disponible"},
    {"idx": 2, "id": 3, "nombre": "inhabilitado"}
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prods = await _supabase
          .from('productos')
          .select()
          .order('fecha_registro', ascending: false);
      if (mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(prods);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForm([Map<String, dynamic>? product]) {
    final nameCtrl = TextEditingController(text: product?['nombre']);
    final descCtrl = TextEditingController(text: product?['descripcion']);
    int? selectedEstado =
        product?['id_estado'] ??
        (_estados.isNotEmpty ? _estados.first['id'] : null);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          product == null ? 'Nuevo Equipo' : 'Editar Equipo',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                dropdownColor: AppColors.surfaceLight,
                value: selectedEstado,
                items: _estados
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e['id'] as int,
                        child: Text(
                          e['nombre'].toString(),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setStateDialog(() => selectedEstado = val),
                decoration: InputDecoration(
                  labelText: 'Estado',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final adminId = auth.currentUser?.id;

              if (adminId == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error: No se pudo obtener el ID del administrador',
                      ),
                    ),
                  );
                }
                return;
              }

              final data = {
                'nombre': nameCtrl.text.trim(),
                'descripcion': descCtrl.text.trim(),
                'id_estado': selectedEstado,
                'id_administrador_p_cargo': adminId,
              };
              try {
                if (product == null) {
                  await _supabase.from('productos').insert(data);
                } else {
                  await _supabase
                      .from('productos')
                      .update(data)
                      .eq('id', product['id']);
                }
              } catch (e) {
                debugPrint('Error saving product: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar el equipo: $e')),
                  );
                }
              }
              if (mounted) {
                Navigator.pop(ctx);
                _loadData();
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUser?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el ID del administrador'),
        ),
      );
      return;
    }

    try {
      await _supabase.from('productos').delete().eq('id', id);
      _loadData();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el equipo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Gestionar Equipos',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryBlue),
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _products.isEmpty
          ? Center(
              child: Text(
                'No hay equipos registrados',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = _products[i];
                final estadoNombre = _estados.firstWhere(
                  (e) => e['id'] == p['id_estado'],
                  orElse: () => {'nombre': 'Desconocido'},
                )['nombre'];

                Color statusColor = AppColors.primaryBlue;
                if (p['id_estado'] == 1) statusColor = AppColors.success;
                if (p['id_estado'] == 2) statusColor = AppColors.warning;
                if (p['id_estado'] == 3) statusColor = AppColors.error;
                if (p['id_estado'] == 4) statusColor = AppColors.accentOrange;

                return NeonCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.videocam, color: statusColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['nombre'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p['descripcion'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                estadoNombre.toString().toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () => _showForm(p),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            onPressed: () => _deleteProduct(p['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
