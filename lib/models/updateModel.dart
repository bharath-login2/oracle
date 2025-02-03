class UpdateModel {
  bool? status;
  String? message;
  Data? data;

  UpdateModel({this.status, this.message, this.data});

  UpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? currentVersion;
  String? minVersion;
  List<Server>? server;

  Data({this.currentVersion, this.minVersion, this.server});

  Data.fromJson(Map<String, dynamic> json) {
    currentVersion = json['currentVersion'];
    minVersion = json['minVersion'];
    if (json['server'] != null) {
      server = <Server>[];
      json['server'].forEach((v) {
        server!.add(Server.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentVersion'] = currentVersion;
    data['minVersion'] = minVersion;
    if (server != null) {
      data['server'] = server!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Server {
  String? name;
  String? url;

  Server({this.name, this.url});

  Server.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}