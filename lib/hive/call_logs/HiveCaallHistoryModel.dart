import 'package:hive/hive.dart';

part 'HiveCaallHistoryModel.g.dart';

@HiveType(typeId: 1)
class HiveCaallHistoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String callType;

  @HiveField(4)
  final String duration;

  @HiveField(5)
  final String timeStamp;

  @HiveField(6)
  final String simSlot;

  @HiveField(7)
  final String callRecordFilePath;

  @HiveField(8)
  final bool isUploaded;

  @HiveField(9)
  final bool isDeleted;
  
  @HiveField(10)
  final bool isEnabled;

  HiveCaallHistoryModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.callType,
    required this.duration,
    required this.timeStamp,
    required this.simSlot,
    required this.callRecordFilePath,
    required this.isUploaded,
    required this.isDeleted,
    required this.isEnabled,
  });
}
