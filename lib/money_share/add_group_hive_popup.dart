import 'package:flutter/material.dart';

class AddGroupHivePopup extends StatefulWidget {
  const AddGroupHivePopup({super.key});

  static Future<String> showPopup(
    BuildContext context, {
    bool isCreate = true,
  }) async {
    return await showModalBottomSheet(
      context: context,
      builder: (_) {
        return AddGroupHivePopup();
      },
    );
  }

  @override
  State<AddGroupHivePopup> createState() => _AddGroupHivePopupState();
}

class _AddGroupHivePopupState extends State<AddGroupHivePopup> {
  final controller = TextEditingController();

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
            children: [
              Text(
                'Lưu lại thông tin chia tiền',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextField(
                  decoration: InputDecoration(hintText: "Tên nhóm"),
                  controller: controller,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (controller.text.isEmpty) return;
                  Navigator.pop(context, controller.text);
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Lưu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
