//   REPRESENT THE LOGGED IN USER.
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class UserModel {
  final String id;
  final String name;
  final String email;
  final double monthlyBudget;
  final DateTime createdAt;

  UserModel({
    String? id,
    required this.name,
    required this.email,
    required this.monthlyBudget,
    required this.createdAt,
  }) : id = id ?? uuid.v4();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return UserModel(
      id:id??this.id,
      name: name??this.name,
      email: email??this.email,
      monthlyBudget: monthlyBudget??this.monthlyBudget,
      createdAt: createdAt??this.createdAt,
    );
  }
  Map<String,dynamic> toJson(){
    return{
      'id':id,
      'name':name,
      'email':email,
      'monthlyBudget':monthlyBudget,
      'createdAt':createdAt.toIso8601String(),
    };
  }
  factory UserModel.fromJson(Map<String,dynamic>json){
    return UserModel(
      id:json['id'],
      name: json['name'], 
      email: json['email'], 
      monthlyBudget: (json['monthlyBudget']as num).toDouble(), 
      createdAt:DateTime.parse(json['createdAt']), 
      );

  }
}
