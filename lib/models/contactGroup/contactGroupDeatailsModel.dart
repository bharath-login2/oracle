class ContactGroupDeatailsModel {
  bool? status;
  String? message;
  Data? data;

  ContactGroupDeatailsModel({this.status, this.message, this.data});

  ContactGroupDeatailsModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? teamId;
  String? name;
  String? contactNos;
  List<Messages>? messages;

  Data({this.id, this.teamId, this.name, this.contactNos, this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    teamId = json['team_id'];
    name = json['name'];
    contactNos = json['contact_nos'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['team_id'] = teamId;
    data['name'] = name;
    data['contact_nos'] = contactNos;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? id;
  String? timePost;
  String? caption;
  String? media;
  bool? isImage;

  Messages({this.id, this.timePost, this.caption, this.media, this.isImage});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    timePost = json['time_post'];
    caption = json['caption'];
    media = json['media'];
    isImage = json['is_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['time_post'] = timePost;
    data['caption'] = caption;
    data['media'] = media;
    data['is_image'] = isImage;
    return data;
  }
}