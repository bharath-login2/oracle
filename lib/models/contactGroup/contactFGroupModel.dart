class ContactGroupModel {
  bool? status;
  String? message;
  Data? data;

  ContactGroupModel({this.status, this.message, this.data});

  ContactGroupModel.fromJson(Map<String, dynamic> json) {
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
  bool? isConfigured;
  List<ListGroup>? listGroup;

  Data({this.isConfigured, this.listGroup});

  Data.fromJson(Map<String, dynamic> json) {
    isConfigured = json['is_configured'];
    if (json['list_group'] != null) {
      listGroup = <ListGroup>[];
      json['list_group'].forEach((v) {
        listGroup!.add(ListGroup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_configured'] = isConfigured;
    if (listGroup != null) {
      data['list_group'] = listGroup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListGroup {
  String? id;
  String? name;
  String? lastMessage;
  String? timePost;
  String? image;

  ListGroup({this.id, this.name, this.lastMessage, this.timePost, this.image});

  ListGroup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lastMessage = json['last_message'];
    timePost = json['time_post'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['last_message'] = lastMessage;
    data['time_post'] = timePost;
    data['image'] = image;
    return data;
  }
}