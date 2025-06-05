import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/gadget.dart';

class GadgetFormPage extends StatefulWidget {
  final Gadget? gadget;
  final Function(Gadget) onSubmit;

  const GadgetFormPage({super.key, this.gadget, required this.onSubmit});

  @override
  State<GadgetFormPage> createState() => _GadgetFormPageState();
}

class _GadgetFormPageState extends State<GadgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _merkController;
  late TextEditingController _colorController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;
  late TextEditingController _generationController;
  late TextEditingController _screenSizeController;
  late TextEditingController _hardDiskSizeController;

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gadget?.name ?? '');
    _merkController = TextEditingController(text: widget.gadget?.data['merk'] ?? '');
    _colorController = TextEditingController(text: widget.gadget?.data['color'] ?? '');
    _capacityController = TextEditingController(text: widget.gadget?.data['capacity'] ?? '');
    _priceController = TextEditingController(text: widget.gadget?.data['price']?.toString() ?? '');
    _generationController = TextEditingController(text: widget.gadget?.data['generation'] ?? '');
    _screenSizeController = TextEditingController(text: widget.gadget?.data['screen_size'] ?? '');
    _hardDiskSizeController = TextEditingController(text: widget.gadget?.data['hard_disk_size'] ?? '');

    if (widget.gadget?.imagePath != null && widget.gadget!.imagePath!.isNotEmpty) {
      _pickedImage = File(widget.gadget!.imagePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _merkController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _generationController.dispose();
    _screenSizeController.dispose();
    _hardDiskSizeController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (photo != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(photo.path);
      final savedImage = await File(photo.path).copy('${appDir.path}/$fileName');
      setState(() {
        _pickedImage = savedImage;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final newGadget = Gadget(
        id: widget.gadget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        data: {
          'merk': _merkController.text,
          'color': _colorController.text,
          'capacity': _capacityController.text,
          'price': _priceController.text,
          'generation': _generationController.text,
          'screen_size': _screenSizeController.text,
          'hard_disk_size': _hardDiskSizeController.text,
        },
        imagePath: _pickedImage?.path,
      );
      // Simpan ke Hive
      final box = await Hive.openBox<Gadget>('gadgets');
      await box.add(newGadget);
      widget.onSubmit(newGadget);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.grey.withAlpha((0.05 * 255).round()),
        ),
        validator: requiredField
            ? (value) => value == null || value.isEmpty ? '$label wajib diisi' : null
            : null,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gadget == null ? 'Tambah Gadget' : 'Edit Gadget'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withAlpha((0.12 * 255).round()), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pickedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor
                        ),
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: _nameController,
                        label: 'Nama Gadget *',
                        icon: Icons.devices,
                        requiredField: true,
                      ),
                      _field(
                        controller: _merkController,
                        label: 'Merk',
                        icon: Icons.badge,
                      ),
                      _field(
                        controller: _colorController,
                        label: 'Color',
                        icon: Icons.color_lens,
                      ),
                      _field(
                        controller: _capacityController,
                        label: 'Capacity',
                        icon: Icons.sd_storage,
                      ),
                      _field(
                        controller: _priceController,
                        label: 'Price',
                        icon: Icons.price_change,
                        keyboardType: TextInputType.number,
                      ),
                      _field(
                        controller: _generationController,
                        label: 'Generation',
                        icon: Icons.timeline,
                      ),
                      _field(
                        controller: _screenSizeController,
                        label: 'Screen Size',
                        icon: Icons.straighten,
                      ),
                      _field(
                        controller: _hardDiskSizeController,
                        label: 'Hard Disk Size',
                        icon: Icons.storage,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _submit,
                          label: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}