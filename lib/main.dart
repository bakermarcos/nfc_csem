import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: ReadExampleScreen(),
  ));
}

class ReadExampleScreen extends StatefulWidget {
  @override
  _ReadExampleScreenState createState() => _ReadExampleScreenState();
}

class _ReadExampleScreenState extends State<ReadExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;
  List<String> strs = List();

  String a = "";

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
              a = 'ID: ${message.id}\n${record.data}\n$date';
            });
            break;
          } else {
            setState(() {
              a = 'ID: ${message.id}\n This tag has no temperature.\n$date';
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

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Read NFC example"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[ListView(
        shrinkWrap: true,
        children: <Widget>[RaisedButton(
        child: const Text("Escanear",
        style: TextStyle(color: Colors.blue, fontSize: 25.0),),
        color: Colors.grey[300],
        onPressed: _toggleScan,
      ),
      Padding(padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12), 
        ),
        child: Text(a,
        style: TextStyle(color: Colors.white,
        fontSize: 25.0),),),
        )
       ])
      ]),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSEM NFC Reader"),
        centerTitle: true,
      ),
      body: Center( child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: const Text("Scan",
                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
              color: Colors.blue,
              onPressed: _toggleScan,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Container(
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
            )
          ]),
    ));
  }
}
