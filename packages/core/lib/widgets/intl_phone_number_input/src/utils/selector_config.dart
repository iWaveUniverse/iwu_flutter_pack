import 'package:flutter/material.dart';

import '../../intl_phone_number_input.dart';
import '../models/country_model.dart';

/// [CountryComparator] takes two countries: A and B.
///
/// Should return -1 if A precedes B, 0 if A is equal to B and 1 if B precedes A
typedef CountryComparator = int Function(Country, Country);

/// [SelectorConfig] contains selector button configurations
class SelectorConfig {
  final Widget Function(String)? flagbuilder;
  final TextStyle? selectorTextStyle;
  final Color? bgColor;

  /// [selectorType], for selector button type
  final PhoneInputSelectorType selectorType;

  /// [countryComparator], sort the country list according to the comparator.
  ///
  /// Sorting is disabled by default
  final CountryComparator? countryComparator;

  /// [setSelectorButtonAsPrefixIcon], this sets/places the selector button inside the [TextField] as a prefixIcon.
  final bool setSelectorButtonAsPrefixIcon;

  /// Space before the flag icon
  final double? leadingPadding;

  /// Add white space for short dial code
  final bool trailingSpace;

  const SelectorConfig({
    this.flagbuilder,
    this.selectorTextStyle,this.bgColor,
    this.selectorType = PhoneInputSelectorType.DROPDOWN,
    this.countryComparator,
    this.setSelectorButtonAsPrefixIcon = false,
    this.leadingPadding,
    this.trailingSpace = true,
  });
}
