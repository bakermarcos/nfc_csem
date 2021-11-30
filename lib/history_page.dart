import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:nfc_csem/entity/tags_entity.dart';
import 'package:path_provider/path_provider.dart';

import 'entity/tags_provider.dart';

enum OptionsOptions { export, delete }

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin{
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OptionsOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OptionsOptions>>[
              const PopupMenuItem<OptionsOptions>(
                child: Text('Exportar para CSV'),
                value: OptionsOptions.export,
              ),
              const PopupMenuItem<OptionsOptions>(
                child: Text(
                  'Deletar Histórico',
                  style: TextStyle(color: Colors.red),
                ),
                value: OptionsOptions.delete,
              )
            ],
            onSelected: _options,
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Text("App NFC", style: TextStyle(color: Colors.white)),
            Container(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text('Histórico de Tags', style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.028,)))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          // Floating action menu item
          Bubble(
            title:"Home",
            iconColor :Colors.white,
            bubbleColor : Colors.blue,
            icon:Icons.home_filled,
            titleStyle:TextStyle(fontSize: MediaQuery.of(context).size.height*0.02, color: Colors.white),
            onPress: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          //Floating action menu item
          Bubble(
            title:"Gráficos",
            iconColor :Colors.white,
            bubbleColor : Colors.blue,
            icon:Icons.show_chart_rounded,
            titleStyle:TextStyle(fontSize: MediaQuery.of(context).size.height*0.02 , color: Colors.white),
            onPress: () {
              _animationController.reverse();
              Navigator.pushNamed(context, '/chart');
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
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: provider.tags.length,
          itemBuilder: (context, index) {
            return _tagCard(context, index);
          }),
    );
  }

  Widget _tagCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        provider.getTags()[index].id ?? '',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height*0.03, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        provider.getTags()[index].date ?? '',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height*0.024,
                        ),
                      ),
                      Text(
                        provider.getTags()[index].temperature ?? '',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height*0.024,
                          color: Colors.orange[800],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onTap: () {
          _showOptionsTag(context, index);
        });
  }

  void _showOptionsTag(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        'Compartilhar temperatura da Tag',
                        style: TextStyle(color: Colors.green, fontSize: MediaQuery.of(context).size.height*0.027),
                      ),
                      onPressed: () {
                        _shareTemperatureTag(index);
                        setState(() {
                          provider.getTags();
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        'Deletar Tag',
                        style: TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.height*0.027),
                      ),
                      onPressed: () {
                        _deleteTagslct(provider.getTags()[index]);
                        setState(() {
                          provider.getTags();
                          Navigator.pop(context);
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _options(OptionsOptions result) {
    switch (result) {
      case OptionsOptions.export:
        _generateCSV(context);
        return;
        break;
      case OptionsOptions.delete:
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Deletar todo histórico?'),
              content: Text('Se você deletar todo o histórico todos os dados serão perdidos.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Deletar'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _deleteHistory(context);
                    });
                  },
                )
              ],
            );
          },
        );
        return;
        break;
    }
    setState(() {});
  }

  _deleteTagslct(TagsEntity tag) {
    provider.deleteTag(tag);
    setState(() {
      provider.getTags();
    });
  }

  _shareTemperatureTag(index) {
    Share.share(provider.getTags()[index].temperature);
    setState(() {
      provider.getTags();
    });
  }

  _deleteHistory(context) {
    setState(() {
      provider.tagsBox.clear();
      provider.getTags();
    });
  }

  Future<void> _generateCSV(context) async {
    List<TagsEntity> data = provider.getTags();
    List<List<String>> csvData = [
      // headers
      <String>['id', 'date', 'temperature'],
      // data
      ...data.map((item) => [item.id, item.date.toString(), item.temperature]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/temperature_data.csv';

    // create file
    final File file = File(path);
    // Save csv string using default configuration
    // , as field separator
    // " as text delimiter and
    // \r\n as eol.
    await file.writeAsString(csv);

    Share.shareFiles(['$dir/temperature_data.csv'], text: 'Temperature Data');
  }
}