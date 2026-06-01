import 'package:flutter/material.dart';

class ExerciseExecutionPage extends StatelessWidget {
  const ExerciseExecutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      appBar: AppBar(
        title: Text("Workout Session", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Full Body Workout",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3949AB), // FIX DI SINI
              ),
            ),
            SizedBox(height: 8),
            Text("Latihan 1 dari 5", style: TextStyle(color: Colors.grey[600])),

            SizedBox(height: 12),

            LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              minHeight: 8,
            ),

            SizedBox(height: 30),

            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJueXZueXpueXpueXpueXpueXpueXpueXpueXpueXpueXpueXpueZ3/3o7TKuylOmScgBA64/giphy.gif',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 25),

            Text(
              "Push Up",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Turunkan tubuh hingga dada hampir menyentuh lantai, jaga punggung tetap lurus, lalu dorong kembali ke atas.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            SizedBox(height: 40),

            Center(
              child: Text(
                "Bagian Timer & Kontrol (Next Step)",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
