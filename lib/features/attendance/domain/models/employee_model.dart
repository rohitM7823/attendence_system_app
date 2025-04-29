
class Employee {
  final String? id;
  final String? name;
  final String? position;
  final String? photoUrl;
  final String? faceData;

  Employee({
    this.id = '0',
    required this.name,
    required this.position,
    required this.photoUrl,
    required this.faceData,
  });


  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json["emp_id"],
      name: json["name"],
      position: json["position"],
      photoUrl: json["photoUrl"],
      faceData: json["face_metadata"],
    );
  }
//
}

