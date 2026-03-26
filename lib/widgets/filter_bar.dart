import 'package:flutter/material.dart';

import '../models/dashboard_filter.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.filter,
    required this.owners,
    required this.statuses,
    required this.onFilterChanged,
  });

  final DashboardFilter filter;
  final List<String> owners;
  final List<String> statuses;
  final ValueChanged<DashboardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: TextFormField(
                initialValue: filter.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search',
                ),
                onChanged: (value) {
                  onFilterChanged(filter.copyWith(search: value));
                },
              ),
            ),
            DropdownButtonFormField<DatePreset>(
              initialValue: filter.datePreset,
              decoration: const InputDecoration(labelText: 'Date'),
              items: const [
                DropdownMenuItem(
                  value: DatePreset.allTime,
                  child: Text('All time'),
                ),
                DropdownMenuItem(
                  value: DatePreset.currentQuarter,
                  child: Text('Current quarter'),
                ),
                DropdownMenuItem(
                  value: DatePreset.last6Months,
                  child: Text('Last 6 months'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFilterChanged(filter.copyWith(datePreset: value));
                }
              },
            ),
            DropdownButtonFormField<String?>(
              initialValue: filter.owner,
              decoration: const InputDecoration(labelText: 'Owner'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All owners'),
                ),
                ...owners.map(
                  (owner) => DropdownMenuItem<String?>(
                    value: owner,
                    child: Text(owner),
                  ),
                ),
              ],
              onChanged: (value) {
                onFilterChanged(
                  value == null
                      ? filter.copyWith(clearOwner: true)
                      : filter.copyWith(owner: value),
                );
              },
            ),
            DropdownButtonFormField<String?>(
              initialValue: filter.status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                ...statuses.map(
                  (status) => DropdownMenuItem<String?>(
                    value: status,
                    child: Text(status),
                  ),
                ),
              ],
              onChanged: (value) {
                onFilterChanged(
                  value == null
                      ? filter.copyWith(clearStatus: true)
                      : filter.copyWith(status: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
