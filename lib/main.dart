import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:FotoApp/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

final Color bgColor = Color(0xff0E0D0D);
final Color darkColor = Color(0xff5C5855);
final Color lightColor = Color(0xffEA5E33);

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
  static String query = "wallpapers";
  List<dynamic> wallpapersList;
  Icon searchIcon = Icon(Icons.search);
  Widget searchBar = Text("FotoApp");

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    var apiUrl =
        "https://api.pexels.com/v1/search?query=" + query + "&per_page=500";
    http.Response response = await http.get(
      apiUrl,
      headers: {
        HttpHeaders.authorizationHeader:
            "563492ad6f91700001000001999da5bd71d04ece9af9ba1a03e8beaf"
      },
    );
    print(apiUrl);
    if (response.statusCode == 200) {
      try {
        final responseJson = jsonDecode(response.body);
        setState(() {
          wallpapersList = responseJson['photos'];
        });
      } catch (e) {
        print(e);
      }
    } else
      print(response.reasonPhrase);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mystyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    var tabindex = 0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: searchBar,
          backgroundColor: bgColor,
          actions: [
            IconButton(
              icon: searchIcon,
              onPressed: () {
                setState(() {
                  if (this.searchIcon.icon == Icons.search) {
                    this.searchIcon = Icon(Icons.cancel);
                    this.searchBar = TextField(
                      textInputAction: TextInputAction.go,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.white)),
                      onSubmitted: (value) {
                        query = value;
                        initialize();
                        print(query);
                      },
                    );
                  } else {
                    this.searchIcon = Icon(Icons.search);
                    this.searchBar = Text("FotoApp");
                  }
                });
              },
              color: Colors.white,
            )
          ],
        ),
        body: wallpapersList != null
            ? StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  String imgPath = wallpapersList[index]["src"]["large"];
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
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: darkColor,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.black)),
          ),
          child: BottomNavigationBar(
            selectedItemColor: lightColor,
            unselectedItemColor: Colors.grey,
            currentIndex: tabindex,
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.image),
                  title: Text(
                    "Wallpapers",
                    style: mystyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_list),
                  title: Text(
                    "Categories",
                    style: mystyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: mystyle,
                  ))
            ],
          ),
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}
