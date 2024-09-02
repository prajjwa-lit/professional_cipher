import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const PdfTextApp());
}

class PdfTextApp extends StatelessWidget {
  const PdfTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Text Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PdfHomePage(),
    );
  }
}

class PdfHomePage extends StatefulWidget {
  const PdfHomePage({super.key});

  @override
  _PdfHomePageState createState() => _PdfHomePageState();
}

class _PdfHomePageState extends State<PdfHomePage> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Create a PDF document with the text input
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(_textController.text),
          );
        },
      ),
    );

    // Save the PDF file to the device's temporary storage
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());

    // Display the PDF using the Printing package
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'example.pdf',
    );

    // Clear the text field after the PDF is generated and displayed
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Text Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your text here',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePdf,
              child: const Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
