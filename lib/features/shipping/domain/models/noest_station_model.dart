class NoestStationModel {
  String? code;
  String? name;
  String? address;
  String? email;
  List<String>? phones;
  int? wilayaId;

  NoestStationModel({
    this.code,
    this.name,
    this.address,
    this.email,
    this.phones,
    this.wilayaId,
  });

  NoestStationModel.fromJson(Map<String, dynamic> json) {
  code = (json['code'] ?? json['key'] ?? json['station_code'])?.toString();
  name = (json['name'] ?? json['label'] ?? json['station_name'])?.toString();
  address = json['address']?.toString();
  email = json['email']?.toString();

  if (json['phones'] is List) {
    phones = List<String>.from(json['phones']);
  } else {
    phones = [];
  }

  wilayaId = _toInt(json['wilaya_id'] ?? json['wilaya'] ?? json['id_wilaya']);
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
}