import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nfc_csem/history_page.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:path_provider/path_provider.dart';


import 'entity/tags_entity.dart';
import 'entity/tags_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configDatabase();
  runApp(MaterialApp(
    home: NFCHome(),
    debugShowCheckedModeBanner: false,
  ));
}

_configDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive
    ..init(dir.path)
    ..registerAdapter(TagsEntityAdapter());

  await Hive.openBox<TagsEntity>('tags');
}

class NFCHome extends StatefulWidget {
  @override
  _NFCHomeState createState() => _NFCHomeState();
}

class _NFCHomeState extends State<NFCHome> {
  StreamSubscription<NDEFMessage> _stream;
  List<String> strs = List();

  String id = "";
  String temperature = "";
  String timestamp = "";
  TagsProvider provider = TagsProvider();

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
              id = 'ID: ${message.id}';
              timestamp = '$date';
              temperature = '${record.data}';
              provider.saveTag(TagsEntity(
                  id: id, date: timestamp, temperature: temperature));
            });
            break;
          } else {
            setState(() {
              id = 'ID: ${message.id}\nThis tag has no temperature.';
              timestamp = '$date';
              temperature = '-';
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.history),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HistoryPage()));
        },
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
                id + '\n' + timestamp,
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
                temperature,
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
