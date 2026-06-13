//Represents a budget limit for a specific category in a specific month.

import 'package:fintak/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';


const uuid = Uuid();

class BudgetModel {
  final String id;
  final TransactionCategory category;
  final double limit; //the max the user wants to spend in this category
  final int month; //  range is 1-12
  final int year;

  BudgetModel({
    String? id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  }) : id=id??uuid.v4();
  BudgetModel copyWith({
    String?id,
    TransactionCategory? category,
    double? limit,
    int?month,
    int?year,
  }) {
    return BudgetModel(
    id: id??this.id,
    category: category??this.category,
    limit: limit??this.limit, 
    month: month??this.month, 
    year: year??this.year
    );
  }
  // Dart object into a Map that can be turned into JSON
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'category': category.name,
    'limit': limit,
    'month': month,
    'year': year,
  };

}
      // rebuild object
  factory BudgetModel.fromJson(Map<String,dynamic>json){
    return BudgetModel(
      id:json['id'],
      category: TransactionCategory.values.firstWhere(
        (category)=>category.name==json['category']
      ), 
      limit: json['limit'],
       month: json['month'],
        year: json['year'],
        );
  }











}

//Setting range for month value 1-12
/*class Month {
  int _value;

  Month(this._value) {
    _validate(_value);
  }

  // Getter
  int get value => _value;

  // Setter
  set value(int newValue) {
    _validate(newValue);
    _value = newValue;
  }

  // Validation Logic
  void _validate(int val) {
    if (val < 1 || val > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
  }
}*/
