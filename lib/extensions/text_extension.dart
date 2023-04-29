extension TextContainsExtension on String {
  bool isContainsASCII(String value) {
    return ASCIIParse.isContains(this, value);
  }
}

class ASCIIParse {
  ASCIIParse._();

  static const _chars = 'aAeEoOuUiIdDyYcCnNsSzZ';

  static final _charsRegex = <RegExp>[
    RegExp(r'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ|ä|å'),
    RegExp(r'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ|Ä|Å'),
    RegExp(r'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|ë'),
    RegExp(r'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ|Ë'),
    RegExp(r'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|ö'),
    RegExp(r'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ|Ö'),
    RegExp(r'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ|û|ü'),
    RegExp(r'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ|Û|Ü'),
    RegExp(r'ì|í|ị|ỉ|ĩ|î|ï'),
    RegExp(r'Ì|Í|Ị|Ỉ|Ĩ|Î|Ï'),
    RegExp(r'đ'),
    RegExp(r'Đ'),
    RegExp(r'ỳ|ý|ỵ|ỷ|ỹ|ÿ'),
    RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ|Ÿ'),
    RegExp(r'ç'),
    RegExp(r'Ç'),
    RegExp(r'ñ'),
    RegExp(r'Ñ'),
    RegExp(r'š'),
    RegExp(r'Š'),
    RegExp(r'ž'),
    RegExp(r'Ž'),
  ];

  static String _parse(final String text) {
    var result = text;
    for (var i = 0; i < _chars.length; ++i) {
      result = result.replaceAll(_charsRegex[i], _chars[i]);
    }
    return result;
  }

  static bool isContains(String? a, String? b) {
    return _parse((a ?? '').trim().toUpperCase())
        .contains(_parse((b ?? '').trim().toUpperCase()));
  }
}
