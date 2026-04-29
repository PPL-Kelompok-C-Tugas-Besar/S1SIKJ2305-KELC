// WAJIB ADA BARIS INI DI PALING ATAS:
import 'package:flutter/material.dart'; 
// Dan baris ini buat manggil file olahraga lo:
import 'package:gymbro/screen/workout_screen.dart'; 

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AlifWorkoutScreen(), 
  ));
}