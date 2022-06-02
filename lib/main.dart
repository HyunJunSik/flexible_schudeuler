import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'check.dart';
import 'map.dart';
import 'todo.dart';

final Uri _url = Uri.parse('https://github.com/HyunJunSik/flexible_schudeuler');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key key}) : super(key: key);

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
  SharedPreferences prefs;
  List todos = [];
  setup() async {
    prefs = await SharedPreferences.getInstance();
    String stringTodo = prefs.getString('todo');
    List todoList = jsonDecode(stringTodo);
    for (var todo in todoList) {
      setState(() {
        Todo ex = Todo(
          description: "",
          longitude: 0.0,
          latitude: 0.0,
          from: DateTime.now(),
          to: DateTime.now(),
          id: 0,
          status: false,
          title: "",
        );
        ex.fromJson(todo);
        todos.add(ex);
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 100, 30, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('asset/title.jpg'),
            SizedBox(
              height: 50,
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                InkWell(
                  child: Image.asset('asset/icon_plan.jpg',
                      width: 170, height: 170),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapPage(todos: todos)));
                  },
                ),
                InkWell(
                    child: Image.asset('asset/icon_socialmedia.jpg',
                        width: 170, height: 170),
                    onTap: () {}),
              ],
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Image.asset('asset/icon_planner.jpg',
                      width: 170, height: 170),
                  onTap: () {
                    if (todos.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: Text("알림"),
                                content: Text("체크할 일정이 없습니다!"),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text("알겠슘당..."))
                                ],
                              ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Check(todos: todos)));
                    }
                  },
                ),
              ],
            ),
            //Column(
            //children: [
            //Text('후원문의'),
            //Text('정현진(국민) : 773902-01-259998'),
            //],
            //),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        children: <Widget>[
          Text('If you want this app code click button'),
          IconButton(
            icon: Icon(Icons.visibility_rounded),
            onPressed: _launchUrl,
          )
        ],
      )),
    );
  }

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }
}
