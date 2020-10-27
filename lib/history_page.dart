import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
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

class _HistoryPageState extends State<HistoryPage> {
  TagsProvider provider = TagsProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OptionsOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OptionsOptions>>[
              const PopupMenuItem<OptionsOptions>(
                child: Text('Export to CSV'),
                value: OptionsOptions.export,
              ),
              const PopupMenuItem<OptionsOptions>(
                child: Text('Delete History',
                style: TextStyle(color: Colors.red),
                ),
                value: OptionsOptions.delete,
              )
            ],
            onSelected: _options,
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'images/csembr.png',
              fit: BoxFit.contain,
              height: 17,
            ),
            Container(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text('Tags History'))
          ],
        ),
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
                            fontSize: 23.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        provider.getTags()[index].date ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        provider.getTags()[index].temperature ?? '',
                        style: TextStyle(
                          fontSize: 18.0,
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
                        'Share Tag Temperature',
                        style: TextStyle(color: Colors.green, fontSize: 20.0),
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
                        'Delete Tag',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
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
        _deleteHistory(context);
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
      ...data.map((item) => [item.id, item.date, item.temperature]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final String dir = (await getExternalStorageDirectory()).path;
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
