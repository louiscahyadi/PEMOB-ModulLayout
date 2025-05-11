import 'package:flutter/material.dart';

// mengimplementasikan widget untuk menampilkan item menu
// menyediakan tampilan menu dengan kombinasi ikon dan label
class MenuItem extends StatelessWidget {
  // menyimpan data ikon yang akan ditampilkan
  final IconData icon;

  // menyimpan teks label untuk menu
  final String label;

  // menyimpan warna yang akan digunakan pada menu
  final Color color;

  // menyediakan fungsi callback ketika menu ditekan
  final VoidCallback? onTap;

  // menginisialisasi widget menu item dengan parameter yang diperlukan
  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFC9B194),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF706D54),
              size: 28.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF706D54),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
