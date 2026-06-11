import 'package:flutter/material.dart';
import 'calculator.dart';
import 'unit_converter.dart';
import 'text_analyzer.dart';
import 'date_calculator.dart';
import 'percentage_calculator.dart';

class ToolsHubApp extends StatefulWidget {
  const ToolsHubApp({super.key});

  @override
  State<ToolsHubApp> createState() => _ToolsHubAppState();
}

class _ToolsHubAppState extends State<ToolsHubApp> {
  int _selectedCategory = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Calculator', 'icon': Icons.calculate},
    {'name': 'Converter', 'icon': Icons.science},
    {'name': 'Text', 'icon': Icons.text_fields},
    {'name': 'Date & Time', 'icon': Icons.date_range},
  ];
  
  final List<Map<String, dynamic>> _tools = [
    // Calculator
    {'name': 'Calculator', 'icon': Icons.calculate, 'category': 'Calculator', 'screen': const CalculatorApp(), 'description': 'Basic arithmetic'},
    {'name': 'Percentage Calc', 'icon': Icons.percent, 'category': 'Calculator', 'screen': const PercentageCalculatorApp(), 'description': 'Percentage calculations'},
    
    // Converter
    {'name': 'Unit Converter', 'icon': Icons.science, 'category': 'Converter', 'screen': const UnitConverterApp(), 'description': 'Length, weight, temperature...'},
    {'name': 'Currency Conv', 'icon': Icons.attach_money, 'category': 'Converter', 'screen': null, 'description': 'Live exchange rates'},
    
    // Text
    {'name': 'Text Analyzer', 'icon': Icons.analytics, 'category': 'Text', 'screen': const TextAnalyzerApp(), 'description': 'Character, word count'},
    
    // Date & Time
    {'name': 'Date Calculator', 'icon': Icons.calculate, 'category': 'Date & Time', 'screen': const DateCalculatorApp(), 'description': 'Difference, add days'},
    {'name': 'Alarms & Clock', 'icon': Icons.access_time, 'category': 'Date & Time', 'screen': null, 'description': 'Timer, stopwatch'},
  ];

  void _openTool(Map<String, dynamic> tool) {
    if (tool['screen'] != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => tool['screen']));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), backgroundColor: Color(0xFF00BCD4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTools = _selectedCategory == 0
        ? _tools
        : _tools.where((t) => t['category'] == _categories[_selectedCategory]['name']).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tools Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 45,
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(cat['icon'], color: isSelected ? Colors.black : const Color(0xFF00BCD4), size: 16),
                        const SizedBox(width: 6),
                        Text(cat['name'], style: TextStyle(color: isSelected ? Colors.black : const Color(0xFF00BCD4), fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tools Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredTools.length,
              itemBuilder: (context, index) {
                final tool = filteredTools[index];
                return GestureDetector(
                  onTap: () => _openTool(tool),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(tool['icon'], color: const Color(0xFF00BCD4), size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tool['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tool['description'],
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
