import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'main.dart';

class WeatherPrediction extends StatefulWidget {
  @override
  _WeatherPredictionState createState() => _WeatherPredictionState();
}

class _WeatherPredictionState extends State<WeatherPrediction> {
  static final url =
      'https://api.thingspeak.com/channels/1327873/feeds.json?api_key=N6F0DZIXW82I47WW&results=2';
  var channel;
  var feeds;
  var lat = "";
  var lon = "";
  var title = "";
  int lpg = 0;
  int smoke = 0;
  int co = 0;
  Timer timer;
  bool isNotify = false;

  void showNotifications(String message) async {
    var android = AndroidNotificationDetails(
      'IoT_notif',
      'IoT_notif',
      'Channel for IoT notification',
      icon: 'iot',
      largeIcon: DrawableResourceAndroidBitmap('iot'),
    );
    var platformSpecifics = NotificationDetails(android: android);
    flip.show(0, "IoT", message, platformSpecifics);
  }

  Future<void> getResponse() async {
    var response = await http.get(url);
    Map map = json.decode(response.body) as Map;
    setState(() {
      channel = map['channel'];
      feeds = map['feeds'];

      title = channel['name'];
      lat = channel['latitude'];
      lon = channel['longitude'];

      lpg = int.parse(feeds[0]['field1']);
      co = int.parse(feeds[0]['field2']);
      smoke = int.parse(feeds[0]['field3']);
    });

    if (lpg >= 40000) {
      isNotify = true;
      showNotifications("Warning LPG Level goes high");
      vibrateDevice();
    } else if (smoke >= 10000) {
      showNotifications("Warning Smoke Level goes high");
      vibrateDevice();
      isNotify = true;
    } else if (co >= 200000) {
      showNotifications("Warning Co Level goes high");
      vibrateDevice();
      isNotify = true;
    } else {
      isNotify = false;
    }
  }

  void vibrateDevice() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
  }

  void launchUrl(String url) async {
    await canLaunch(url) ? await launch(url) : throw "Couldn't launch $url";
  }

  Widget textWidget({String text, double textSize}) {
    return Center(
      child: Text(
        "$text",
        style: TextStyle(fontSize: textSize, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getResponse());
    getResponse();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var boxSide = MediaQuery.of(context).size.width * 0.10;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isNotify ? Colors.red : Colors.green,
        title: Text(
          title,
          style: TextStyle(fontSize: boxSide * 0.50),
        ),
        centerTitle: true,
      ),
      body: feeds == null && channel == null
          ? Center(
              child: Text(
                'Fetching Data Please Wait....',
                style: TextStyle(fontSize: boxSide * 0.70),
                textAlign: TextAlign.center,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                isNotify ? Colors.red : Colors.green,
                Colors.white
              ], begin: Alignment.topCenter)),
              child: ListView(
                children: [
                  SizedBox(
                    height: boxSide,
                    width: boxSide,
                  ),
                  textWidget(text: 'Lpg : $lpg', textSize: boxSide * 0.70),
                  SizedBox(
                    height: boxSide,
                    width: boxSide,
                  ),
                  textWidget(text: 'Co : $co', textSize: boxSide * 0.70),
                  SizedBox(
                    height: boxSide,
                    width: boxSide,
                  ),
                  textWidget(text: 'Smoke : $smoke', textSize: boxSide * 0.70),
                  SizedBox(
                    height: boxSide,
                    width: boxSide,
                  ),
                  Container(
                    height: boxSide * 2.5,
                    width: boxSide * 2.5,
                    child: MaterialButton(
                      child: Image.asset('images/map.png'),
                      onPressed: () {
                        launchUrl("https://maps.google.com/?q=$lat,$lon");
                      },
                    ),
                  ),
                  SizedBox(
                    height: boxSide,
                    width: boxSide,
                  ),
                ],
              ),
            ),
    );
  }
}
