import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum TransactionCategory {
  food,
  transport,
  entertainment,
  health,
  shopping,
  salary,
  freelance,
  other, housing, utilities, income,
}

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type; //<---Enum
  final TransactionCategory category;
  final DateTime date;
  final String? note;//< nullable

  TransactionModel({
    String? id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
     this.note,
  }) : id = id ?? uuid.v4(); 

  //Create a copy of the Items object with optional update
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
  Map <String,dynamic> toJson(){
    return{
      'id':id,
      'title':title,
      'amount':amount,
      'type':type.name,
      'category':category.name,
      'date':date.toIso8601String(),
      'note':note,
    };
  }
  
  factory TransactionModel.fromJson(
  Map<String, dynamic> json,
) {
  return TransactionModel(
    id: json['id'],
    title: json['title'],
    amount: (json['amount'] as num).toDouble(),
    type: TransactionType.values.firstWhere(
      (type) => type.name == json['type'],
    ),
    category: TransactionCategory.values.firstWhere(
      (category) => category.name == json['category'],
    ),
    date: DateTime.parse(json['date']),
    note: json['note'],
  );
}
}
