import 'package:meta/meta.dart';
import 'dart:convert';

class ReceivedThroughModel {
    String status;
    List<ReceivedThrough> data;

    ReceivedThroughModel({
        required this.status,
        required this.data,
    });

    factory ReceivedThroughModel.fromRawJson(String str) => ReceivedThroughModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ReceivedThroughModel.fromJson(Map<String, dynamic> json) => ReceivedThroughModel(
        status: json["status"],
        data: List<ReceivedThrough>.from(json["data"].map((x) => ReceivedThrough.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ReceivedThrough {
    String recievedTruId;
    String recievedThrough;

    ReceivedThrough({
        required this.recievedTruId,
        required this.recievedThrough,
    });

    factory ReceivedThrough.fromRawJson(String str) => ReceivedThrough.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ReceivedThrough.fromJson(Map<String, dynamic> json) => ReceivedThrough(
        recievedTruId: json["recieved_tru_id"],
        recievedThrough: json["recieved_through"],
    );

    Map<String, dynamic> toJson() => {
        "recieved_tru_id": recievedTruId,
        "recieved_through": recievedThrough,
    };
}
