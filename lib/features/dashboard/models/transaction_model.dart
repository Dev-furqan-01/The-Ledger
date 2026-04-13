import 'package:flutter/material.dart';

enum TransactionType { debit, credit }

class TransactionModel {
  final int? id;
  final String title;
  final DateTime date;
  final String category;
  final double amount;
  final TransactionType type;
  final IconData icon;

  const TransactionModel({
    this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.amount,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'type': type.index,
      'icon': icon.codePoint,
    };
  }

  static IconData getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shop':
        return Icons.shopping_bag;
      case 'Travel':
        return Icons.commute;
      case 'Bills':
        return Icons.receipt_long;
      case 'Health':
        return Icons.medical_services;
      case 'Salary':
        return Icons.payments;
      case 'Business':
        return Icons.work;
      case 'Other':
      default:
        return Icons.more_horiz;
    }
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      icon: getIconForCategory(map['category']),
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? category,
    double? amount,
    TransactionType? type,
    IconData? icon,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}
