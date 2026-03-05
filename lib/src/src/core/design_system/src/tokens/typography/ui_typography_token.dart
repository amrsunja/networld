import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_ui.dart';
import 'utils/typo_helper.dart';
part 'src/display_xl_typo.dart';
part 'src/display_lg_typo.dart';
part 'src/display_md_typo.dart';
part 'src/display_sm_typo.dart';
part 'src/display_xs_typo.dart';
part 'src/text_xl_typo.dart';
part 'src/text_lg_typo.dart';
part 'src/text_md_typo.dart';
part 'src/text_sm_typo.dart';
part 'src/text_xs_typo.dart';


class UITypographyToken {
  // 1. Define instance variables (Remove 'static')
  final DisplayXlTypo displayXl;
  final DisplayLgTypo displayLg;
  final DisplayMdTypo displayMd;
  final DisplaySmTypo displaySm;
  final DisplayXsTypo displayXs;

  final TextXlTypo textXl;
  final TextLgTypo textLg;
  final TextMdTypo textMd;
  final TextSmTypo textSm;
  final TextXsTypo textXs;
  
  // 2. Main constructor
  UITypographyToken({
    required this.displayXl,
    required this.displayLg,
    required this.displayMd,
    required this.displaySm,
    required this.displayXs,

    required this.textXl,
    required this.textLg,
    required this.textMd,
    required this.textSm,
    required this.textXs,
  });

  // 3. Light Factory: Pass the light color token
  factory UITypographyToken.light() {
    final color = UIColorsToken.neu700;
    return UITypographyToken(
      displayXl: DisplayXlTypo(color: color),
      displayLg: DisplayLgTypo(color: color),
      displayMd: DisplayMdTypo(color: color),
      displaySm: DisplaySmTypo(color: color),
      displayXs: DisplayXsTypo(color: color),
      textXl: TextXlTypo(color: color),
      textLg: TextLgTypo(color: color),
      textMd: TextMdTypo(color: color),
      textSm: TextSmTypo(color: color),
      textXs: TextXsTypo(color: color),
    );
  }

  // 4. Dark Factory: Pass the dark color token
  factory UITypographyToken.dark() {
    final color = UIColorsToken.neu100;
    return UITypographyToken(
      displayXl: DisplayXlTypo(color: color),
      displayLg: DisplayLgTypo(color: color),
      displayMd: DisplayMdTypo(color: color),
      displaySm: DisplaySmTypo(color: color),
      displayXs: DisplayXsTypo(color: color),
      textXl: TextXlTypo(color: color),
      textLg: TextLgTypo(color: color),
      textMd: TextMdTypo(color: color),
      textSm: TextSmTypo(color: color),
      textXs: TextXsTypo(color: color),
    );
  }
}
