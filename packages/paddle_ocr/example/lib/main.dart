import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paddle_ocr/bean/ocr_results.dart';
import 'package:paddle_ocr/paddle_ocr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isEnabled = true;
  String _ocrResultStr = 'No OCR result yet.';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await PaddleOcr.platformVersion ?? 'Unknown';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _pickImageAndRunOcr() async {
    setState(() {
      isEnabled = false;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (!mounted) return;
      setState(() {
        isEnabled = true;
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
    final ocrResultMap = await PaddleOcr.ocrFromImage(
      pickedFile.path,
      ocr_type: 'ID_CARD',
      isPrint: true,
    );

    if (!mounted) return;

    if (ocrResultMap['success'] == true) {
      final ocrResultInfo = ocrResultMap['ocrResult'] as OcrResultInfo;
      final ocrType = ocrResultInfo.ocr_type ?? 'OTHER';
      final results = ocrResultInfo.ocrResults ?? const [];
      final buffer = StringBuffer()
        ..writeln(ocrType)
        ..writeln();

      if (ocrType == 'EMPTY') {
        buffer.writeln('Empty page.');
      }
      if (ocrType == 'BANK_CARD' && results.isEmpty) {
        buffer.writeln('Please try recognizing again.');
      }

      for (final ocrResult in results) {
        buffer
          ..writeln(
            '${ocrResult.index} ${ocrResult.name} ${ocrResult.confidence}',
          )
          ..writeln(ocrResult.bounds.toString())
          ..writeln();
      }

      setState(() {
        _ocrResultStr = buffer.toString();
      });
    } else {
      debugPrint(
        'OCR failed [${ocrResultMap['code']} ${ocrResultMap['message']}]',
      );
    }

    setState(() {
      isEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Paddle OCR Demo'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              TextButton(
                onPressed: isEnabled ? _pickImageAndRunOcr : null,
                child: const Text('Test OCR recognition'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_ocrResultStr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
