import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'todo.dart';

class Check extends StatefulWidget {
  final List<dynamic> todos;
  Check({Key key, this.todos}) : super(key: key);

  @override
  _CheckState createState() => _CheckState(todos: todos);
}

class _CheckState extends State<Check> {
  List<dynamic> todos;
  _CheckState({this.todos});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return Card(
                elevation: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  child: InkWell(
                    onTap: () {
                      check(todos[index], index);
                    },
                    child: makeListTile(todos[index], index),
                  ),
                ));
          }),
    );
  }

  makeListTile(Todo todo, index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Row(
        children: [
          Text(
            todo.title,
          ),
          SizedBox(
            width: 10,
          ),
          todo.status
              ? Icon(Icons.verified, color: Color(0xFF8DD43F))
              : Container()
        ],
      ),
      subtitle: Wrap(
        children: <Widget>[
          Text(
            todo.description,
            overflow: TextOverflow.clip,
            maxLines: 1,
          )
        ],
      ),
    );
  }

  Future check(Todo todo, index) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("알림"),
        content: Text("이 일정을 수행하셨나요?"),
        actions: [
          FlatButton(
              onPressed: () {
                setState(() {
                  todo.status = false;
                });
                Navigator.pop(ctx);
              },
              child: Text("앗 아직 안했네 ㅈㅅ ㅋ!")),
          FlatButton(
              onPressed: () async {
                if (todo.status == false) {
                  if (todo.longitude == 0.0 && todo.latitude == 0.0) {
                    setState(() {
                      todo.status = true;
                    });
                  } else {
                    //Harversine Formula
                    Position position = await Geolocator.getCurrentPosition();
                    double radius = 6371;
                    double deltaLa =
                        radians((position.latitude - todo.latitude).abs());
                    double deltaLo =
                        radians((position.longitude - todo.longitude).abs());
                    double sindeltaLa = sin(deltaLa / 2);
                    double sindeltaLo = sin(deltaLo / 2);
                    double squareRoot = sqrt(sindeltaLo * sindeltaLa +
                        cos(radians(position.latitude)) *
                            cos(radians(todo.latitude)) *
                            sindeltaLo *
                            sindeltaLa);
                    double distance = 2 * radius * asin(squareRoot);
                    if (distance <= 0.5) {
                      setState(() {
                        todo.status = true;
                      });
                    }
                  }
                }
                Navigator.pop(ctx);
              },
              child: Text("ㅇㅇ 했음"))
        ],
      ),
    );
  }
}
