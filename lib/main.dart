import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'desiredpaper.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController t1 = new TextEditingController(text: "");
  final imagesaver = ImageSaver();

  Map wallPaperHome;

  fetchwallpaper() async {
    http.Response response = await http.get("https://api.pexels.com/v1/curated?per_page=5",
        headers: {HttpHeaders.authorizationHeader : "{YOUR API_KEY}"},
    );
    setState(() {
      wallPaperHome = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    fetchwallpaper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Wallpaper App",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.all(15),
          child: new Column(
            children: <Widget>[
              new Container(
                child: new TextField(
                  decoration: new InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(fontSize: 20,color: Colors.grey[700],fontWeight: FontWeight.bold),
                    suffixIcon: new IconButton(icon: new Icon(Icons.search,color: Colors.white,), onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ResultPage(search: t1.text,)));
                    }),
                  ),
                  controller: t1,
                ),
              ),
              new Padding(padding: const EdgeInsets.only(bottom: 10)),
              wallPaperHome == null ? new Center(
                child: new CircularProgressIndicator(),
              ) : new Container(
                padding: const EdgeInsets.all(10),
                child: new ListView.builder(
                    shrinkWrap: true,
                    itemCount: wallPaperHome.length,
                    itemBuilder: (context , index) =>
                    new Column(
                      children: <Widget>[
                        new GestureDetector(
                          child: new Image.network(wallPaperHome["photos"][index]["src"]["original"]),
                          onTap: (){
                            Future <void> saveNetworkImage() async {
                              final url = wallPaperHome["photos"][index]["src"]["original"];
                              final image = NetworkImage(url);
                              final load = image.load(key);
                              load.addListener((listener, err) async {
                                final byteData = await listener.image.toByteData(
                                 format : ImageByteFormat.png
                                );
                                final bytes = byteData.buffer.asUint8List();
                                final res = await imagesaver.saveImage(imageBytes: bytes,directoryName: "wallpaper")
                              });
                            }
                          },
                        ),
                        new Padding(padding: const EdgeInsets.only(bottom: 10)),
                      ],
                    )
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}


