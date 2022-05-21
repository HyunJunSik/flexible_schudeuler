import 'package:flutter/material.dart';
import 'big_map.dart';
import 'utils.dart';
import 'todo.dart';

const String API_KEY = "AIzaSyAfbPk9W48RAmUhPUCJ_9e79OV5F5lAiXA";

String getStaticMap(double latitude, double longitude) {
  return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$API_KEY';
}

class TodoView extends StatefulWidget {
  Todo todo;
  TodoView({Key key, this.todo}) : super(key: key);

  @override
  _TodoViewState createState() => _TodoViewState(todo: todo);
}

class _TodoViewState extends State<TodoView> {
  Todo todo;
  _TodoViewState({this.todo});
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool mapLoading = false;
  String mapImageUrl;
  Map pickedLoc = {};

  _pickLocation() async {
    pickedLoc = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BigMap(),
      fullscreenDialog: true,
    ));

    if (pickedLoc == null) return;
    setState(() {
      todo.latitude = pickedLoc['latitude'];
      todo.longitude = pickedLoc['longitude'];
      mapLoading = true;
    });

    final staticImageUrl =
        getStaticMap(pickedLoc['latitude'], pickedLoc['longitude']);

    setState(() {
      mapImageUrl = staticImageUrl;
      mapLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (todo != null) {
      titleController.text = todo.title;
      descriptionController.text = todo.description;
      todo.from = todo.from;
      todo.to = todo.to;
      if (todo.latitude != 0.0 && todo.longitude != 0.0) {
        setState(() {
          mapLoading = true;
          final staticImageUrl = getStaticMap(todo.latitude, todo.longitude);
        });
      }
    }
    print(todo.latitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title: Text("Todo View"),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                        child: colorOverride(TextField(
                      onChanged: (data) {
                        todo.title = data;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "제목",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      controller: titleController,
                    ))),
                    SizedBox(
                      height: 25,
                    ),
                    Column(
                      children: <Widget>[
                        buildDateTimePicker(),
                      ],
                    ),
                    Container(
                        child: colorOverride(TextField(
                      maxLines: 3,
                      onChanged: (data) {
                        todo.description = data;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "설명",
                        hintText: "어떤 계획을 가지고 계신가요?",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      controller: descriptionController,
                    ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: mapImageUrl == null
                          ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.grey),
                                    onPressed: _pickLocation,
                                  ),
                                  Text('장소를 선택하려면 + 아이콘을 탭하세요'),
                                ]))
                          : mapLoading
                              ? Center(child: CircularProgressIndicator())
                              : Image.network(mapImageUrl,
                                  width: double.infinity, fit: BoxFit.cover),
                    )
                  ],
                ))),
        bottomNavigationBar: SizedBox(
            height: 55.0,
            child: BottomAppBar(
                color: Color.fromRGBO(58, 66, 86, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    VerticalDivider(
                      color: Colors.white,
                    ),
                    IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context, todo);
                        })
                  ],
                ))));
  }

  Widget buildDateTimePicker() => Column(children: [
        buildFrom(),
        buildTo(),
      ]);

  Widget buildHeader({String header, Widget child}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          header,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        child,
      ]);

  Widget buildDropdownField({
    String text,
    VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildFrom() => buildHeader(
      header: 'FROM',
      child: Row(children: [
        Expanded(
          flex: 2,
          child: buildDropdownField(
            text: Utils.toDate(todo.from),
            onClicked: () => pickFromDateTime(pickDate: true),
          ),
        ),
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(todo.from),
            onClicked: () => pickFromDateTime(pickDate: false),
          ),
        )
      ]));

  Widget buildTo() => buildHeader(
      header: 'TO',
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: buildDropdownField(
                text: Utils.toDate(todo.to),
                onClicked: () => pickToDateTime(pickDate: true)),
          ),
          Expanded(
              child: buildDropdownField(
            text: Utils.toTime(todo.to),
            onClicked: () => pickToDateTime(pickDate: false),
          ))
        ],
      ));

  Future pickFromDateTime({bool pickDate}) async {
    final date = await pickDateTime(todo.from, pickDate: pickDate);
    if (date == null) return;

    if (date.isAfter(todo.to)) {
      todo.to = DateTime(
          date.year, date.month, date.day, todo.to.hour, todo.to.minute);
    }
    setState(() => todo.from = date);
  }

  Future pickToDateTime({bool pickDate}) async {
    final date = await pickDateTime(
        DateTime(todo.to.year, todo.to.month, todo.to.day, todo.to.hour,
            todo.to.minute),
        pickDate: pickDate,
        firstDate: pickDate ? todo.from : null);
    if (date == null) return;

    setState(() => todo.to = date);
  }

  Future<DateTime> pickDateTime(
    DateTime initialDate, {
    bool pickDate,
    DateTime firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) return null;

      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }

  Widget colorOverride(Widget child) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.white,
        hintColor: Colors.white,
      ),
      child: child,
    );
  }
}
