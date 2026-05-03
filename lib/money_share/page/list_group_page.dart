import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list_group_cubit.dart';

class ListGroupPage extends StatefulWidget {
  const ListGroupPage({super.key});

  @override
  State<ListGroupPage> createState() => _ListGroupPageState();
}

class _ListGroupPageState extends State<ListGroupPage> {
  late ListGroupCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cubit = ListGroupCubit();
    _cubit.getListHive();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListGroupCubit, ListGroupState>(
      bloc: _cubit,
      builder: (context, state) {
        final groups = state.listData ?? [];
        return Scaffold(
          appBar: AppBar(
            title: const Text("Danh sach nhom"),
          ),
          body:
              groups.isEmpty
                  ? const Center(
                    child: Text(
                      "Chua co nhom nao duoc luu.",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, index) {
                      final group = groups[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFDBEAFE),
                              child: Icon(
                                Icons.groups_2_rounded,
                                size: 18,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                group.name ?? "",
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: groups.length,
                  ),
        );
      },
    );
  }
}
