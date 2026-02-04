import 'package:flutter/material.dart';
import '../../../models/course.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class AddCourseDialog extends StatefulWidget {
  final String initialName;
  const AddCourseDialog({super.key, this.initialName = ''});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _teeNameController;
  late TextEditingController _slopeController;
  late TextEditingController _ratingController;
  late List<TextEditingController> _parsControllers;
  late List<TextEditingController> _siControllers;
  late List<TextEditingController> _yardagesControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _addressController = TextEditingController();
    _teeNameController = TextEditingController(text: 'Standard');
    _slopeController = TextEditingController(text: '113');
    _ratingController = TextEditingController(text: '72.0');
    _parsControllers = List.generate(18, (i) => TextEditingController(text: '4'));
    _siControllers = List.generate(18, (i) => TextEditingController(text: (i + 1).toString()));
    _yardagesControllers = List.generate(18, (i) => TextEditingController(text: '0'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _teeNameController.dispose();
    _slopeController.dispose();
    _ratingController.dispose();
    for (var c in _parsControllers) {
      c.dispose();
    }
    for (var c in _siControllers) {
      c.dispose();
    }
    for (var c in _yardagesControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Course'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BoxyArtFormField(label: 'Course Name', controller: _nameController),
            const SizedBox(height: 16),
            BoxyArtFormField(label: 'Location / Address', controller: _addressController, maxLines: 2),
            const SizedBox(height: 16),
            BoxyArtFormField(label: 'Tee Position Name (e.g. White, Yellow)', controller: _teeNameController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: BoxyArtFormField(label: 'Slope', controller: _slopeController, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: BoxyArtFormField(label: 'Rating', controller: _ratingController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Hole Details (Par, SI, Yardage)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 18,
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    Text('Hole ${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _parsControllers[i],
                        decoration: const InputDecoration(hintText: 'Par', isDense: true, border: OutlineInputBorder()),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _siControllers[i],
                        decoration: const InputDecoration(hintText: 'SI', isDense: true, border: OutlineInputBorder()),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _yardagesControllers[i],
                        decoration: const InputDecoration(hintText: 'Yds', isDense: true, border: OutlineInputBorder()),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.isEmpty) return;
    
    final teeConfig = TeeConfig(
      name: _teeNameController.text.trim(),
      rating: double.tryParse(_ratingController.text) ?? 72.0,
      slope: int.tryParse(_slopeController.text) ?? 113,
      holePars: _parsControllers.map((c) => int.tryParse(c.text) ?? 4).toList(),
      holeSIs: _siControllers.map((c) => int.tryParse(c.text) ?? 1).toList(),
      yardages: _yardagesControllers.map((c) => int.tryParse(c.text) ?? 0).toList(),
    );

    final course = Course(
      id: '', // Firestore will assign
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      tees: [teeConfig],
      isGlobal: true,
    );

    Navigator.of(context).pop(course);
  }
}
