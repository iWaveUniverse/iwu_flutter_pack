double get _scale => 1;

extension SizeExtension on num {
  double scale() {
    return this * _scale;
  }
}