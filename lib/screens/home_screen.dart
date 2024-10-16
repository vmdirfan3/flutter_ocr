import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visiting Card Scanner'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () {
              cardProvider.pickImage(ImageSource.camera).then((_) {
                if (cardProvider.imageFile != null) {
                  // Use the last added entry index
                  cardProvider.navigateToResult(context, cardProvider.cardsDataList.length - 1);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () {
              cardProvider.pickImage(ImageSource.gallery).then((_) {
                if (cardProvider.imageFile != null) {
                  // Use the last added entry index
                  cardProvider.navigateToResult(context, cardProvider.cardsDataList.length - 1);
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: cardProvider.loading // Show loading indicator if loading is true
            ? const CircularProgressIndicator()
            : cardProvider.cardsDataList.isEmpty
            ? const Text(
          'No Saved Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
            : ListView.builder(
          itemCount: cardProvider.cardsDataList.length,
          itemBuilder: (context, index) {
            // Access the card's categorized data and uncategorized data
            final entry = cardProvider.cardsDataList[index];
            final categorizedData = entry['categorizedData'] as Map<String, dynamic>;

            // Display the main piece of categorized data (Company Name or any preferred field)
            String displayText = categorizedData['Company Name'] ?? categorizedData['Email'] ?? categorizedData['Phone Number'] ?? 'Unknown';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(displayText, style: const TextStyle(fontSize: 18)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Remove the selected entry from the list
                    cardProvider.deleteEntry(index);
                  },
                ),
                onTap: () {
                  // Navigate to ResultScreen with detailed information of the selected entry
                  cardProvider.navigateToResult(context, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
