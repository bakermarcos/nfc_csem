import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:nfc_csem/entity/tags_entity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'entity/tags_provider.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/csembr.png',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                height: 17,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text('Tags Chart'))
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionBubble(
          items: <Bubble>[
            // Floating action menu item
            Bubble(
              title: "Home",
              iconColor: Colors.white,
              bubbleColor: Colors.blue,
              icon: Icons.home,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            //Floating action menu item
            Bubble(
              title: "History",
              iconColor: Colors.white,
              bubbleColor: Colors.blue,
              icon: Icons.history,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
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
                  yValueMapper: (TagsEntity tagsEntity, _) => double.parse(
                      '${tagsEntity.temperature.substring(22, 26)}'),
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(isVisible: true))
            ]));
  }
}
