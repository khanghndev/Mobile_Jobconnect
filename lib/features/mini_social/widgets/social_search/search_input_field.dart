import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  const SearchInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child:  TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          hintText: 'Tìm kiếm',
          hintStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white60,
      )
    );
  }
}
