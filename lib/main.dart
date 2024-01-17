import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soundrec_poc/mp3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const Home3(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  // late FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await recorder.openRecorder();

    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  static Future<Directory?> getStorageDir() {
    if (Platform.isAndroid) {
      return getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future record() async {
    try {
      if (!isRecorderReady) {
        return;
      }
      await recorder.startRecorder(
          toFile:
              '${(await getStorageDir())!.path}/tata_ai${DateTime.now()}.aac');
      print('${(await getStorageDir())!.path}/tata_ai${DateTime.now()}.aac');
    } catch (e) {
      print(e);
    }
  }

  Future stop() async {
    try {
      final path = await recorder.stopRecorder();
      final audioFile = File(path!);
      print("audioFile: $audioFile");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<RecordingDisposition>(
        stream: recorder.onProgress,
        builder: (ctx, snapshot) {
          final duration = snapshot.data?.duration ?? Duration.zero;
          return Center(
            child: GestureDetector(
                onTap: () async {
                  if (recorder.isRecording) {
                    await stop();
                  } else {
                    await record();
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(duration.inSeconds.toString()),
                    const Icon(
                      Icons.mic,
                      size: 150,
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}
