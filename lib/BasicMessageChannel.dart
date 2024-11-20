import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicMessageChannelScreen extends StatefulWidget {
  const BasicMessageChannelScreen({super.key});

  @override
  State<BasicMessageChannelScreen> createState() => _BasicMessageChannelScreenState();
}

class _BasicMessageChannelScreenState extends State<BasicMessageChannelScreen> {
  final BasicMessageChannel<String> _channel = const BasicMessageChannel('com.example.basic/message', StringCodec());
  static const BasicMessageChannel<dynamic> messageChannel =
  BasicMessageChannel('com.example.advanced/message', StandardMessageCodec());
  late Map<String, dynamic> returnMapData= {};
  String _response = '';
  _send() async {
    String? response = await _channel.send('Hello from Flutter!');
    setState(() {
      _response = response??'No response';
    });
  }

  Future<void> sendAdvancedMessage() async {
    // Create a Map to send
    Map<String, dynamic> message = {
      'name': 'John Doe',
      'age': 25,
      'country': 'USA',
    };

    // Send the Map and receive the response
    final dynamic response = await messageChannel.send(message);
    if (response is Map) {
      setState(() {
        returnMapData = Map<String, dynamic>.from(response);
      });
    } else {
      print('Invalid response format');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Basic Message Channel',
        style: TextStyle(color: Colors.white, fontSize: 28.0),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _send,
            child: Text('Send Message'),
          ),
          SizedBox(height: 20),
          if (_response.isNotEmpty)
          Text('Response: $_response'),
          ElevatedButton(
            onPressed: sendAdvancedMessage,
            child: Text('Send Message Map'),
          ),
          SizedBox(height: 20),
          if (returnMapData.isNotEmpty)
            ...[
              Text('Response: ${returnMapData['name']}',style: TextStyle(fontSize: 25),),
              Text('Response: ${returnMapData['age']}',style: TextStyle(fontSize: 25),),
              Text('Response: ${returnMapData['country']}',style: TextStyle(fontSize: 25),),
              Text('processed: ${returnMapData['processed']}',style: TextStyle(fontSize: 25),),
              Text('status: ${returnMapData['status']}',style: TextStyle(fontSize: 25),),
            ]
        ],
      ),
    ),
  );
}
}
