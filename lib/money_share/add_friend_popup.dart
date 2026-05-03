import 'package:demo2/money_share/model/name_model.dart';
import 'package:flutter/material.dart';

import '../base/common_function.dart';

class AddFriendPopup extends StatefulWidget {
  final bool isCreate;
  final NameModel? model;

  const AddFriendPopup({super.key, required this.isCreate, this.model});

  static Future<NameModel?> showPopup(
    BuildContext context, {
    bool isCreate = true,
    NameModel? model,
  }) async {
    return await showModalBottomSheet(
      context: context,
      builder: (_) {
        return AddFriendPopup(isCreate: isCreate, model: model);
      },
    );
  }

  @override
  State<AddFriendPopup> createState() => _AddFriendPopupState();
}

class _AddFriendPopupState extends State<AddFriendPopup> {
  final controller = TextEditingController();
  final listMoney = <MoneyModel>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = widget.model?.name ?? "";
    listMoney.addAll(widget.model?.listMoney ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.isCreate ? "Thêm thông tin" : "Sửa thông tin",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextField(
                  controller: controller,
                  maxLines: 1,
                  decoration: InputDecoration(
                    // border: OutlineInputBorder(),
                    label: Text("Tên"),
                    hint: Text("Nhập tên"),
                  ),
                ),
              ),
              Text("Dòng tiền"),
              _buildList(),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        listMoney.add(MoneyModel());
                        setState(() {});
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Thên tiền",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (controller.text.isEmpty) {
                          print('Name isEmpty');
                          return;
                        }

                        if (widget.isCreate) {
                          final data = NameModel(
                            id: 0,
                            name: controller.text,
                            listMoney: listMoney,
                          );
                          Navigator.of(context).pop(data);
                        } else {
                          final data = widget.model?.copyWith(
                            name: controller.text,
                            listMoney: listMoney,
                          );
                          Navigator.of(context).pop(data);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.isCreate ? "Thêm mới" : "Cập nhật",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        final data = listMoney[index];
        return Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    listMoney[index] = listMoney[index].copyWith(money: 0);
                    return;
                  }
                  listMoney[index] = listMoney[index].copyWith(
                    money: int.parse(value.replaceAll(",", "")),
                  );
                },
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                maxLength: 19,
                decoration: InputDecoration(
                  hintText: "Nhập số tiền",
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  isDense: true,
                  suffixIcon: InkWell(
                    onTap: () {
                      print('_AddFriendPopupState._buildList');
                      listMoney[index] = listMoney[index].copyWith(
                        isCollected: !data.isCollected,
                      );
                      setState(() {});
                    },
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: data.isCollected == true
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data.isCollected == true ? "Thu" : "Chi",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                controller: TextEditingController(
                  text: formatCurrency(data.money ?? 0),
                ),
              ),
            ),
          ],
        );
      },
      itemCount: listMoney.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 8);
      },
    );
  }
}
