import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editview.dart';
import 'todo.dart';
import 'package:intl/intl.dart';
import 'calendar.dart';

List<Marker> mymarker = [];
List<Circle> mycircle = [];

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error("Location services are disabled");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return Future.error("Location services are disabled");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  Position position = await Geolocator.getCurrentPosition();

  return position;
}

class MapPage extends StatefulWidget {
  final List<dynamic> todos;
  const MapPage({Key key, this.todos}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState(todos: todos);
}

class _MapPageState extends State<MapPage> {
  GoogleMapController googleMapController;
  List<dynamic> todos;
  SharedPreferences prefs;
  _MapPageState({this.todos});

  Future saveTodo() async {
    List items = todos.map((e) => e.toJson()).toList();
    if (items == null) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('todo', jsonEncode(items));
    });
  }

  Future reload() async {
    mymarker = [];
    mycircle = [];
    for (Todo t in todos) {
      print(t.from);
      print(t.to);
      print(t.latitude);
      print(t.longitude);
      mymarker.add(Marker(
        markerId: MarkerId('$t.id'),
        draggable: true,
        infoWindow: InfoWindow(
          title: t.title,
        ),
        position: LatLng(t.latitude, t.longitude),
      ));
      mycircle.add(Circle(
        circleId: CircleId('$t.id'),
        radius: 150.0,
        zIndex: 1,
        center: LatLng(t.latitude, t.longitude),
        fillColor: Colors.blueAccent.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
      ));
    }
    print(mymarker.length);
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  static const CameraPosition _user = CameraPosition(
    target: LatLng(37.2791, 127.9043),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _user,
        mapToolbarEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: Set.from(mymarker),
        circles: Set.from(mycircle),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => {
                _showBottomSheet(context),
              },
              icon: Icon(Icons.menu),
              color: Colors.white,
            ),
            Spacer(),
            IconButton(
              onPressed: () => {addTodo()},
              icon: Icon(Icons.add),
              color: Colors.white,
            ),
            Spacer(),
            IconButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => calendar(todos))),
              },
              icon: Icon(Icons.calendar_today),
              color: Colors.white,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        backgroundColor: Colors.indigo,
        child: Icon(
          Icons.location_history,
        ),
        onPressed: () async {
          Position position = await _determinePosition();
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 16)));
          mymarker.add(Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude)));
        },
      ),
    );
  }

  double ele = 8.0;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.blueAccent,
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: ele,
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  child: InkWell(
                    onTap: () async {
                      Todo t = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TodoView(todo: todos[index])));
                      if (t != null) {
                        setState(() {
                          todos[index] = t;
                        });
                        saveTodo();
                      }
                    },
                    child: makeListTile(todos[index], index),
                  )),
            );
          },
        ),
      ),
    );
  }

  addTodo() async {
    int id = Random().nextInt(30);
    Todo t = Todo(
        id: id,
        title: '',
        description: '',
        from: DateTime.now(),
        to: DateTime.now().add(Duration(hours: 2)),
        status: false,
        latitude: 0.0,
        longitude: 0.0);
    print('enter add todoview');
    Todo returnTodo = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoView(todo: t)));
    if (returnTodo != null) {
      print('save todo');
      setState(() {
        print('addreturn');
        todos.add(returnTodo);
      });
      reload();
      saveTodo();
    } else {
      print('dont save todo');
    }
  }

  makeListTile(Todo todo, index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
            border: Border(
          right: BorderSide(width: 1.0, color: Colors.white24),
        )),
        child: Container(
          color: Colors.deepPurple,
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm').format(todo.from),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                DateFormat('HH:mm').format(todo.to),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            todo.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 10,
          ),
          todo.status
              ? Icon(Icons.verified, color: Colors.greenAccent)
              : Container()
        ],
      ),
      subtitle: Wrap(
        children: <Widget>[
          Text(
            todo.description,
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing: InkWell(
        onTap: () {
          setState(() {
            delete(todo);
          });
        },
        child: Icon(Icons.delete, color: Colors.white, size: 30.0),
      ),
    );
  }

  Future delete(Todo todo) async {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("알림"),
              content: Text("정말 일정을 지울거에요??"),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text("좀 더 고민해볼게")),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      todos.remove(todo);
                    });
                    Navigator.pop(ctx);
                    print('delete');
                    saveTodo();
                    reload();
                  },
                  child: Text("ㅇㅇ 지울겨"),
                )
              ],
            ));
  }
}
