class PersonRecord {
  final int? id;
  final int number;
  final String name;
  final String residence;
  final double amount;
  final double? year1444;
  final String? year1444Status;
  final double? year1445;
  final String? year1445Status;
  final double? year1446;
  final String? year1446Status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PersonRecord({
    this.id,
    required this.number,
    required this.name,
    required this.residence,
    required this.amount,
    this.year1444,
    this.year1444Status,
    this.year1445,
    this.year1445Status,
    this.year1446,
    this.year1446Status,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  double get totalReceivedAmount {
    double total = 0;
    if (year1444 != null) total += year1444!;
    if (year1445 != null) total += year1445!;
    if (year1446 != null) total += year1446!;
    return total;
  }

  double get remainingAmount {
    return amount - totalReceivedAmount;
  }

  bool get isFullyPaid => remainingAmount <= 0;

  int get activeYearsCount {
    int count = 0;
    if (year1444 != null) count++;
    if (year1445 != null) count++;
    if (year1446 != null) count++;
    return count;
  }

  String get paymentStatus {
    if (isFullyPaid) return 'مكتمل';
    if (activeYearsCount == 0) return 'لم يبدأ';
    return 'جزئي';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'residence': residence,
      'amount': amount,
      'year1444': year1444,
      'year1444Status': year1444Status,
      'year1445': year1445,
      'year1445Status': year1445Status,
      'year1446': year1446,
      'year1446Status': year1446Status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PersonRecord.fromMap(Map<String, dynamic> map) {
    return PersonRecord(
      id: map['id'],
      number: map['number'],
      name: map['name'],
      residence: map['residence'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      year1444: map['year1444'] != null ? (map['year1444'] as num).toDouble() : null,
      year1444Status: map['year1444Status'],
      year1445: map['year1445'] != null ? (map['year1445'] as num).toDouble() : null,
      year1445Status: map['year1445Status'],
      year1446: map['year1446'] != null ? (map['year1446'] as num).toDouble() : null,
      year1446Status: map['year1446Status'],
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }

  PersonRecord copyWith({
    int? id,
    int? number,
    String? name,
    String? residence,
    double? amount,
    double? year1444,
    String? year1444Status,
    double? year1445,
    String? year1445Status,
    double? year1446,
    String? year1446Status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonRecord(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      residence: residence ?? this.residence,
      amount: amount ?? this.amount,
      year1444: year1444 ?? this.year1444,
      year1444Status: year1444Status ?? this.year1444Status,
      year1445: year1445 ?? this.year1445,
      year1445Status: year1445Status ?? this.year1445Status,
      year1446: year1446 ?? this.year1446,
      year1446Status: year1446Status ?? this.year1446Status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'PersonRecord(id: $id, name: $name, amount: $amount)';
}
