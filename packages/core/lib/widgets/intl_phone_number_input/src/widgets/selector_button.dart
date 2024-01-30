import 'package:_iwu_pack/widgets/widget_app_flag.dart';
import 'package:flutter/material.dart';

import '../../intl_phone_number_input.dart';
import '../models/country_model.dart';

/// [SelectorButton]
class SelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final String? locale;
  final bool isEnabled;
  final bool isScrollControlled;

  final ValueChanged<Country?> onCountryChanged;

  const SelectorButton({
    super.key,
    required this.countries,
    required this.country,
    required this.selectorConfig,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.locale,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
  });

  @override
  Widget build(BuildContext context) {
    return countries.isNotEmpty && countries.length > 1
        ? DropdownButtonHideUnderline(
            child: DropdownButton<Country>(
              elevation: 4,
              icon: Container(
                margin: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: selectorConfig.selectorTextStyle!.color ?? Colors.grey,
                ),
              ),
              hint: Item(
                country: country,
                builder: selectorConfig.flagbuilder,
                leadingPadding: selectorConfig.leadingPadding,
                trailingSpace: selectorConfig.trailingSpace,
                textStyle: selectorConfig.selectorTextStyle,
              ),
              value: country,
              items: mapCountryToDropdownItem(countries),
              onChanged: isEnabled ? onCountryChanged : null,
              dropdownColor: selectorConfig.bgColor,
            ),
          )
        : Item(
            country: country,
            builder: selectorConfig.flagbuilder,
            leadingPadding: selectorConfig.leadingPadding,
            trailingSpace: selectorConfig.trailingSpace,
            textStyle: selectorConfig.selectorTextStyle,
          );
  }

  /// Converts the list [countries] to `DropdownMenuItem`
  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(
      List<Country> countries) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
        value: country,
        child: Item(
          country: country,
          builder: selectorConfig.flagbuilder,
          textStyle: selectorConfig.selectorTextStyle,
          trailingSpace: selectorConfig.trailingSpace,
        ),
      );
    }).toList();
  }
}

/// [Item]
class Item extends StatelessWidget {
  final Widget Function(String)? builder;
  final Country? country;
  final TextStyle? textStyle;
  final double? leadingPadding;
  final bool trailingSpace;

  const Item({
    super.key,
    this.builder,
    this.country,
    this.textStyle,
    this.leadingPadding = 12,
    this.trailingSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    String dialCode = (country?.dialCode ?? '');
    if (trailingSpace) {
      dialCode = dialCode.padRight(5, "   ");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: leadingPadding),
        builder != null
            ? builder!(country!.alpha2Code!)
            : WidgetAppFlag.countryCode(countryCode: country!.alpha2Code),
        SizedBox(width: leadingPadding),
        Text(
          dialCode,
          textDirection: TextDirection.ltr,
          style: textStyle,
        ),
      ],
    );
  }
}
