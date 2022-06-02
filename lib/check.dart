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
        appBar: AppBar(
          title: Text('Check List'),
          backgroundColor: Color(0xFF325DCE),
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: Color(0xFF3DD91B)),
              ),
              height: 120,
              child: Text(
                '일정을 수행하셨다면 체크해주세요!\n (일정에 위치도 포함되어있다면 해당 위치 300미터 이내에 사용자가 존재해야 체크가 가능합니다.)\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return Card(
                        elevation: 8.0,
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          child: InkWell(
                            onTap: () {
                              check(todos[index], index);
                            },
                            child: makeListTile(todos[index], index),
                          ),
                        ));
                  }),
            )
          ],
        ));
  }

  makeListTile(Todo todo, index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      tileColor: Color(0xFF20DC1C),
      title: Row(
        children: [
          Text(
            todo.title,
          ),
          SizedBox(
            width: 10,
          ),
          todo.status
              ? Icon(Icons.verified, color: Color(0xFF28A5D5))
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
                final snackBar = SnackBar(content: Text('일정 수행이 취소되었습니다.'));
                setState(() {
                  todo.status = false;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text("앗 아직 안했네 ㅈㅅ ㅋ!")),
          FlatButton(
              onPressed: () async {
                SnackBar yes;
                if (todo.status == false) {
                  if (todo.longitude == 0.0 && todo.latitude == 0.0) {
                    setState(() {
                      todo.status = true;
                      yes = SnackBar(content: Text('일정 수행이 완료되었습니다.'));
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
                    if (distance <= 0.3) {
                      setState(() {
                        todo.status = true;
                        yes = SnackBar(content: Text('일정 수행이 완료되었습니다.'));
                      });
                    } else {
                      yes = SnackBar(
                          content: Text(
                              '정하신 위치와 사용자의 거리가 300m 이상이므로 수행을 완료하실 수 없습니다.'));
                    }
                  }
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(yes);
              },
              child: Text("ㅇㅇ 했음"))
        ],
      ),
    );
  }
}
