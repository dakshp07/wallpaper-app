import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'desiredpaper.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

class ResultPage extends StatefulWidget {

  String search;
  ResultPage({this.search});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  final imagesaver = ImageSaver();
  Map wallpaperSearch;
  fetchData() async {
    http.Response response = await http.get("https://api.pexels.com/v1/search?query="+widget.search,
        headers:{HttpHeaders.authorizationHeader : "{YOUR API_KEY}"});
    setState(() {
      wallpaperSearch = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.search.toUpperCase(),style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.all(15),
          child: new Column(
            children: <Widget>[
              wallpaperSearch == null ? new Center(
                child: new CircularProgressIndicator(),
              ) : new Container(
                padding: const EdgeInsets.all(10),
                child: new ListView.builder(
                  shrinkWrap: true,
                    itemCount: wallpaperSearch.length,
                    itemBuilder: (context , index) =>
                        new Column(
                          children: <Widget>[
                            new GestureDetector(
                              child: new Image.network(wallpaperSearch["photos"][index]["src"]["original"]),
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
      ),
    );
  }
}
