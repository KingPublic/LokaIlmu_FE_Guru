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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...['Semua Subjek', 'Informatika', 'Sains', 'Matematika', 'Bahasa']
                  .map((cat) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) {
                            onCategorySelected(cat);
                          },
                        ),
                      ))
            ],
          ),
        ),
      ],
    );
  }
}
