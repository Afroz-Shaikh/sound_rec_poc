import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

class Home3 extends StatefulWidget {
  const Home3({Key? key}) : super(key: key);

  @override
  State<Home3> createState() => _Home3State();
}

class _Home3State extends State<Home3> {
  bool isRecorderReady = false;

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    isRecorderReady = true;
  }

  // chnageExt() {
  //   FFmpegKit.execute('-i file1.aac -c:v mpeg4 file2.mp4')
  //       .then((session) async {
  //     final returnCode = await session.getReturnCode();

  //     if (ReturnCode.isSuccess(returnCode)) {
  //       print('SUccess');
  //       // SUCCESS
  //     } else if (ReturnCode.isCancel(returnCode)) {
  //       // CANCEL
  //       print('FAILED');
  //     } else {
  //       // ERROR
  //     }
  //   });
  // }

  static Future<Directory?> getStorageDir() {
    if (Platform.isAndroid) {
      return getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> record() async {
    try {
      await Permission.microphone.request();
      print("Starting to RECORD");
      RecordMp3.instance.start(
          '${(await getApplicationDocumentsDirectory())!.path}/tata_ai01.mp3',
          (type) {
        print(type);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> stop() async {
    try {
      RecordMp3.instance.stop();
    } catch (e) {
      print(e);
    }
  }

  Future<void> play() async {
    final player = AudioPlayer();
    try {
      final file = File(
          '${(await getApplicationDocumentsDirectory())!.path}/tata_ai01.mp3');
      // await player.setSourceUrl(
      //   file.path,
      // );
      await player.play(DeviceFileSource(file.path));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () async {
            if (isRecorderReady) {
              await stop();
              await play();
            } else {
              await record();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  record();
                },
                child: const Icon(
                  Icons.mic,
                  size: 150,
                  color: Colors.red,
                ),
              ),
              GestureDetector(
                onTap: () {
                  stop();
                },
                child: const Icon(
                  Icons.stop,
                  size: 150,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  play();
                },
                child: const Icon(
                  Icons.play_arrow,
                  size: 150,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
