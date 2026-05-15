library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/widgets/neon_text_field.dart';
import '../../providers/auth_provider.dart';

class AdditionalUserDataScreen extends StatefulWidget {
  const AdditionalUserDataScreen({super.key});

  @override
  State<AdditionalUserDataScreen> createState() =>
      _AdditionalUserDataScreenState();
}

class _AdditionalUserDataScreenState extends State<AdditionalUserDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _profileController = TextEditingController();

  String? _selectedCareer;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  // State for dynamic career dropdown and neon indicator
  bool _isCareerDropdownEnabled = false;
  bool _isStudentRole = false;
  bool _isSaveButtonDisabled = false;

  final List<String> _careers = [
    'Ingeniería de Sistemas',
    'Ingeniería Civil',
    'Ingeniería Agroindustrial',
    'ADS',
    'Enfermería',
    'Ingeniería Mecánica',
    'Ingeniería Agronómica',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    // Listen to changes in the profile/role field
    _profileController.addListener(_onProfileRoleChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  /// Detects changes in the profile/role input in real-time
  void _onProfileRoleChanged() {
    final currentText = _profileController.text.trim().toLowerCase();
    final isStudent = currentText == 'estudiante';

    if (isStudent != _isStudentRole) {
      setState(() {
        _isStudentRole = isStudent;
        _isCareerDropdownEnabled = isStudent;
        
        // If not a student, clear the career selection
        if (!isStudent) {
          _selectedCareer = null;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate format (jpg/png/jpeg)
        final ext = pickedFile.name.toLowerCase();
        if (!ext.endsWith('.jpg') &&
            !ext.endsWith('.jpeg') &&
            !ext.endsWith('.png')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solo se permiten formatos JPG y PNG'),
              ),
            );
          }
          return;
        }

        // Compress image
        final dir = await getTemporaryDirectory();
        final targetPath =
            '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final XFile? compressedFile =
            await FlutterImageCompress.compressAndGetFile(
              pickedFile.path,
              targetPath,
              quality: 70,
              minWidth: 400,
              minHeight: 400,
            );

        if (compressedFile != null) {
          final size = await compressedFile.length();
          // Restricción de Tamaño: 2MB máximo después de compresión
          if (size > 2 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La imagen es demasiado grande (máx 2MB)'),
                ),
              );
            }
            return;
          }

          setState(() {
            _imageFile = File(compressedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la imagen: $e')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, sube una foto de rostro obligatoria'),
        ),
      );
      return;
    }

    if (_selectedCareer == null && _profileController.text.trim() == 'estudiante') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una carrera')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    String uploadedPhotoUrl = '';

    // Subir la imagen a Supabase Storage
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && _imageFile != null) {
        // 1. Definimos el nombre del archivo
        final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";

        // 2. CONCATENAMOS: El RLS exige que el primer nivel sea el UID
        final path = "${user.id}/$fileName";

        await Supabase.instance.client.storage
            .from('profile-photos')
            .upload(path, _imageFile!);

        uploadedPhotoUrl = Supabase.instance.client.storage
            .from('profile-photos')
            .getPublicUrl(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
      return; // Stop if upload fails
    }

    final success = await auth.saveAdditionalData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      role: 'usuario',
      career: _selectedCareer ?? '',
      profile: _profileController.text.trim(),
      photoUrl: uploadedPhotoUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados exitosamente. Tu cuenta está pendiente de aprobación.'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Disable the save button to prevent multiple submissions
      setState(() {
        _isSaveButtonDisabled = true;
      });
      
      // Navigate to waiting approval screen
      if (mounted) {
        context.go('/waiting');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al guardar los datos'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Completar Perfil',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Para terminar tu registro, necesitamos algunos datos adicionales.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _imageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.primaryBlue,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Añadir foto',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: NeonCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NeonTextField(
                          controller: _firstNameController,
                          label: 'Primer Nombre',
                          hint: 'Ej: Juan',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        NeonTextField(
                          controller: _lastNameController,
                          label: 'Primer Apellido',
                          hint: 'Ej: Pérez',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carrera / Programa',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: _isCareerDropdownEnabled 
                                    ? AppColors.surfaceLight 
                                    : AppColors.surfaceLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isCareerDropdownEnabled
                                      ? AppColors.primaryBlue.withValues(alpha: 0.5)
                                      : AppColors.border.withValues(alpha: 0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedCareer,
                                  hint: Text(
                                    'Selecciona una carrera',
                                    style: GoogleFonts.inter(
                                      color: _isCareerDropdownEnabled
                                          ? AppColors.textTertiary
                                          : AppColors.textTertiary.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  items: _isCareerDropdownEnabled
                                      ? _careers.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: GoogleFonts.inter(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          );
                                        }).toList()
                                      : [],
                                  onChanged: _isCareerDropdownEnabled
                                      ? (newValue) {
                                          setState(() {
                                            _selectedCareer = newValue;
                                          });
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            if (!_isCareerDropdownEnabled) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Opción solo para estudiantes',
                                style: GoogleFonts.inter(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isStudentRole
                                ? [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.6),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ]
                                : [],
                          ),
                          child: NeonTextField(
                            controller: _profileController,
                            label: 'Perfil / Rol',
                            hint: 'Ej: estudiante, docente, coordinador-docente',
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) => NeonButton(
                      text: 'Guardar Datos',
                      onPressed: _isSaveButtonDisabled ? null : _handleSave,
                      isLoading: auth.isLoading,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
