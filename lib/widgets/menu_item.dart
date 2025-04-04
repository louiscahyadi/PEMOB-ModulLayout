import 'package:flutter/material.dart';

// widget untuk menampilkan item menu
// widget ini digunakan untuk menampilkan menu dengan ikon dan label
class MenuItem extends StatelessWidget {
  // icon menu
  final IconData icon;

  // label menu
  final String label;

  // qarna menu
  final Color color;

  // callback saat menu ditekan
  final VoidCallback? onTap;

  // constructor untuk membuat widget MenuItem
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
