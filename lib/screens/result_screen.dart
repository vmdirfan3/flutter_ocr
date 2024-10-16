import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';

class ResultScreen extends StatelessWidget {
  final int index; // Index of the current card

  const ResultScreen({required this.index});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);

    // Fetch the current card's data using the index
    final cardData = cardProvider.cardsDataList[index];
    final Map<String, String> extractedData = Map<String, String>.from(cardData['categorizedData']);
    final List<String> rawTextLines = List<String>.from(cardData['uncategorizedData']);

    // TextEditingController for uncategorized data
    TextEditingController rawTextController = TextEditingController(text: rawTextLines.join('\n'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Enter edit mode
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Edit Card'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categorized Information:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ...extractedData.keys.map((key) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: TextField(
                                controller: TextEditingController(text: extractedData[key]),
                                decoration: InputDecoration(
                                  labelText: key,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  // Update the corresponding data in the card provider
                                  extractedData[key] = value;
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          const Text(
                            'Uncategorized Information:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: rawTextController,
                            maxLines: null, // Allow multiline input
                            decoration: const InputDecoration(
                              labelText: 'Uncategorized Information',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Update raw text lines directly
                              cardProvider.updateEntry(extractedData, value.split('\n'), index);
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Save changes when done
                          cardProvider.updateEntry(extractedData, rawTextController.text.split('\n'), index);
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Details saved successfully!')),
                          );
                        },
                        child: const Text('Save'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog without saving
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Categorized Information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...extractedData.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$key: ${extractedData[key] ?? ''}',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text(
                'Uncategorized Information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                rawTextLines.join('\n'),
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
