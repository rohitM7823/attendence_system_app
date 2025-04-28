import 'dart:developer';

class Employee {
  final String id;
  final String name;
  final String position;
  final String photoUrl;
  String _faceData = '';

  Employee({
    this.id = '0',
    required this.name,
    required this.position,
    required this.photoUrl,
  });

  String get faceData => _faceData;

  set faceData(String faceData) {
    this._faceData = faceData;
    log(_faceData, name: 'FACE_DATA');
  }
}

final Employee testEmployee = Employee(
  id: '1',
  name: 'Test Employee',
  position: 'Senior Developer',
  photoUrl: 'https://example.com/avatar.jpg',
);
