import 'package:flutter/material.dart';

class DataCollectionScreen extends StatelessWidget {
  const DataCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image for Data Collection"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            bottom: 24.0,
            right: 24.0,
          ),
          child: Column(
            children: [
              /// Letter Selection
              Text("Select Letter", style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(
                height: 650,
                child: GridView.count(
                  crossAxisSpacing: 10,
                  crossAxisCount: 4,
                  children: List.generate(26, (index) {
                    String letter = alphabet.elementAt(index);
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          print('$letter pressed!');
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(Colors.black),
                          backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade100),
                        ),
                        child: Text(letter, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    );
                  }),
                ),
              ),
              /// Upload Image Button
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                  padding: WidgetStatePropertyAll(EdgeInsets.only(
                    left: 15.0,
                    top: 10.0,
                    right: 15.0,
                    bottom: 10.0,
                  )),
                ),
                child: Text("Upload Image", style: Theme.of(context).textTheme.labelSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
