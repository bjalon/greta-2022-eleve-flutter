import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MaterialApp(home: MyApp(), routes: {
    "/eleve": (context) {
      return EleveView();
    }
  }));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('http://192.168.68.101:8080/eleves');
    // var url = Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste élèves"),
      ),
      body: FutureBuilder<http.Response>(
          future: http.get(url), builder: futureManager),
    );
  }

  Widget futureManager(BuildContext context, dynamic snapshot) {
    if (snapshot.hasError) {
      print(snapshot.error);
      return const Center(child: Text("Une erreur serveur s'est produite"));
    } else if (snapshot.hasData) {
      final jsonString = snapshot.data!.body.replaceAll("'", "\"");
      final json = jsonDecode(jsonString);

      return Center(child: ElevesWidget(json["data"]));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class ElevesWidget extends StatelessWidget {
  final List<dynamic> eleves;

  const ElevesWidget(this.eleves, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> listEleve = [];
    for (var eleve in eleves) {
      listEleve.add(TextButton(
          onPressed: () {
            Navigator.pushNamed(context, "/eleve", arguments: eleve);
          },
          child: Text(eleve)));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: listEleve);
  }
}

class EleveView extends StatelessWidget {
  const EleveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var eleve = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
        appBar: AppBar(title: Text("Eleve : $eleve")),
        body: Center(child: Text("Info de $eleve")));
  }
}
