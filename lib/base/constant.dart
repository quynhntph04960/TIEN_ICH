import '../pokemon/model/level_info.dart';

class Constant {
  static final levelInfosPokemon = [
    LevelInfoModel(1, 'Các ô giữ nguyên sau khi nối đúng.'),
    LevelInfoModel(2, 'Các ô trong từng cột đổ từ trên xuống dưới.'),
    LevelInfoModel(3, 'Các ô trong từng cột đổ từ dưới lên trên.'),
    LevelInfoModel(4, 'Các ô trong từng hàng đổ từ trái qua phải.'),
    LevelInfoModel(5, 'Các ô trong từng hàng đổ từ phải qua trái.'),
    LevelInfoModel(6, 'Nửa trái đổ về cột 8, nửa phải đổ về cột 9.'),
    LevelInfoModel(7, 'Nửa trái đổ về cột 1, nửa phải đổ về cột 16.'),
    LevelInfoModel(8, 'Các ô trong từng cột đổ về hàng 5.'),
    LevelInfoModel(
      9,
      'Hàng 2-4 đổ về hàng 1, hàng 6-8 đổ về hàng 9, hàng 5 tách chẵn/lẻ.',
    ),
  ];
}
