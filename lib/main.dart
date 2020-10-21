import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: NFCHome(),
  ));
}

class NFCHome extends StatefulWidget {
  @override
  _NFCHomeState createState() => _NFCHomeState();
}

class _NFCHomeState extends State<NFCHome> {
  StreamSubscription<NDEFMessage> _stream;
  List<String> strs = List();

  String a = "";
  String b = "";

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) {
        var date = DateTime.now();
        if (message.isEmpty) {
          print("Read empty NDEF message");
          return;
        }
        print("Read NDEF message with ${message.records.length} records");
        for (NDEFRecord record in message.records) {
          strs.add(record.data);
          print(record.data);
          if ((record.data != null) && (record.data.contains("temperature"))) {
            setState(() {
              a = 'ID: ${message.id}\n$date';
              b = '${record.data}';
            });
            break;
          } else {
            setState(() {
              a = 'ID: ${message.id}\nThis tag has no temperature.\n$date';
              b = '-';
            });
          }
        }
      }, onError: (error) {
        setState(() {
          _stream = null;
        });
        if (error is NFCUserCanceledSessionException) {
          print("user canceled");
        } else if (error is NFCSessionTimeoutException) {
          print("session timed out");
        } else {
          print("error: $error");
        }
      }, onDone: () {
        setState(() {
          _stream = null;
        });
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Image.asset(
                 'images/csembr.png',
                  fit: BoxFit.contain,
                  height: 32,
              ),
              Container(
                  padding: const EdgeInsets.all(10.0), child: Text('NFC Reader'))
            ],
          ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: const Text("Scan",
                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
              color: Colors.blue,
              onPressed: _toggleScan,
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                a,
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                b,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35.0,
                ),
              ),
            )
          ]),
    );
  }
}
