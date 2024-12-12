import 'package:flutter/material.dart';
import '../models/export_settings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ExportSettingsDialog extends StatefulWidget {
  final String title;
  final Widget chart;
  final ExportSettings initialSettings;

  const ExportSettingsDialog({
    Key? key,
    required this.title,
    required this.chart,
    required this.initialSettings,
  }) : super(key: key);

  @override
  State<ExportSettingsDialog> createState() => _ExportSettingsDialogState();
}

class _ExportSettingsDialogState extends State<ExportSettingsDialog> {
  late ExportSettings settings;
  final GlobalKey previewKey = GlobalKey();
  String? exportPath;
  final TextEditingController _fileNameController = TextEditingController();
  String _fileName = '';
  final List<String> _formatOptions = ['PNG', 'JPG'];

  @override
  void initState() {
    super.initState();
    settings = widget.initialSettings.copyWith(
      quality: 3.0,
      width: 1920,
      height: 1080,
    );
    _fileName = widget.title.replaceAll(' ', '_').toLowerCase();
    _fileNameController.text = _fileName;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1000,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exportar ${widget.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDimensionsSection(),
                          const Divider(),
                          _buildFileNameSection(),
                          const Divider(),
                          _buildStyleSection(),
                          const Divider(),
                          _buildFormatSection(),
                          const Divider(),
                          _buildLocationSection(),
                          const Divider(),
                          _buildQualitySection(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const Text(
                          'Previsualización',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPreview(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (settings.exportPath != null && _fileName.isNotEmpty) {
                      final fileName = _fileName.endsWith('.${settings.format.toLowerCase()}') 
                          ? _fileName 
                          : '$_fileName.${settings.format.toLowerCase()}';
                          
                      final fullSettings = settings.copyWith(
                        customTitle: fileName,
                      );
                      
                      Navigator.of(context).pop(fullSettings);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingrese un nombre de archivo y seleccione una ubicación'),
                        ),
                      );
                    }
                  },
                  child: const Text('Exportar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre del archivo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del archivo',
            hintText: 'Ingrese el nombre del archivo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.file_present),
          ),
          onChanged: (value) {
            setState(() {
              _fileName = value;
            });
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Extensión: .${settings.format.toLowerCase()}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showColorPicker({
    required Color initialColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dimensiones',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildPresetButton('HD', 1280, 720),
            _buildPresetButton('Full HD', 1920, 1080),
            _buildPresetButton('4K', 3840, 2160),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Ancho',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: settings.width.toString()),
                onChanged: (value) => _updateSettings(
                  width: double.tryParse(value) ?? settings.width,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Alto',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: settings.height.toString()),
                onChanged: (value) => _updateSettings(
                  height: double.tryParse(value) ?? settings.height,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estilo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Color de fondo
        Row(
          children: [
            const Text('Color de fondo'),
            const SizedBox(width: 16), // Espaciado ajustable
            InkWell(
              onTap: () => _showColorPicker(
                initialColor: settings.backgroundColor,
                onColorChanged: (color) => setState(() {
                  settings = settings.copyWith(backgroundColor: color);
                }),
              ),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: settings.backgroundColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Spacer(), // Esto empujará el resto del contenido hacia la derecha
          ],
        ),
        const SizedBox(height: 8),
        // Borde
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Incluir borde'),
          value: settings.includeBorder,
          onChanged: (value) => _updateSettings(includeBorder: value),
        ),
        if (settings.includeBorder) ...[
          // Color del borde
          Row(
            children: [
              const Text('Color del borde'),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _showColorPicker(
                  initialColor: settings.borderColor,
                  onColorChanged: (color) => setState(() {
                    settings = settings.copyWith(borderColor: color);
                  }),
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.borderColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          // Ancho del borde
          Row(
            children: [
              const Text('Ancho del borde'),
              Expanded(
                child: Slider(
                  value: settings.borderWidth,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  label: settings.borderWidth.toString(),
                  onChanged: (value) => _updateSettings(borderWidth: value),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formato',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: settings.format,
          decoration: const InputDecoration(
            labelText: 'Formato',
          ),
          items: _formatOptions.map((format) {
            return DropdownMenuItem(
              value: format,
              child: Text(format),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                settings = settings.copyWith(format: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, double width, double height) {
    return OutlinedButton(
      onPressed: () => _updateSettings(width: width, height: height),
      child: Text(label),
    );
  }

  void _updateSettings({
    double? width,
    double? height,
    double? quality,
    bool? includeBorder,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    String? format,
    EdgeInsets? padding,
    String? customTitle,
    String? watermarkText,
  }) {
    setState(() {
      settings = settings.copyWith(
        width: width,
        height: height,
        quality: quality,
        includeBorder: includeBorder,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        format: format,
        padding: padding,
        customTitle: customTitle,
        watermarkText: watermarkText,
      );
    });
  }

  Widget _buildPreview() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 400,
      ),
      width: 450,
      height: 350,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: settings.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: settings.includeBorder 
            ? Border.all(
                color: settings.borderColor,
                width: settings.borderWidth,
              ) 
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Padding(
              padding: settings.padding,
              child: widget.chart,
            ),
            if (settings.showCustomTitle && settings.customTitle?.isNotEmpty == true)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    settings.customTitle!,
                    style: TextStyle(
                      fontSize: settings.titleFontSize * 0.7,
                      fontWeight: FontWeight.bold,
                      color: settings.titleColor,
                    ),
                  ),
                ),
              ),
            if (settings.showWatermark && settings.watermarkText?.isNotEmpty == true)
              Positioned(
                bottom: 8,
                right: 8,
                child: Opacity(
                  opacity: settings.watermarkOpacity,
                  child: Transform.rotate(
                    angle: -3.14159 / 6,
                    child: Text(
                      settings.watermarkText!,
                      style: TextStyle(
                        fontSize: settings.watermarkFontSize * 0.7,
                        color: settings.watermarkColor,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                exportPath ?? 'No seleccionado',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _selectExportLocation,
              icon: const Icon(Icons.folder),
              label: const Text('Cambiar'),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Future<void> _selectExportLocation() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Seleccionar carpeta de exportación',
    );
    
    if (selectedDirectory != null) {
      setState(() {
        exportPath = selectedDirectory;
        settings = settings.copyWith(exportPath: selectedDirectory);
      });
    }
  }

  Widget _buildQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calidad de Exportación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: settings.quality,
          min: 1.0,
          max: 4.0,
          divisions: 6,
          label: '${settings.quality}x',
          onChanged: (value) {
            setState(() {
              settings = settings.copyWith(quality: value);
            });
          },
        ),
        const Text('Mayor calidad = archivo más grande',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
} 