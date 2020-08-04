import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      save();
      newTaskCtrl.clear();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gerenciador de tarefas")),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];
                if (item.done) {
                  return Dismissible(
                    child: CheckboxListTile(
                      title: Text(item.title,
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough)),
                      value: item.done,
                      onChanged: (value) {
                        setState(() {
                          item.done = value;
                          save();
                        });
                      },
                    ),
                    key: Key(item.title),
                    background: Container(
                      color: Colors.red.withOpacity(0.2),
                    ),
                    onDismissed: (direction) {
                      remove(index);
                    },
                  );
                } else {
                  return Dismissible(
                    child: CheckboxListTile(
                      title: Text(item.title),
                      value: item.done,
                      onChanged: (value) {
                        setState(() {
                          item.done = value;
                          save();
                        });
                      },
                    ),
                    key: Key(item.title),
                    background: Container(
                      color: Colors.red.withOpacity(0.2),
                    ),
                    onDismissed: (direction) {
                      remove(index);
                    },
                  );
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: newTaskCtrl,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Crie aqui sua tarefa'),
                ),
              )),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: add,
                color: Colors.green,
              )
            ],
          ),
        ],
      ),
    );
  }
}
