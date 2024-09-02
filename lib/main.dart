import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextToImageScreen(),
    );
  }
}

class TextToImageScreen extends StatefulWidget {
  @override
  _TextToImageScreenState createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _generatedImage;

  Future<void> _generateImage(String text) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Define the size of the canvas
    const double width = 300;
    const double height = 100;

    // Draw white background
    final Paint paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    // Draw the text on the canvas
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: width);
    textPainter.paint(canvas, Offset(10, 25));

    final ui.Image image = await recorder.endRecording().toImage(width.toInt(), height.toInt());

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save the image to a file
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/generated_image.png');
      await file.writeAsBytes(pngBytes);

      setState(() {
        _generatedImage = file;
        _textController.clear(); // Clear the text field after generating the image
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to: ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Image Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter text to generate image',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _generateImage(_textController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter some text')),
                  );
                }
              },
              child: Text('Generate Image'),
            ),
            SizedBox(height: 20),
            _generatedImage != null
                ? Image.file(_generatedImage!)
                : Text('No image generated yet'),
          ],
        ),
      ),
    );
  }
}
