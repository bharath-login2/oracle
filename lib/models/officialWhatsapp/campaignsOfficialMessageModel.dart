class CampaignsOfficialMessageModel {
  List<Messages>? messages;

  CampaignsOfficialMessageModel({this.messages});

  CampaignsOfficialMessageModel.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  bool? fromMe;
  String? sentTime;
  String? status;
  MessageText? messageText;

  Messages({this.fromMe, this.sentTime, this.status, this.messageText});

  Messages.fromJson(Map<String, dynamic> json) {
    fromMe = json['fromMe'];
    sentTime = json['sentTime'];
    status = json['status'];
    messageText = json['messageText'] != null
        ? new MessageText.fromJson(json['messageText'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromMe'] = this.fromMe;
    data['sentTime'] = this.sentTime;
    data['status'] = this.status;
    if (this.messageText != null) {
      data['messageText'] = this.messageText!.toJson();
    }
    return data;
  }
}

class MessageText {
  String? format;
  String? url;
  String? fileName;
  String? messageBody;
  String? footer;
  List<Buttons>? buttons;

  MessageText(
      {this.format,
        this.url,
        this.fileName,
        this.messageBody,
        this.footer,
        this.buttons});

  MessageText.fromJson(Map<String, dynamic> json) {
    format = json['format'];
    url = json['url'];
    fileName = json['fileName'];
    messageBody = json['messageBody'];
    footer = json['footer'];
    if (json['buttons'] != null) {
      buttons = <Buttons>[];
      json['buttons'].forEach((v) {
        buttons!.add(new Buttons.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['format'] = this.format;
    data['url'] = this.url;
    data['fileName'] = this.fileName;
    data['messageBody'] = this.messageBody;
    data['footer'] = this.footer;
    if (this.buttons != null) {
      data['buttons'] = this.buttons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Buttons {
  String? type;
  String? text;
  String? btnUrl;

  Buttons({this.type, this.text, this.btnUrl});

  Buttons.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    text = json['text'];
    btnUrl = json['btn_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['text'] = this.text;
    data['btn_url'] = this.btnUrl;
    return data;
  }
}