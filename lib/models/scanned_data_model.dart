class ScannedDataModel {
  final String itemName;
  final String itemId;

  ScannedDataModel({required this.itemName, required this.itemId});

  factory ScannedDataModel.fromJson(Map<String, dynamic> json) {
    return ScannedDataModel(
      itemName: json['itemName'],
      itemId: json['itemId'],
    );
  }
}
