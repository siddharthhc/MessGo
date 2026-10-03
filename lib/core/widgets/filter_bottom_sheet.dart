import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic> currentFilters;

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    required this.currentFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _maxPrice;
  late double _minRating;
  late bool _vegOnly;
  late bool _openNow;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.currentFilters['maxPrice'] ?? 5000;
    _minRating = widget.currentFilters['minRating'] ?? 0;
    _vegOnly = widget.currentFilters['vegOnly'] ?? false;
    _openNow = widget.currentFilters['openNow'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _maxPrice = 5000;
                          _minRating = 0;
                          _vegOnly = false;
                          _openNow = false;
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Color(0xFF00D4FF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Max Price: ?${_maxPrice.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Slider(
                  value: _maxPrice,
                  min: 1000,
                  max: 5000,
                  divisions: 8,
                  activeColor: const Color(0xFF00D4FF),
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _maxPrice = v),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Min Rating: ${_minRating.toStringAsFixed(1)}+',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: const Color(0xFF00D4FF),
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _minRating = v),
                ),
                
                const SizedBox(height: 16),
                
                _buildToggle('Veg Only', _vegOnly, (v) => setState(() => _vegOnly = v)),
                _buildToggle('Open Now', _openNow, (v) => setState(() => _openNow = v)),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF2979FF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onApply({
                            'maxPrice': _maxPrice,
                            'minRating': _minRating,
                            'vegOnly': _vegOnly,
                            'openNow': _openNow,
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Apply Filters',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00D4FF),
            activeTrackColor: const Color(0xFF00D4FF).withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
