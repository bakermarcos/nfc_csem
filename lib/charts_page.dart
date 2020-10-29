import 'package:flutter/material.dart';
import 'package:nfc_csem/entity/tags_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'entity/tags_provider.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  TagsProvider provider = TagsProvider();
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
                height: 17,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text('Tags Chart'))
            ],
          ),
        ),
        body: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            // Chart title
            title: ChartTitle(text: 'Temperature by time analyses'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              LineSeries<TagsEntity, String>(
                  dataSource: provider.getTags(),
                  xValueMapper: (TagsEntity tagsEntity, _) => tagsEntity.date,
                  yValueMapper: (TagsEntity tagsEntity, _) =>
                      double.parse(
                          '${tagsEntity.temperature.substring(22, 26)}'),
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(isVisible: true))
            ]));
  }
}
