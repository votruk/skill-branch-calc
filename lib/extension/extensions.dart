import 'dart:math';

extension DoubleExt on double {
  String prettifyWithPrecision([final int precisionPlaces = 5]) {
    if (!this.isFinite) {
      return "NaN";
    }
    return this
        .roundWithPrecision(precisionPlaces)
        .toString()
        .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  double roundWithPrecision(final int precisionPlaces) {
    final num mod = pow(10.0, precisionPlaces);
    return ((this * mod).round().toDouble() / mod);
  }
}
