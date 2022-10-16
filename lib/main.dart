import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//ffmpeg
import 'package:ffmpeg_kit_flutter/abstract_session.dart';
import 'package:ffmpeg_kit_flutter/arch_detect.dart';
import 'package:ffmpeg_kit_flutter/chapter.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session_complete_callback.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_session.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_session_complete_callback.dart';
import 'package:ffmpeg_kit_flutter/level.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/log_callback.dart';
import 'package:ffmpeg_kit_flutter/log_redirection_strategy.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_json_parser.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/media_information_session_complete_callback.dart';
import 'package:ffmpeg_kit_flutter/packages.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:ffmpeg_kit_flutter/signal.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:ffmpeg_kit_flutter/statistics_callback.dart';
import 'package:ffmpeg_kit_flutter/stream_information.dart';

void main() {
  runApp(const SlothApp());
}

class SlothApp extends StatelessWidget {
  const SlothApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.black,
        indicatorColor: const Color(0xff0E1D36),
        hintColor: const Color(0xff280C0B),
        highlightColor: const Color(0xff372901),
        hoverColor: const Color(0xff3A3A3B),
        focusColor: const Color(0xff0B2512),
        disabledColor: Colors.grey,
        cardColor: const Color(0xFF151515),
        canvasColor: Colors.black,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

var inputPath;
Map inputInfo = {};
var thumbnail;

class _MainPageState extends State<MainPage> {
  _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      inputPath = result.files.single.path;
      FFprobeKit.getMediaInformation(inputPath).then(
        (session) async {
          final information = await session.getMediaInformation();
          if (information != null) {
            thumbnail = await VideoThumbnail.thumbnailFile(
                video: inputPath,
                thumbnailPath: (await getTemporaryDirectory()).path,
                imageFormat: ImageFormat.JPEG);
            var frameRateString =
                information.getAllProperties()?["streams"][0]["r_frame_rate"];
            var frameRateBuffer = frameRateString.split('/');
            inputInfo["framerate"] = double.parse(frameRateBuffer[0]) /
                double.parse(frameRateBuffer[1]);
            inputInfo["duration"] = information.getDuration();
            inputInfo["name"] = result.files.single.name;
            inputInfo["bitrate"] = information.getBitrate();
            setState(() {});
          } else {
            print("Invalid file");
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
        title: const Text('Sloth'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(),
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                accountName: Text("Chenghao Li"),
                accountEmail: Text("chenghaoli36@gmail.com"),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickFile();
        },
        child: const Icon(Icons.add_a_photo_rounded),
      ),
      body: inputInfo["framerate"] == null ? EmptyPage() : VideoInfo(),
    );
  }
}

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(
            size: 60,
            Icons.add_a_photo_rounded,
          ),
          Divider(height: 20, color: Colors.black),
          Text('Press the Add Video Button to get started!'),
        ],
      ),
    );
  }
}

class VideoInfo extends StatefulWidget {
  const VideoInfo({super.key});

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Image.file(File(thumbnail),
                    fit: BoxFit.fitWidth, width: 200, height: 113),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        inputInfo["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                        ),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0)),
                      Text(
                        inputPath,
                        style: const TextStyle(fontSize: 10.0),
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.0)),
                      Text(
                        (((double.parse(inputInfo["duration"]) * 100).round()) /
                                    100)
                                .toString() +
                            ' seconds',
                        style: const TextStyle(fontSize: 10.0),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.more_vert,
                size: 16.0,
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.add_a_photo_rounded),
            title: Text('Video Info'),
            subtitle: Text('Technical video stuff'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
                'Framerate: ' + inputInfo["framerate"].toString() + " FPS"),
            dense: true,
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Bitrate: ' + inputInfo["bitrate"] + " bps"),
            dense: true,
          ),
        ),
      ],
    );
  }
}
