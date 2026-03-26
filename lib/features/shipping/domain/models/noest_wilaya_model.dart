class NoestWilayaModel {
  int? id;
  String? code;
  String? name;

  NoestWilayaModel({this.id, this.code, this.name});

  NoestWilayaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code']?.toString();
    name = json['name']?.toString();
  }
}