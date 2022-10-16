import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

class _MainPageState extends State<MainPage> {
  var inputPath;
  _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      inputPath = result.files.single.path;
      FFprobeKit.getMediaInformation(inputPath).then(
        (session) async {
          final information = await session.getMediaInformation();
          if (information != null) {
            var properties =
                information.getAllProperties()?["streams"][0]["r_frame_rate"];
            print(properties);
            print(information.getAllProperties());
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
        body: const PageContents());
  }
}

class PageContents extends StatefulWidget {
  const PageContents({super.key});

  @override
  State<PageContents> createState() => _PageContentsState();
}

class _PageContentsState extends State<PageContents> {
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
