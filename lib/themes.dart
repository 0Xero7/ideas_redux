import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.getTextTheme('Nunito'),
  buttonColor: Color.fromARGB(255, 230, 230, 230),
);
ThemeData darkTheme  = ThemeData.dark(). copyWith(
  textTheme:  GoogleFonts.getTextTheme('Nunito').copyWith(
    headline4: GoogleFonts.getFont('Nunito', color: Colors.white70),
    headline6: GoogleFonts.getFont('Nunito', color: Colors.white70),
    subtitle1: GoogleFonts.getFont('Nunito', color: Colors.white60),
    subtitle2: GoogleFonts.getFont('Nunito', color: Colors.white60),
    bodyText1: GoogleFonts.getFont('Nunito', color: Colors.white60),
    bodyText2: GoogleFonts.getFont('Nunito', color: Colors.white60),
  ),
);