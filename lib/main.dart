import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

//ffmpeg
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

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
  _pickFile(context) async {
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
            if (frameRateBuffer[0] != '0') {
              inputInfo["framerate"] = double.parse(frameRateBuffer[0]) /
                  double.parse(frameRateBuffer[1]);
            } else {
              inputInfo["framerate"] = double.parse(
                  information.getAllProperties()?["format"]["tags"]
                      ["com.android.capture.fps"]);
            }
            inputInfo["duration"] = information.getDuration();
            inputInfo["name"] = result.files.single.name;
            inputInfo["bitrate"] = information.getBitrate();
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File Invalid, Try again.'),
              ),
            );
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
        onPressed: () async {
          var status = await Permission.manageExternalStorage.request();
          _pickFile(context);
        },
        child: const Icon(Icons.add_a_photo_rounded),
      ),
      body: inputInfo["framerate"] == null ? const EmptyPage() : VideoInfo(),
      bottomNavigationBar:
          inputInfo["framerate"] != null ? const RenderButton() : null,
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
        Divider(
          height: 10,
        ),
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
                          fontWeight: FontWeight.bold,
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
                        '${((double.parse(inputInfo["duration"]) * 100).round()) / 100} seconds',
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
        Divider(
          height: 20,
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.add_a_photo_rounded),
            title: Text(
              'Video Info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Technical video stuff'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Framerate: ${inputInfo["framerate"]} FPS'),
            dense: true,
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Bitrate: ${inputInfo["bitrate"]} bps'),
            dense: true,
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              'Video Properties Editor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Timescale: '),
          ),
        ),
        Card(
          child: TimescaleSlider(),
        ),
        Card(
          child: ToggleSpeedChange(),
        ),
        Divider(height: 50),
      ],
    );
  }
}

class TimescaleSlider extends StatefulWidget {
  const TimescaleSlider({super.key});

  @override
  State<TimescaleSlider> createState() => _TimescaleSliderState();
}

double _speedvalue = 1;

class _TimescaleSliderState extends State<TimescaleSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _speedvalue,
      min: 0.1,
      max: 2,
      divisions: 19,
      label: 'x${((_speedvalue * 10).round() / 10)}',
      onChanged: (double value) {
        setState(() {
          _speedvalue = value;
        });
      },
    );
  }
}

class ToggleSpeedChange extends StatefulWidget {
  const ToggleSpeedChange({super.key});

  @override
  State<ToggleSpeedChange> createState() => _ToggleSpeedChangeState();
}

class _ToggleSpeedChangeState extends State<ToggleSpeedChange> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text("Speed up video based off timescale"),
      value: true,
      onChanged: (value) {},
    );
  }
}

class RenderButton extends StatefulWidget {
  const RenderButton({super.key});

  @override
  State<RenderButton> createState() => _RenderButtonState();
}

class _RenderButtonState extends State<RenderButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          print((await getExternalStorageDirectories(
                  type: StorageDirectory.downloads))
              ?.first
              .path);
          FFmpegKit.execute(
                  '-i ${inputPath} -filter "minterpolate=\'fps=120\',setpts=4*PTS" -an ${(await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first.path}/${inputPath}_new.mp4')
              .then((session) async {
            print("started");
            final returnCode = await session.getReturnCode();
            final logs = await session.getAllLogs();
            logs.forEach((element) {
              print(element.getMessage());
            });
            if (ReturnCode.isSuccess(returnCode)) {

            }
          });
        },
        child: const Text("Render"));
  }
}
