import 'package:hive/hive.dart';

part 'gadget.g.dart';

@HiveType(typeId: 0)
class Gadget extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  Map<String, dynamic> data;
  @HiveField(3)
  String? imagePath;

  Gadget({
    required this.id,
    required this.name,
    required this.data,
    this.imagePath,
  });

  factory Gadget.fromJson(Map<String, dynamic> json) {
    return Gadget(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      data: json['data'] ?? <String, dynamic>{},
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toApiJson() => {
        'id': id,
        'name': name,
        'data': data,
        'imagePath': imagePath,
      };
}