import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../screens/result_screen.dart';

class CardProvider with ChangeNotifier {
  XFile? imageFile;
  List<Map<String, dynamic>> cardsDataList = []; // List to store both categorized and uncategorized data
  bool loading = false; // Track loading state

  CardProvider() {
    loadDataFromPreferences();
  }

  // Method to load data from SharedPreferences
  Future<void> loadDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedCardsData = prefs.getString('cardsDataList');

    if (storedCardsData != null) {
      cardsDataList = List<Map<String, dynamic>>.from(
          json.decode(storedCardsData).map((item) => Map<String, dynamic>.from(item))
      );
    }

    notifyListeners();
  }

  // Method to save data to SharedPreferences
  Future<void> saveDataToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(cardsDataList);
    prefs.setString('cardsDataList', encodedData);
  }

  void updateEntry(Map<String, String> updatedData, List<String> updatedRawTextLines, int index) {
    if (index >= 0 && index < cardsDataList.length) {
      cardsDataList[index]['categorizedData'] = updatedData;
      cardsDataList[index]['uncategorizedData'] = updatedRawTextLines;

      saveDataToPreferences(); // Save changes to SharedPreferences
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Method to handle image picking and text extraction
  Future<void> pickImage(ImageSource source) async {
    loading = true; // Start loading
    notifyListeners(); // Notify listeners to update UI

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        imageFile = pickedImage;
        await extractTextFromImage();
      }
    } catch (e) {
      print("Error picking image: $e"); // Log any error for debugging
    }

    loading = false; // Stop loading
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to extract text from the selected image
  Future<void> extractTextFromImage() async {
    if (imageFile == null) return;

    final InputImage inputImage = InputImage.fromFilePath(imageFile!.path);
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    Map<String, String> newEntry = {};
    List<String> newRawTextLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text.toLowerCase();

        if (lineText.contains('@')) {
          newEntry['Email'] = line.text;
        } else if (RegExp(r'^[+]*[0-9]{1,3}[-\s./0-9]*$').hasMatch(line.text)) {
          newEntry['Phone Number'] = line.text;
        } else if (lineText.contains('www') || lineText.contains('http')) {
          newEntry['Website'] = line.text;
        } else if (lineText.contains('inc') || lineText.contains('ltd') || lineText.contains('corp')) {
          newEntry['Company Name'] = line.text;
        } else if (lineText.contains('street') || lineText.contains('st.') || lineText.contains('road') || lineText.contains('avenue')) {
          newEntry['Address'] = '${newEntry['Address'] ?? ''}${line.text}, ';
        } else {
          newRawTextLines.add(line.text); // Add any text that doesn't match known patterns
        }
      }
    }

    if (newEntry.isNotEmpty || newRawTextLines.isNotEmpty) {
      cardsDataList.add({
        'categorizedData': newEntry,
        'uncategorizedData': newRawTextLines,
      });
      await saveDataToPreferences(); // Save both categorized and uncategorized data to SharedPreferences
    }

    textRecognizer.close();
    notifyListeners();
  }

  void deleteEntry(int index) {
    if (index >= 0 && index < cardsDataList.length) {
      cardsDataList.removeAt(index);
      saveDataToPreferences();
      notifyListeners();
    }
  }

  // Method to clear all data
  void clearData() {
    imageFile = null;
    cardsDataList.clear();
    saveDataToPreferences(); // Clear data from SharedPreferences as well
    notifyListeners();
  }

  void navigateToResult(BuildContext context, int index) {
    if (index >= 0 && index < cardsDataList.length) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            index: index,
          ),
        ),
      );
    }
  }
}
