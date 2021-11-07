// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

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

  // ================ //
  // HELPER FUNCTIONS //
  // ================ //
  List<int> getRandomIds() {
    List<int> randomIds = [];
    Random random = Random();

    for (int i = 1; i <= 10; i++) {
      int id = random.nextInt(21529208);
      randomIds.add(id);
    }

    return randomIds;
  }

  // Get list of random articles
  Future<List<WikiArticle>> getArticles() async {
    Uri url = Uri.parse(
        "https://en.wikipedia.org/w/api.php?action=query&format=json&pageids=4445%7C251");
    http.Response response = await http.get(url);
    Map data = json.decode(response.body);
    Map pages = data["query"]["pages"];

    List<WikiArticle> articles = [];

    pages.forEach((key, value) {
      WikiArticle article =
          WikiArticle(pageID: value["pageid"], title: value["title"]);
      articles.add(article);
    });

    return articles;
  }

  @override
  void initState() {
    super.initState();
    getArticles();
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
              onPressed: () async {
                await getArticles();
              },
              icon: const Icon(Icons.refresh))
        ],
        title: const Text("Articles"),
      ),
      body: ListView(),
    );
  }
}
