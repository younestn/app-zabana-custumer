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
    code = json['code']?.toString();
    name = json['name']?.toString();
    address = json['address']?.toString();
    email = json['email']?.toString();
    phones = json['phones'] != null ? List<String>.from(json['phones']) : [];
    wilayaId = json['wilaya_id'];
  }
}