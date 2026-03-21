import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_kpi_screen.dart';

class CorporateFundingScreen extends StatefulWidget {
  const CorporateFundingScreen({super.key});

  @override
  State<CorporateFundingScreen> createState() => _CorporateFundingScreenState();
}

class _CorporateFundingScreenState extends State<CorporateFundingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Delete KPI
  Future<void> deleteKpi(String docId) async {
    await FirebaseFirestore.instance
        .collection('kpi_records')
        .doc(docId)
        .delete();
  }

  // Stream for KPIs
  Stream<QuerySnapshot<Map<String, dynamic>>> getKpiStream() {
    return _firestore
        .collection('kpi_records')
        .orderBy('createdAt')
        .snapshots();
  }

  // Group KPIs by pillar
  Map<String, List<Map<String, dynamic>>> groupKpisByPillar(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {
      'Corporate & Foundation Funding': [],
      'Institutional Grants & Trusts': [],
      'Digital & Online Fundraising': [],
      'Individual Giving & Board Engagement': [],
      'Strategic Events & Partnerships': [],
    };

    for (var doc in docs) {
      final data = doc.data();
      data['id'] = doc.id;
      final pillar = (data['pillar'] ?? '') as String;
      if (grouped.containsKey(pillar)) grouped[pillar]!.add(data);
    }

    return grouped;
  }

  // Update KPI value
  Future<void> updateKpiValue(String docId, num newValue) async {
    await FirebaseFirestore.instance
        .collection('kpi_records')
        .doc(docId)
        .update({'value': newValue});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[300], // gray top bar
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Image.asset('assets/usapho_logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Dashboard',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getKpiStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final grouped = groupKpisByPillar(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 Executive Summary Grid (3 per row)
                LayoutBuilder(
                  builder: (context, constraints) {
                    double spacing = 12;
                    double cardWidth = (constraints.maxWidth - spacing * 2) / 3;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.start,
                      children: grouped.entries.map((entry) {
                        final pillar = entry.key;
                        final kpis = entry.value;

                        final totalValue = kpis.fold<num>(
                          0,
                          (acc, kpi) => acc + ((kpi['value'] ?? 0) as num),
                        );
                        final totalTarget = kpis.fold<num>(
                          0,
                          (acc, kpi) => acc + ((kpi['target'] ?? 0) as num),
                        );
                        final percent = totalTarget > 0
                            ? (totalValue / totalTarget) * 100
                            : 0;

                        String status;
                        Color color;

                        if (percent >= 100) {
                          status = 'On Track';
                          color = Colors.green;
                        } else if (percent >= 50) {
                          status = 'At Risk';
                          color = Colors.orange;
                        } else {
                          status = 'Off Track';
                          color = Colors.red;
                        }

                        return SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pillar,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${percent.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // 🟢 Detailed KPI View
                const Text(
                  'Detailed KPI Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Column(
                  children: grouped.entries.map((entry) {
                    final pillar = entry.key;
                    final kpis = entry.value;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pillar,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: kpis.map((kpi) {
                                final kpiName =
                                    (kpi['kpi'] ?? 'Unnamed KPI') as String;
                                final owner =
                                    (kpi['owner'] ?? 'Unassigned') as String;
                                final value = (kpi['value'] ?? 0) as num;
                                final target = (kpi['target'] ?? 0) as num;
                                final percent = target > 0
                                    ? (value / target) * 100
                                    : 0;

                                Color statusColor;
                                String statusLabel;

                                if (percent >= 100) {
                                  statusColor = Colors.green;
                                  statusLabel = 'On Track';
                                } else if (percent >= 50) {
                                  statusColor = Colors.orange;
                                  statusLabel = 'At Risk';
                                } else {
                                  statusColor = Colors.red;
                                  statusLabel = 'Off Track';
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            final controller =
                                                TextEditingController();
                                            showDialog(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                    title: Text(kpiName),
                                                    content: TextField(
                                                      controller: controller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          const InputDecoration(
                                                            labelText:
                                                                'Enter new value',
                                                          ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              dialogContext,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final newValue =
                                                              num.tryParse(
                                                                controller.text,
                                                              ) ??
                                                              0;
                                                          await updateKpiValue(
                                                            kpi['id'] ?? '',
                                                            newValue,
                                                          );
                                                          if (!dialogContext
                                                              .mounted) {
                                                            return;
                                                          }
                                                          Navigator.of(
                                                            dialogContext,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          'Update',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$kpiName ($owner): $value / $target (${percent.toStringAsFixed(1)}%)',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                statusLabel,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: LinearProgressIndicator(
                                                  value: target > 0
                                                      ? (value / target).clamp(
                                                          0,
                                                          1,
                                                        )
                                                      : 0,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete KPI'),
                                              content: Text(
                                                'Are you sure you want to delete "$kpiName"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            await deleteKpi(kpi['id'] ?? '');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddKpiScreen()),
          );
        },
      ),
    );
  }
}
