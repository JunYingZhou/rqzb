import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:paddle_ocr/bean/ocr_results.dart';
import 'package:paddle_ocr/paddle_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isEnabled = true;
  String _ocrResultStr = '无';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PaddleOcr.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
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
              FlatButton(
                onPressed:isEnabled?() async {
                  setState(() {
                    isEnabled = false;
                  });
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(source: ImageSource.gallery);
                  if(pickedFile == null){
                    setState(() {
                      isEnabled = true;
                    });
                    return;
                  }
                  Future.delayed(Duration(milliseconds: 100),() async{
                    dynamic ocrResultMap = await PaddleOcr.ocrFromImage(pickedFile.path,ocr_type: 'ID_CARD',isPrint:true);
                    if(ocrResultMap['success']) {
                      OcrResultInfo ocrResultInfo = ocrResultMap['ocrResult'];
                      print(ocrResultInfo.ocrResults.toString());
                      setState(() {
                        _ocrResultStr = ocrResultInfo.ocr_type +
                            '\n\n' +
                            (ocrResultInfo.ocr_type == 'EMPTY' ? '空白页' : '');
                        if (ocrResultInfo.ocr_type == 'BANK_CARD' &&
                            ocrResultInfo.ocrResults.length == 0) {
                          _ocrResultStr += '请重新识别';
                        }
                      });
                      ocrResultInfo.ocrResults.forEach((ocrResult) {
                        setState(() {
                          _ocrResultStr +=
                          '${ocrResult.index} ${ocrResult.name} ${ocrResult.confidence}\n ${ocrResult.bounds.toString()}\n\n';
                        });
                      });
                    }else{
                      print('ocr识别失败[${ocrResultMap['code']} ${ocrResultMap['message']}]');
                    }
                    setState(() {
                      isEnabled = true;
                    });
                  });
                }:null,
                child: Text('测试OCR识别'),
              ),
              Expanded(child: SingleChildScrollView(child: Text(_ocrResultStr)))
            ],
          ),
        ),
      ),
    );
  }
}
