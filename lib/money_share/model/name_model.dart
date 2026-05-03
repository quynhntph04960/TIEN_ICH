import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'name_model.g.dart';

@HiveType(typeId: 0)
class GroupShareMoney extends Equatable {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<NameModel> users;

  GroupShareMoney({required this.name, required this.users});

  @override
  // TODO: implement props
  List<Object?> get props => [name, users];
}

@HiveType(typeId: 1)
class NameModel extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<MoneyModel>? listMoney;

  const NameModel({required this.id, required this.name, this.listMoney});

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, listMoney];

  @override
  String toString() {
    return 'NameModel{id: $id, name: $name, listMoney: $listMoney}';
  }

  NameModel copyWith({int? id, String? name, List<MoneyModel>? listMoney}) {
    return NameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      listMoney: listMoney ?? this.listMoney,
    );
  }
}

@HiveType(typeId: 2)
class MoneyModel extends Equatable {
  @HiveField(0)
  final int? money;
  @HiveField(1)
  final String? title;
  @HiveField(2)
  final bool isCollected; // true là thu, false là chi

  const MoneyModel({this.money, this.isCollected = false, this.title});

  @override
  // TODO: implement props
  List<Object?> get props => [money, isCollected, title];

  MoneyModel copyWith({int? money, String? title, bool? isCollected}) {
    return MoneyModel(
      money: money ?? this.money,
      title: title ?? this.title,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}
