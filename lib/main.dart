import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:FotoApp/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

final Color myColor = Color(0xff222f3e);
final Color myColor2 = Color(0xff2f3640);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> wallpapersList;
  String apiUrl = "https://api.pexels.com/v1/search?query=random&per_page=80";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    http.Response response = await http.get(
      apiUrl,
      headers: {
        HttpHeaders.authorizationHeader:
            "563492ad6f91700001000001999da5bd71d04ece9af9ba1a03e8beaf"
      },
    );
    if (response.statusCode == 200) {
      try {
        final responseJson = jsonDecode(response.body);
        wallpapersList = responseJson['photos'];
        print(wallpapersList[1]["src"]["medium"]);
      } catch (e) {
        print(e);
      }
    } else
      print(response.reasonPhrase);
  }

  @override
  Widget build(BuildContext context) {
    var tabindex = 0;
    void incrementTab(index) {
      setState(() {
        tabindex = index;
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("FotoApp"),
          backgroundColor: myColor,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
              color: Colors.white,
            )
          ],
        ),
        body: wallpapersList != null
            ? StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  String imgPath = wallpapersList[index]["src"]["medium"];
                  return Card(
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImagePath(imgPath))),
                      child: Hero(
                          tag: imgPath,
                          child: FadeInImage(
                            width: MediaQuery.of(context).size.width,
                            placeholder: AssetImage("assets/loading.gif"),
                            image: NetworkImage(imgPath),
                            fit: BoxFit.cover,
                          )),
                    ),
                  );
                },
                staggeredTileBuilder: (index) =>
                    StaggeredTile.count(2, index.isEven ? 2 : 3),
                itemCount: wallpapersList.length,
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: myColor,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: tabindex,
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.image), title: Text("Wallpapers")),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list), title: Text("Categories")),
            BottomNavigationBarItem(
                icon: Icon(Icons.info), title: Text("About"))
          ],
          onTap: (index) {
            incrementTab(index);
          },
        ),
        backgroundColor: myColor2,
      ),
    );
  }
}
