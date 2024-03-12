class ScannedDataModel {
  final int id;
  final String deviceName;

  ScannedDataModel({required this.id, required this.deviceName});

  factory ScannedDataModel.fromJson(Map<String, dynamic> json) {
    return ScannedDataModel(
      id: json['id'],
      deviceName: json['deviceName'],
    );
  }
}
