import 'package:demo2/base/common_function.dart';
import 'package:demo2/money_share/add_friend_popup.dart';
import 'package:demo2/money_share/add_group_hive_popup.dart';
import 'package:demo2/money_share/money_share_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'model/name_model.dart';
import 'page/list_group_page.dart';

class MoneySharePage extends StatefulWidget {
  const MoneySharePage({super.key});

  @override
  State<MoneySharePage> createState() => _MoneySharePageState();
}

class _MoneySharePageState extends State<MoneySharePage> {
  final _cubit = MoneyShareCubit();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return const ListGroupPage();
                  },
                ),
              );
            },
            icon: const Icon(Icons.list),
          ),
          title: const Text("Chia tien"),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await AddGroupHivePopup.showPopup(context);
                _cubit.saveGroupMoney(result);
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await AddFriendPopup.showPopup(context);
            _cubit.addFriend(result);
          },
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text("Them ban"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MoneyShareCubit, MoneyShareState>(
      builder: (context, state) {
        if (state.names.isEmpty) {
          return const Center(
            child: Text(
              "Chua co thanh vien nao.\nNhan \"Them ban\" de bat dau.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: state.names.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = state.names[index];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final result = await AddFriendPopup.showPopup(
                  context,
                  isCreate: false,
                  model: data,
                );
                _cubit.updateFriend(result);
              },
              child: _buildItem(data),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<MoneyShareCubit, MoneyShareState>(
      builder: (context, state) {
        final eachAmount = _cubit.chiaDeuMoiNguoi().toStringAsFixed(2);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            spacing: 12,
            children: [
              _buildSummaryChip(
                "Tong chi",
                formatCurrency(_cubit.tongTienChi()),
                const Color(0xFFDC2626),
              ),
              _buildSummaryChip(
                "Tong thu",
                formatCurrency(_cubit.tongTienThu()),
                const Color(0xFF059669),
              ),
              _buildSummaryChip(
                "Moi nguoi",
                formatCurrency(eachAmount),
                const Color(0xFF1D4ED8),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryChip(String title, String value, Color valueColor) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(NameModel data) {
    final name = data.name;
    final incomeList =
        data.listMoney
            ?.where((e) => e.isCollected == true)
            .map((e) => formatCurrency(e.money))
            .join("; ") ??
        "";
    final expenseList =
        data.listMoney
            ?.where((e) => e.isCollected != true)
            .map((e) => formatCurrency(e.money))
            .join("; ") ??
        "";
    final transactionCount = "(${data.listMoney?.length ?? 0})";

    final sumMoney =
        data.listMoney?.where((e) => e.isCollected != true).fold(0, (p, money) {
          return p + (money.money ?? 0);
        }) ??
        0;
    final receiveBack =
        "${(sumMoney - _cubit.chiaDeuMoiNguoi()) > 0 ? (sumMoney - _cubit.chiaDeuMoiNguoi()) : 0}";
    final needToPay =
        "${(_cubit.chiaDeuMoiNguoi() - sumMoney) > 0 ? _cubit.chiaDeuMoiNguoi() - sumMoney : 0}";

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        transactionCount,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRowLabelValue("Khoan thu", incomeList),
                  const SizedBox(height: 6),
                  _buildRowLabelValue("Khoan chi", expenseList),
                  const Divider(height: 18),
                  _buildMoneyResult(
                    "Phai tra",
                    formatCurrency(needToPay),
                    Colors.red,
                  ),
                  const SizedBox(height: 4),
                  _buildMoneyResult(
                    "Nhan lai",
                    formatCurrency(receiveBack),
                    const Color(0xFF059669),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _cubit.deleteFriend(data);
              },
              icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
              tooltip: "Xoa",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowLabelValue(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value.isEmpty ? "-" : value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyResult(String title, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            "$title:",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
