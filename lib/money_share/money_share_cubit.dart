import 'package:demo2/money_share/model/name_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

class MoneyShareCubit extends Cubit<MoneyShareState> {
  MoneyShareCubit() : super(MoneyShareState());

  void addLineMoney(NameModel data, int index) {
    final names = List<NameModel>.from(state.names).map((e) {
      if (data.id == e.id) {
        final moneys = e.listMoney ?? [];
        moneys.insert(0, MoneyModel());
        print('MoneyShareCubit.addLineMoney');
        return e.copyWith(listMoney: moneys);
      }
      return e;
    }).toList();
    emit(state.copyWith(names: names));
  }

  void addFriend(NameModel? data) {
    if (data == null) return;
    final names = List<NameModel>.from(state.names);
    names.insert(0, data.copyWith(id: state.names.length + 1));
    emit(state.copyWith(names: names));
  }

  void updateFriend(NameModel? data) {
    if (data?.id == null) return;
    final newList = state.names.map((e) {
      if (data?.id == e.id) {
        return data!;
      }
      return e;
    }).toList();
    emit(state.copyWith(names: newList));
  }

  int tongTienChi() {
    int total = state.names.fold(0, (prev, data) {
      return prev +
          (data.listMoney?.where((e) => e.isCollected != true).fold(0, (
                p,
                money,
              ) {
                return (p ?? 0) + (money.money ?? 0);
              }) ??
              0);
    });
    return total;
  }

  int tongTienThu() {
    int total = state.names.fold(0, (prev, data) {
      return prev +
          (data.listMoney?.where((e) => e.isCollected == true).fold(0, (
                p,
                money,
              ) {
                return (p ?? 0) + (money.money ?? 0);
              }) ??
              0);
    });
    return total;
  }

  double chiaDeuMoiNguoi() {
    final member = state.names.length;
    if (member == 0) return 0;

    return (tongTienChi() - tongTienThu()) / member;
  }

  void deleteFriend(NameModel data) {
    final names = List<NameModel>.from(state.names);
    names.removeWhere((e) => e.id == data.id);

    emit(state.copyWith(names: names));
  }

  Future saveGroupMoney(String? name) async {
    if (name == null) {
      print('Null name group table');
      return;
    }

    if (state.names.length <= 0) {
      print('Null name share money');
      return;
    }

    final boxHive = await Hive.openBox<GroupShareMoney>('ShareMoney');
    final group = GroupShareMoney(
      name: name,
      users: List<NameModel>.from(state.names),
    );

    try {
      await boxHive.add(group);
      print('MoneyShareCubit.saveGroupMoney create');
    } catch (e) {
      print('MoneyShareCubit.saveGroupMoney - $e');
    }
  }
}

class MoneyShareState extends Equatable {
  final List<NameModel> names;

  const MoneyShareState({this.names = const []});

  @override
  // TODO: implement props
  List<Object?> get props => [names];

  MoneyShareState copyWith({List<NameModel>? names}) {
    return MoneyShareState(names: names ?? this.names);
  }
}
