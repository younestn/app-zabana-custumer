class NoestWilayaModel {
  int? id;
  String? code;
  String? name;

  NoestWilayaModel({this.id, this.code, this.name});

  NoestWilayaModel.fromJson(Map<String, dynamic> json) {
    code = (json['code'] ?? json['key'] ?? json['wilaya_code'])?.toString();
    name = (json['name'] ?? json['label'] ?? json['wilaya_name'])?.toString();

    id = _toInt(
      json['id'] ??
      json['wilaya_id'] ??
      json['key'] ??
      json['code'],
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}