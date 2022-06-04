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
    final url = Uri.parse('http://localhost:8080/eleves');
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
      final jsonString = snapshot.data!.body;
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
        body: Center(
            child: FutureBuilder<http.Response>(
          future: http.get(Uri.parse("http://localhost:8080/notes/$eleve")),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              Future.delayed(Duration(seconds: 3), () {
                Navigator.pop(context);
              });
              return const Center(
                child: Text("La récupération des infos a échouée"),
              );
            } else if (snapshot.hasData) {
              var notes = jsonDecode(snapshot.data!.body)["data"];
              return Center(
                child: NotesWidget(eleve.toString(), notes),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        )));
  }
}

class NotesWidget extends StatefulWidget {
  final List<dynamic> notes;
  final String eleve;

  const NotesWidget(this.eleve, this.notes, {Key? key}) : super(key: key);

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  double? moyenne;
  String? newNoteToAdd;

  @override
  Widget build(BuildContext context) {
    final List<Widget> columnChildren = [];

    if (moyenne != null) {
      columnChildren.add(Text("La moyenne est de $moyenne"));
    }

    for (var note in widget.notes) {
      columnChildren.add(Text(note.toString()));
    }

    columnChildren.add(TextField(onChanged: (value) => newNoteToAdd = value));
    columnChildren.add(ElevatedButton(
        onPressed: () async {
          if (newNoteToAdd == null || newNoteToAdd!.isEmpty) {
            print("Rien à ajouter");
          } else {
            http.post(Uri.parse(
                "http://localhost:8080/notes/${widget.eleve}?note=$newNoteToAdd"));
            Navigator.popAndPushNamed(context, "/eleve", arguments: widget.eleve);
          }
        },
        child: Text("Ajouter")));

    return Column(
      children: columnChildren,
    );
  }

  @override
  void initState() {
    fetchMoyenne();
  }

  Future<void> fetchMoyenne() async {
    final response = await http
        .get(Uri.parse("http://localhost:8080/moyenne/${widget.eleve}"));
    setState(() {
      moyenne = jsonDecode(response.body)["data"];
    });
  }
}
