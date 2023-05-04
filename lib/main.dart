import 'dart:convert';
import 'dart:io';
import 'package:api_example/details_wallaper.dart';
import 'package:api_example/model/color_model.dart';
import 'package:api_example/model/wallpaper_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpClient;

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
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Wallpaer> wallpaper;
  var searchContrroler = TextEditingController();
  bool isMobile = false;
  List<ColorModel> arrayColors = [];

  @override
  void initState() {
    super.initState();
    wallpaper = getVwallpaper('Car');
    arrayColors.add(ColorModel(
        name: 'Orange', hexcode: 'F14747', mColor: Color(0xFFF14747)));
    arrayColors.add(
        ColorModel(name: 'Blue', hexcode: '391AEC', mColor: Color(0xFF391AEC)));
    arrayColors.add(ColorModel(
        name: 'Green', hexcode: 'CAFF37', mColor: Color(0xFFCAFF37)));
  }

  Future<Wallpaer> getVwallpaper(String mQuery, {String? Colorcode}) async {
    var mUrl =
        "https://api.pexels.com/v1/search?query=$mQuery&per_page=15&color=${Colorcode ?? ""}";
    var responce = await httpClient.get(Uri.parse(mUrl), headers: {
      'Authorization':
          'bQ5T0u3fMl4xx3vj65Ql0YPNWlBWFyI9RT2RHS5CqybR0Qe7ZXxYsFCN'
    });
    if (responce.statusCode == 200) {
      var data = jsonDecode(responce.body);
      return Wallpaer.fromJson(data);
    } else {
      return Wallpaer();
    }
  }

  @override
  Widget build(BuildContext context) {
    isMobile = Platform.isAndroid || Platform.isIOS;
    return Scaffold(
      appBar: AppBar(
        title: Text("app"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchContrroler,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  hintText: 'search....',
                  suffixIcon: InkWell(
                      onTap: () {
                        wallpaper =
                            getVwallpaper(searchContrroler.text.toString());
                        setState(() {});
                      },
                      child: Icon(Icons.search))),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: arrayColors.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      wallpaper = getVwallpaper(
                          searchContrroler.text.toString() == ""
                              ? 'horse'
                              : searchContrroler.text.toString(),
                          Colorcode: arrayColors[index].hexcode);
                      setState(() {});
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21),
                        color: arrayColors[index].mColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Wallpaer>(
              future: wallpaper,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    itemCount: snapshot.data!.photos!.length,
                    gridDelegate: isMobile
                        ? SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 9 / 16,
                            mainAxisSpacing: 11,
                            crossAxisSpacing: 11)
                        : SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 16 / 9,
                            mainAxisSpacing: 11,
                            crossAxisSpacing: 11),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return DetailWallpaer(
                                url: isMobile
                                    ? snapshot
                                        .data!.photos![index].src!.portrait!
                                    : snapshot
                                        .data!.photos![index].src!.landscape!,
                              );
                            },
                          ));
                        },
                        child: Image.network(
                          isMobile
                              ? snapshot.data!.photos![index].src!.portrait!
                              : snapshot.data!.photos![index].src!.landscape!,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
