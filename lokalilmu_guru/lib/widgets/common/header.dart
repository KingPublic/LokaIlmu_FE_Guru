import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const Header({
    super.key,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua Subjek', 'Informatika', 'Sains', 'Matematika', 'Bahasa'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar with blue border and rounded corners
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1B3C73), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1B3C73), width: 2),
              ),
            ),
          ),
        ),

        // Category pills
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSelected = cat == selectedCategory;

              return ChoiceChip(
                label: Text(cat,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    )),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(cat),
                selectedColor: const Color(0xFF1B3C73),
                backgroundColor: const Color(0xFFF0F0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: isSelected
                      ? BorderSide.none
                      : const BorderSide(color: Colors.transparent),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
