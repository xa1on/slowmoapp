import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

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
  void _fetchVideo() async {
    final PermissionState requestPerms =
        await PhotoManager.requestPermissionExtend();
    if (requestPerms.isAuth) {
      print("Granted");
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
            _fetchVideo();
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
