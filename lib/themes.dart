import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.nunitoTextTheme().copyWith(
    headline4: GoogleFonts.nunitoSans(color: Colors.black54)
  ),
  buttonColor: Color.fromARGB(255, 230, 230, 230),
  // col0r
);
ThemeData darkTheme  = ThemeData.dark(). copyWith(
  textTheme:  GoogleFonts.nunitoTextTheme().copyWith(
    headline4: GoogleFonts.nunitoSans(color: Colors.white70),
    headline6: GoogleFonts.nunitoSans(color: Colors.white70),
    subtitle1: GoogleFonts.nunitoSans(color: Colors.white60),
    subtitle2: GoogleFonts.nunitoSans(color: Colors.white60),
  ),
);