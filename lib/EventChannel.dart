import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventChannelScreen extends StatefulWidget {
  const EventChannelScreen({super.key});

  @override
  State<EventChannelScreen> createState() => _EventChannelScreenState();
}

class _EventChannelScreenState extends State<EventChannelScreen> {
  // EventChannel to communicate with native code
  static const EventChannel _eventChannel = EventChannel('com.example.app/sensorStream');
  late StreamSubscription _subscription;


  double x = 0.0, y = 0.0, z = 0.0;


  @override
  void initState() {
    super.initState();
    // Listen to the event stream for sensor data
    _subscription=_eventChannel.receiveBroadcastStream().listen((data) {
      setState(() {
        x = data['x'] ?? 0.0;
        y = data['y'] ?? 0.0;
        z = data['z'] ?? 0.0;
      });
    }, onError: (error) {
      setState(() {
        x = 0.0;
        y = 0.0;
        z = 0.0;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Channel",
          style: TextStyle(color: Colors.white, fontSize: 28.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("X: $x", style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 10,),
            Text("Y: $y",style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 10,),
            Text("Z: $z",style: TextStyle(fontSize: 20.0)),
          ],
        ),
      ),
    );
  }
}
