import 'dart:async';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nfc_csem/charts_page.dart';
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
    initialRoute: '/',
    routes: <String, WidgetBuilder> {
      '/history': (context) => HistoryPage(),
      '/chart': (context) => ChartPage(),
    },
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

class _NFCHomeState extends State<NFCHome> with TickerProviderStateMixin{
  StreamSubscription<NDEFMessage> _stream;
  List<String> strs = List();
  String id = "";
  String temperature = "";
  String timestamp = "";
  TagsProvider provider = TagsProvider();

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState(){   
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation); 
    super.initState();
  }

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          // Floating action menu item
          Bubble(
            title:"Charts",
            iconColor :Colors.white,
            bubbleColor : Colors.blue,
            icon:Icons.show_chart_rounded,
            titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
            onPress: () {
              Navigator.pushNamed(context, '/chart');
            },
          ),
          //Floating action menu item
          Bubble(
            title:"History",
            iconColor :Colors.white,
            bubbleColor : Colors.blue,
            icon:Icons.history,
            titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
            onPress: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        
        // Floating Action button Icon color
        iconColor: Colors.blue,

        // Flaoting Action button Icon 
        icon: AnimatedIcons.list_view,

        
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text((_stream == null ? "Scan" : "Stop scanning"),
                  style: TextStyle(color: Colors.white, fontSize: 20.0)
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    if (_stream == null) {
                      _startScanning();
                      
                    } else {
                      _stopScanning();
                    }
                  },
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
                temperature.replaceAll('Current temperature: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 90.0,
                ),
              ),
            )
          ]),
    );
  }
}
