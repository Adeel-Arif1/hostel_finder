class FirebaseDataModel {
  FirebaseDataModel({
    required this.firebaseDataModelHostelAddress,
    required this.hostelContact,
    required this.hostelName,
    required this.hostelOwner,
    required this.hostelAddress,
    required this.address,
    required this.age,
    required this.name,
  });

  final String? firebaseDataModelHostelAddress;
  final String? hostelContact;
  final String? hostelName;
  final String? hostelOwner;
  final List<String> hostelAddress;
  final Address? address;
  final int? age;
  final String? name;

  factory FirebaseDataModel.fromJson(Map<String, dynamic> json) {
    return FirebaseDataModel(
      firebaseDataModelHostelAddress: json["hostel_address"],
      hostelContact: json["hostel_contact"],
      hostelName: json["hostel_name"],
      hostelOwner: json["hostel_owner"],
      hostelAddress: json["hostel address"] == null
          ? []
          : List<String>.from(json["hostel address"]!.map((x) => x)),
      address:
          json["address"] == null ? null : Address.fromJson(json["address"]),
      age: json["age"],
      name: json["name"],
    );
  }
}

class Address {
  Address({
    required this.line1,
  });

  final String? line1;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json["line1"],
    );
  }
}
