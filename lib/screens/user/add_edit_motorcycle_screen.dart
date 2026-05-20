import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/motorcycle_model.dart';
import '../../providers/motorcycle_provider.dart';

class AddEditMotorcycleScreen extends StatefulWidget {
  final MotorcycleModel? motorcycle;

  const AddEditMotorcycleScreen({super.key, this.motorcycle});

  @override
  State<AddEditMotorcycleScreen> createState() => _AddEditMotorcycleScreenState();
}

class _AddEditMotorcycleScreenState extends State<AddEditMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.motorcycle?.brand ?? '');
    _modelController = TextEditingController(text: widget.motorcycle?.model ?? '');
    _plateController = TextEditingController(text: widget.motorcycle?.plateNumber ?? '');
    _yearController = TextEditingController(text: widget.motorcycle?.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MotorcycleProvider>();
    bool success;

    if (widget.motorcycle == null) {
      success = await provider.addMotorcycle(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        plateNumber: _plateController.text.trim().toUpperCase(),
        year: int.tryParse(_yearController.text),
      );
    } else {
      final updated = MotorcycleModel(
        id: widget.motorcycle!.id,
        userId: widget.motorcycle!.userId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        plateNumber: _plateController.text.trim().toUpperCase(),
        year: int.tryParse(_yearController.text),
      );
      success = await provider.updateMotorcycle(updated);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Operation failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MotorcycleProvider>().isLoading;
    final isEdit = widget.motorcycle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom Branded AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9614C), // Retro Red
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2C1810),
                          offset: Offset(8, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF4EBD0)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              isEdit ? 'EDIT MACHINE' : 'ADD MACHINE',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: const Color(0xFFF4EBD0),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _brandController,
                            label: 'BRAND NAME',
                            icon: Icons.branding_watermark_rounded,
                            validator: (v) => v!.isEmpty ? 'Brand is required' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _modelController,
                            label: 'MODEL NAME',
                            icon: Icons.motorcycle_rounded,
                            validator: (v) => v!.isEmpty ? 'Model is required' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _plateController,
                            label: 'PLATE NUMBER',
                            icon: Icons.pin_rounded,
                            validator: (v) => v!.isEmpty ? 'Plate number is required' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _yearController,
                            label: 'MANUFACTURE YEAR',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9614C), // Retro Red
                                foregroundColor: const Color(0xFFF4EBD0),
                                disabledBackgroundColor: const Color(0xFFD9614C).withValues(alpha: 0.6),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFF2C1810), width: 4),
                                ),
                              ).copyWith(
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF2C1810),
                                      offset: Offset(8, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Color(0xFFF4EBD0),
                                        ),
                                      )
                                    : Text(
                                        isEdit ? 'UPDATE MACHINE' : 'REGISTER MACHINE',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C1810),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2C1810),
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C1810),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF2C1810)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2C1810), width: 4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2C1810), width: 4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD9614C), width: 4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 4),
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
