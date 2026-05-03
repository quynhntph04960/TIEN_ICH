import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../model/name_model.dart';

class ListGroupCubit extends Cubit<ListGroupState> {
  ListGroupCubit() : super(ListGroupState());

  Future getListHive() async {
    final list = boxHive.values.cast<GroupShareMoney>().toList();
    print('getListHive- ${boxHive.values.length}');

    emit(state.copyWith(listData: list));
  }
}

class ListGroupState extends Equatable {
  final List<GroupShareMoney>? listData;

  const ListGroupState({this.listData});

  @override
  // TODO: implement props
  List<Object?> get props => [listData];

  ListGroupState copyWith({List<GroupShareMoney>? listData}) {
    return ListGroupState(listData: listData ?? this.listData);
  }
}
