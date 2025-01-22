import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/chart_data.dart';

class ChartDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? initialData;

  const ChartDialog({
    Key? key,
    required this.title,
    this.initialData,
  }) : super(key: key);

  @override
  State<ChartDialog> createState() => _ChartDialogState();
}

class _ChartDialogState extends State<ChartDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late List<Color> _colors;
  late List<Map<String, dynamic>> _dataPoints;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final initialData = widget.initialData;
    _selectedType = initialData?['type'] ?? 'line';
    _colors = (initialData?['colors'] as List<Color>?) ?? 
              [Colors.blue, Colors.green, Colors.red, Colors.orange];
    _dataPoints = List<Map<String, dynamic>>.from(
      initialData?['dataPoints'] ?? []
    );
    _titleController = TextEditingController(text: widget.title);
  }

  Widget _buildDataPointRow(int index, Map<String, dynamic> point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: point['category']?.toString() ?? '',
              decoration: InputDecoration(
                labelText: 'Categoría ${index + 1}',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              onChanged: (value) {
                setState(() {
                  _dataPoints[index]['category'] = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: point['value']?.toString() ?? '',
              decoration: InputDecoration(
                labelText: 'Valor ${index + 1}',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Requerido';
                if (double.tryParse(value!) == null) return 'Número inválido';
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _dataPoints[index]['value'] = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.circle, color: point['color'] ?? _colors[index % _colors.length]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Seleccionar Color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: point['color'] ?? _colors[index % _colors.length],
                      onColorChanged: (color) {
                        setState(() {
                          _dataPoints[index]['color'] = color;
                        });
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _dataPoints.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Gráfico',
                ),
                items: const [
                  DropdownMenuItem(value: 'line', child: Text('Línea')),
                  DropdownMenuItem(value: 'bar', child: Text('Barras')),
                  DropdownMenuItem(value: 'pie', child: Text('Circular')),
                  DropdownMenuItem(value: 'column', child: Text('Columnas')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Lista de puntos de datos
              ..._dataPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return _buildDataPointRow(index, point);
              }).toList(),
              // Botón para agregar nuevo punto
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _dataPoints.add({'category': '', 'value': 0.0, 'color': _colors.first});
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Punto'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newChartData = _dataPoints.map((point) => ChartData(
                category: point['category'] as String,
                value: (point['value'] as num).toDouble(),
                date: DateTime.now(),
                color: point['color'] as Color,
              )).toList();
              
              Navigator.of(context).pop({
                'type': _selectedType,
                'title': widget.title,
                'data': newChartData,
                'isCustom': true,
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
