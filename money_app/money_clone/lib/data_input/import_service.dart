import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:excel/excel.dart';
import 'package:money_clone/data/models.dart' as models;

class ImportService {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Capture image from camera
  Future<File?> captureImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing image: $e');
      }
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  // Recognize text from an image
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      if (kDebugMode) {
        print('Error recognizing text: $e');
      }
      return '';
    }
  }

  // Parse recognized text into possible transactions
  List<Map<String, dynamic>> parseReceiptText(String text) {
    final List<Map<String, dynamic>> possibleTransactions = [];
    
    // Simple regex patterns to identify potential transaction data
    final datePattern = RegExp(r'\d{1,2}[\/\.\-]\d{1,2}[\/\.\-]\d{2,4}');
    final amountPattern = RegExp(r'\$?\d+\.\d{2}');
    
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // Look for amount pattern
      final amountMatches = amountPattern.allMatches(line);
      if (amountMatches.isNotEmpty) {
        final amount = amountMatches.first.group(0)?.replaceAll('\$', '') ?? '0.00';
        
        // Look for a date in nearby lines
        String? date;
        for (int j = max(0, i - 2); j <= min(lines.length - 1, i + 2); j++) {
          final dateMatches = datePattern.allMatches(lines[j]);
          if (dateMatches.isNotEmpty) {
            date = dateMatches.first.group(0);
            break;
          }
        }
        
        // Use the current line or previous line as a potential title
        final title = i > 0 && !amountPattern.hasMatch(lines[i - 1])
            ? lines[i - 1].trim()
            : line.replaceAll(amountPattern, '').trim();
        
        if (title.isNotEmpty) {
          possibleTransactions.add({
            'title': title,
            'amount': double.tryParse(amount) ?? 0.0,
            'date': date,
          });
        }
      }
    }
    
    return possibleTransactions;
  }

  // Import from Excel file
  Future<List<models.Transaction>> importFromExcel(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      final List<models.Transaction> transactions = [];
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]?.rows;
      
      if (rows == null || rows.isEmpty) return [];
      
      // Analyze header row to determine column mapping
      final headerRow = rows[0];
      final Map<String, int> columnMap = {};
      
      for (int i = 0; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell == null) continue;
        
        final header = cell.value.toString().toLowerCase();
        
        if (header.contains('date')) {
          columnMap['date'] = i;
        } else if (header.contains('desc') || header.contains('detail') || header.contains('narr')) {
          columnMap['description'] = i;
        } else if (header.contains('amount') || header.contains('value')) {
          columnMap['amount'] = i;
        } else if (header.contains('type') || header.contains('category')) {
          columnMap['type'] = i;
        }
      }
      
      // Parse data rows
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;
        
        try {
          final dateIndex = columnMap['date'];
          final descIndex = columnMap['description'];
          final amountIndex = columnMap['amount'];
          final typeIndex = columnMap['type'];
          
          // Skip row if required columns are missing
          if (dateIndex == null || descIndex == null || amountIndex == null) continue;
          
          final dateCell = row[dateIndex];
          final descCell = row[descIndex];
          final amountCell = row[amountIndex];
          final typeCell = typeIndex != null ? row[typeIndex] : null;
          
          if (dateCell == null || descCell == null || amountCell == null) continue;
          
          DateTime date;
          // Check if the date value is already a DateTime
          if (dateCell.value is DateTime) {
            date = dateCell.value as DateTime;
          } else {
            // Try to parse date from string
            try {
              date = DateTime.parse(dateCell.value.toString());
            } catch (_) {
              // If parsing fails, use current date
              date = DateTime.now();
            }
          }
          
          final description = descCell.value.toString();
          double amount;
          
          // Check if the amount value is already a number
          if (amountCell.value is num) {
            amount = (amountCell.value as num).toDouble();
          } else {
            // Try to parse amount from string
            final amountStr = amountCell.value.toString().replaceAll(RegExp(r'[^\d\.-]'), '');
            amount = double.tryParse(amountStr) ?? 0.0;
          }
          
          // Determine transaction type
          models.TransactionType type;
          if (typeCell != null) {
            final typeStr = typeCell.value.toString().toLowerCase();
            if (typeStr.contains('income') || typeStr.contains('credit')) {
              type = models.TransactionType.income;
            } else if (typeStr.contains('expense') || typeStr.contains('debit')) {
              type = models.TransactionType.expense;
            } else if (typeStr.contains('transfer')) {
              type = models.TransactionType.transfer;
            } else {
              // Determine type based on amount sign
              type = amount >= 0 ? models.TransactionType.income : models.TransactionType.expense;
            }
          } else {
            // Determine type based on amount sign
            type = amount >= 0 ? models.TransactionType.income : models.TransactionType.expense;
          }
          
          // Ensure amount is positive (type determines if it's income or expense)
          amount = amount.abs();
          
          transactions.add(models.Transaction(
            id: 'import_${i}_${DateTime.now().millisecondsSinceEpoch}',
            title: description,
            amount: amount,
            date: date,
            type: type,
            paymentMethod: models.PaymentMethod.other,
          ));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing row $i: $e');
          }
          continue;
        }
      }
      
      return transactions;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing from Excel: $e');
      }
      return [];
    }
  }
  
  // Helper function
  int max(int a, int b) => a > b ? a : b;
  int min(int a, int b) => a < b ? a : b;
}
