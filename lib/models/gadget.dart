import 'package:hive/hive.dart';

part 'gadget.g.dart';

@HiveType(typeId: 0)
class Gadget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Map<String, dynamic>? data;

  @HiveField(3)
  String? imagePath;

  Gadget({
    required this.id,
    required this.name,
    this.data,
    this.imagePath,
  });

  factory Gadget.fromJson(Map<String, dynamic> json) => Gadget(
        id: json['id'].toString(),
        name: json['name'],
        data: (json['data'] is Map)
            ? Map<String, dynamic>.from(json['data'])
            : null,
        imagePath: json['imagePath'],
      );

  Map<String, dynamic> toApiJson() => {
        'name': name,
        'data': data,
      };
}