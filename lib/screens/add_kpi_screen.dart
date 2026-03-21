import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddKpiScreen extends StatefulWidget {
  const AddKpiScreen({super.key});

  @override
  State<AddKpiScreen> createState() => _AddKpiScreenState();
}

class _AddKpiScreenState extends State<AddKpiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController kpiController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();

  String? selectedPillar;

  final List<String> pillars = [
    'Corporate & Foundation Funding',
    'Institutional Grants & Trusts',
    'Digital & Online Fundraising',
    'Individual Giving & Board Engagement',
    'Strategic Events & Partnerships',
  ];

  Future<void> saveKpi() async {
    if (!_formKey.currentState!.validate() || selectedPillar == null) return;

    await FirebaseFirestore.instance.collection('kpi_records').add({
      'kpi': kpiController.text.trim(),
      'value': num.tryParse(valueController.text) ?? 0,
      'target': num.tryParse(targetController.text) ?? 0,
      'pillar': selectedPillar,
      'owner': ownerController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add KPI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: kpiController,
                decoration: const InputDecoration(labelText: 'KPI Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter KPI name' : null,
              ),
              TextFormField(
                controller: ownerController,
                decoration: const InputDecoration(
                  labelText: 'Person Responsible',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter person responsible'
                    : null,
              ),
              TextFormField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
              TextFormField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target'),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedPillar,
                hint: const Text('Select Pillar'),
                items: pillars
                    .map(
                      (pillar) =>
                          DropdownMenuItem(value: pillar, child: Text(pillar)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPillar = value;
                  });
                },
                validator: (value) => value == null ? 'Select a pillar' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: saveKpi, child: const Text('Save KPI')),
            ],
          ),
        ),
      ),
    );
  }
}
