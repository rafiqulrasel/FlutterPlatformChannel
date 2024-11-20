
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelScreen extends StatefulWidget {
  const MethodChannelScreen({super.key});

  @override
  State<MethodChannelScreen> createState() => _MethodChannelScreenState();
}

class _MethodChannelScreenState extends State<MethodChannelScreen> {
  static const platform = MethodChannel("com.example.app/version");

  var _version = 'Unknown';
  var _buildNumber = 'Unknown';

  Future<void> _getVersionAndBuildNumber() async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>>('getVersionInfo');
      print("data result ${jsonEncode(result)}");
      setState(() {
        _version = result?['versionName'] ?? 'Unknown';
        _buildNumber = result?['versionCode'].toString() ?? 'Unknown';
      });
    } on PlatformException catch (e) {
      print("Failed to get version info: ${e.message}");
    }
  }
  Future<Map<String, dynamic>?> _getVersionInfo() async {
    try {
      final Map versionInfo = await platform.invokeMethod('getVersionInfo');
      return {
        'versionName': versionInfo['versionName'],
        'versionCode': versionInfo['versionCode'],
      };
    } on PlatformException catch (e) {
      print("Failed to get version info: ${e.message}");
      return null;
    }
  }
  Future<void> _sendMessageToNative(String message) async {
    try {
      await platform.invokeMethod('showToast', {"message": message});
    } on PlatformException catch (e) {
      print("Failed to send message to native: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Method Channel',
          style: TextStyle(color: Colors.white, fontSize: 28.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getVersionAndBuildNumber,
              child: Text('Get Version Info'),
            ),
            Text('Version: $_version\n'),
            Text('Build Number: $_buildNumber\n'),
        FutureBuilder<Map<String, dynamic>?>(
          future: _getVersionInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.data == null) {
              return Text("Failed to retrieve version info.");
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Version Name: ${snapshot.data!['versionName']}'),
                  Text('Version Code: ${snapshot.data!['versionCode']}'),
                ],
              );
            }
          },
        ),
            ElevatedButton(
              onPressed: () {
                _sendMessageToNative('Hello from Flutter!');
              },
              child: Text('Show Toast'),
            ),
          ],
        ),
      ),
    );
  }
}
