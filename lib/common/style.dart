import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color colorOrange = Color(0xFFF9BB6F);
const Color colorDarkOrange = Color(0xFFD6974C);
const Color colorGreen = Color(0xFF8CBC90);
const Color colorSoftGreen = Color(0xFFE6FAE7);
const Color colorBlue = Color(0xFF89BFEF);
const Color colorSoftBlue = Color(0xFFE9F4FF);
const Color colorYellow = Color(0xFFD8D689);
const Color colorSoftYellow = Color(0xFFFFFEDA);
const Color colorRed = Color(0xFFF4B6BB);
const Color colorSoftRed = Color(0xFFFFF2F3);

const Color colorGray = Color(0xFFC9C9C9);
const Color colorSoftGray = Color(0xFFFAFAFA);

Color getColorByIndex(int index) {
  int num = index % 4;

  switch (num) {
    case 0:
      return colorRed;
    case 1:
      return colorGreen;
    case 2:
      return colorBlue;
    case 3:
      return colorYellow;
  }
  return colorGreen;
}

Color getSoftColorByIndex(int index) {
  int num = index % 4;

  switch (num) {
    case 0:
      return colorSoftRed;
    case 1:
      return colorSoftGreen;
    case 2:
      return colorSoftBlue;
    case 3:
      return colorSoftYellow;
  }
  return colorGreen;
}

TextStyle textRegular = GoogleFonts.poppins(
    color: colorGray, fontSize: 14.0, fontWeight: FontWeight.normal);

TextStyle textMedium = GoogleFonts.nunito(
    color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600);

TextStyle textBoldBlack = GoogleFonts.poppins(
    color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600);

TextStyle titleBoldOrange = GoogleFonts.nunito(
    color: colorDarkOrange, fontSize: 26.0, fontWeight: FontWeight.bold);

TextStyle titleBoldWhite = GoogleFonts.nunito(
    color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold);

TextStyle titleBoldBlack = GoogleFonts.nunito(
    color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold);

TextStyle titleMediumBlack = GoogleFonts.nunito(
    color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold);
