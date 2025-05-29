// filepath: c:\Sujoy\Personal\moneyclone\money_app\money_clone\lib\data\models.dart

enum TransactionType { income, expense, transfer }

enum PaymentMethod { cash, creditCard, debitCard, bankTransfer, other }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? category;
  final String? description;
  final PaymentMethod paymentMethod;
  final String? accountId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.category,
    this.description,
    required this.paymentMethod,
    this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod.toString(),
      'accountId': accountId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => TransactionType.expense),
      category: map['category'],
      description: map['description'],
      paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.toString() == map['paymentMethod'],
          orElse: () => PaymentMethod.other),
      accountId: map['accountId'],
    );
  }
}

class Account {
  final String id;
  final String name;
  final double balance;
  final String? accountNumber;
  final String? bankName;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    this.accountNumber,
    this.bankName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'accountNumber': accountNumber,
      'bankName': bankName,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      accountNumber: map['accountNumber'],
      bankName: map['bankName'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? icon;
  final TransactionType type;

  Category({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toString(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      type: TransactionType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => TransactionType.expense),
    );
  }
}
