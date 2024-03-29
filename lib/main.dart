import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:nfc_csem/charts_page.dart';
import 'package:nfc_csem/history_page.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import 'entity/tags_entity.dart';
import 'entity/tags_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configDatabase();
  runApp(MaterialApp(
    home: NFCHome(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: <String, WidgetBuilder>{
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

class _NFCHomeState extends State<NFCHome> with TickerProviderStateMixin {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  StreamSubscription<NDEFMessage> _stream;
  List<String> strs = List();
  String ide = "";
  String temperature = "";
  String timestamp = "";
  TagsProvider provider = TagsProvider();

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );
    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  void _startScanning() {
    Wakelock.enable();
    setState(() {
      _stream = NFC.readNDEF(once: true).listen((NDEFMessage message) {
        if (message.isEmpty) {
          print("Read empty NDEF message");
          setState(() {
            ide = 'Empty Tag';
            temperature = '-';
          });
          return;
        }
        for (NDEFRecord record in message.records) {
          var date = DateTime.now();
          strs.add(record.data);
          if ((record.data != null) && (record.data.contains("temperature"))) {
            setState(() {
              ide = 'ID: ${message.records.contains('id').toString()}';
              timestamp = '$date';
              temperature = '${record.data}';
              temperature = temperature.replaceAll('Current temperature: ', '');
              temperature = temperature.replaceAll('C', '');
              temperature = temperature + '°C';
              temperature.replaceAll(' ', '');
              provider.saveTag(TagsEntity(
                  id: ide, date: timestamp, temperature: temperature));
            });
            break;
          } else {
            setState(() {
              ide = 'ID: ${message.records.contains('id').toString()}\nEssa tag não tem dado de temperatura.';
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
    Wakelock.disable();
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

  _launchCsemSite() async {
    const url = 'https://csembrasil.com.br/';
    if (await canLaunch(url)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Você quer ir ao website do CSEM Brasil?'),
            content: Text(
                'CSEM Brasil é um centro de pesquisa e desenvolvimento, gerando soluções inovadoras para o mercado. Vá para o website para mais informações.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Ir para website'),
                onPressed: () async {
                  Navigator.pop(context);
                  await launch(url);
                },
              )
            ],
          );
        },
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AppSettings.openNFCSettings();
            },
            icon: Icon(Icons.nfc_rounded),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Text("App NFC", style: TextStyle(color: Colors.white)),
            Container(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text('Leitor NFC',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.028,
                    )))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          // Floating action chart item
          Bubble(
            title: "Gráficos",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.show_chart_rounded,
            titleStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
                color: Colors.white),
            onPress: () {
              _animationController.reverse();
              Navigator.pushNamed(context, '/chart');
            },
          ),
          //Floating action history item
          Bubble(
            title: "Histórico",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.history,
            titleStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.02,
                color: Colors.white),
            onPress: () {
              _animationController.reverse();
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
      body: Column(children: <Widget>[
        Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1)),
        GestureDetector(
          child: Image.asset(
            'images/csem.png',
            alignment: Alignment.center,
            fit: BoxFit.fitWidth,
            height: MediaQuery.of(context).size.height * 0.085,
          ),
          onTap: _launchCsemSite,
        ),
        Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1)),
        RaisedButton(
          child: Text((_stream == null ? "Escanear" : "Parar de escanear"),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.027)),
          color: Colors.blue,
          onPressed: () {
            //MediaQuery.of(context).size.width = 411.42857142857144
            //MediaQuery.of(context).size.height = 731.4285714285714
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
            ide + '\n' + timestamp,
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.034),
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
              fontSize: MediaQuery.of(context).size.height * 0.13,
            ),
          ),
        )
      ]),
    );
  }
}
