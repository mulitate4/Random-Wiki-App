// ignore_for_file: avoid_print

// todo
// - Change theme to dark mode
// - Add an option for simple.wiki (?)
// - Allow query input

import 'dart:convert';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class WikiArticle {
  final int pageID;
  final String title;

  WikiArticle({required this.pageID, required this.title});

  factory WikiArticle.fromJSON(Map<String, dynamic> json) {
    return WikiArticle(pageID: json["pageID"], title: json["title"]);
  }
}

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({Key? key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  // =========== //
  // MEMBER VARS //
  // =========== //
  List articleIDs = [];
  late Future<List<WikiArticle>> _articles;
  String urlSeperator = "%7C";
  final RefreshController _refreshController = RefreshController();
  final List<String> _excludeList = [
    "Talk",
    "User talk",
    "User",
    "Wikipedia",
    "Category",
    "File",
    "Portal",
    "Category talks"
  ];

  // ================ //
  // HELPER FUNCTIONS //
  // ================ //
  // Get 10 Random IDS ranging
  // from the number of wikipedia
  // articles
  List<int> getRandomIds() {
    List<int> randomIds = [];
    Random random = Random();

    for (int i = 1; i <= 30; i++) {
      int id = random.nextInt(21529208);
      randomIds.add(id);
    }

    return randomIds;
  }

  // Get a Promise/Future with
  // List of WikiPedia Articles
  Future<List<WikiArticle>> getArticles() async {
    List<int> ids = getRandomIds();
    String concatenatedIds = ids.join(urlSeperator);
    List<WikiArticle> articles = [];

    while (articles.length < 10) {
      Uri url = Uri.parse(
          "https://en.wikipedia.org/w/api.php?action=query&format=json&pageids=$concatenatedIds");
      http.Response response = await http.get(url);
      Map data = json.decode(response.body);
      Map pages = data["query"]["pages"];

      // Serialize the JSON data into <WikiArticle>
      pages.forEach((key, value) {
        if (value.containsKey("title")) {
          if (!_excludeList.contains(value["title"].split(":")[0])) {
            WikiArticle article =
                WikiArticle(pageID: value["pageid"], title: value["title"]);
            articles.add(article);
          }
        }
      });
    }

    return articles;
  }

  // Refresh list of articles
  void refreshArticles() {
    setState(() {
      // this still gives a future.
      // The future builder handles futures itself
      _articles = getArticles();
    });
  }

  // ========== //
  // INITIALIZE //
  // ========== //
  @override
  void initState() {
    super.initState();
    _articles = getArticles();
  }

  // == //
  // UI //
  // == //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                refreshArticles();
              },
              icon: const Icon(Icons.refresh))
        ],
        title: const Text("Wiki Random"),
      ),
      body: FutureBuilder<List<WikiArticle>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _refreshController.refreshCompleted();
            return SmartRefresher(
                onRefresh: () {
                  refreshArticles();
                },
                controller: _refreshController,
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(snapshot.data![index].title),
                          onTap: () async {
                            int articlePageId = snapshot.data![index].pageID;
                            String wikiUrl =
                                "http://en.wikipedia.org/?curid=$articlePageId";
                            if (await canLaunch(wikiUrl)) {
                              await launch(wikiUrl);
                            }
                          },
                        ),
                      );
                    }));
          } else if (snapshot.hasError) {
            return const Text("An Error Occured, Please, try again.");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
