import 'dart:convert';

class ExpenseTypePending {
    bool status;
    String message;
    Data data;

    ExpenseTypePending({
        required this.status,
        required this.message,
        required this.data,
    });

    factory ExpenseTypePending.fromRawJson(String str) => ExpenseTypePending.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ExpenseTypePending.fromJson(Map<String, dynamic> json) => ExpenseTypePending(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    List<ExpenseTypeElement> expenseType;

    Data({
        required this.expenseType,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        expenseType: List<ExpenseTypeElement>.from(json["expense_type"].map((x) => ExpenseTypeElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "expense_type": List<dynamic>.from(expenseType.map((x) => x.toJson())),
    };
}

class ExpenseTypeElement {
    String expCatId;
    String expCatName;

    ExpenseTypeElement({
        required this.expCatId,
        required this.expCatName,
    });

    factory ExpenseTypeElement.fromRawJson(String str) => ExpenseTypeElement.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ExpenseTypeElement.fromJson(Map<String, dynamic> json) => ExpenseTypeElement(
        expCatId: json["ExpCatId"],
        expCatName: json["ExpCatName"],
    );

    Map<String, dynamic> toJson() => {
        "ExpCatId": expCatId,
        "ExpCatName": expCatName,
    };
}
