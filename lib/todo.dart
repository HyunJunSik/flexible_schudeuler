import 'dart:convert';

class Todo {
  int id;
  String title;
  String description;
  DateTime from;
  DateTime to;
  bool status;
  double latitude;
  double longitude;

  Todo(
      {this.id,
      this.title,
      this.description,
      this.from,
      this.to,
      this.status,
      this.latitude,
      this.longitude}) {
    id = this.id;
    title = this.title;
    description = this.description;
    from = this.from;
    to = this.to;
    status = this.status;
    latitude = this.latitude;
    longitude = this.longitude;
  }

  toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "from": from.toIso8601String(),
      "to": to.toIso8601String(),
      "status": status,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  fromJson(jsonData) {
    return Todo(
      id: jsonData['id'],
      title: jsonData['title'],
      description: jsonData['description'],
      from: DateTime.parse(jsonData['from']),
      to: DateTime.parse(jsonData['to']),
      status: jsonData['status'],
      latitude: jsonData['latitude'],
      longitude: jsonData['longitude'],
    );
  }
}
