import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gas_prediction/weather.dart';

final FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var android = AndroidInitializationSettings('iot');
  var settings = InitializationSettings(android: android);
  await flip.initialize(settings, onSelectNotification: (String payload) async {
    if (payload != null) {
      print("notification payload: $payload");
    }
  });
  runApp(
    MaterialApp(
      title: 'WeatherPrediction',
      debugShowCheckedModeBanner: false,
      home: WeatherPrediction(),
    ),
  );
}
