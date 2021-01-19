import 'dart:convert';

class CasesModel {
  final String code;
  final List<dynamic> results;
  final String message;

  CasesModel({
    this.code,
    this.results,
    this.message,
  });

  static CasesModel fromRawJson(String str) =>
      CasesModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  static CasesModel fromJson(dynamic json) {
    //print(json["code"]);
    return CasesModel(
      code: json["code"] as String,
      results: json["result"] as List<dynamic>,
      message: json["message"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "results": results,
        "message": message,
      };
}
