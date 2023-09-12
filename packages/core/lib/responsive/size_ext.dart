import 'package:flutter/material.dart';

import '../setup/index.dart';
import 'responsive_layout.dart';

BuildContext get _context => findAppContext!;

extension ScaleExt on num {
  get s => this * scaleW(_context);
  get sw2 => responsiveByWidth(
      _context, this * (scaleW(_context) < .2 ? .2 : scaleW(_context)),
      phone: this * .2);
  get sw3 => responsiveByWidth(
      _context, this * (scaleW(_context) < .3 ? .3 : scaleW(_context)),
      phone: this * .3);
  get sw4 => responsiveByWidth(
      _context, this * (scaleW(_context) < .4 ? .4 : scaleW(_context)),
      phone: this * .4);
  get sw5 => responsiveByWidth(
      _context, this * (scaleW(_context) < .5 ? .5 : scaleW(_context)),
      phone: this * .5);
  get sw => responsiveByWidth(
      _context, this * (scaleW(_context) < .65 ? .65 : scaleW(_context)),
      phone: this * .7);
  get sw7 => responsiveByWidth(
      _context, this * (scaleW(_context) < .7 ? .7 : scaleW(_context)),
      phone: this * .7);
  get sw8 => responsiveByWidth(
      _context, this * (scaleW(_context) < .8 ? .8 : scaleW(_context)),
      phone: this * .8);

  get spw => responsiveByWidth(
      _context, this * (scaleW(_context) < .65 ? .65 : scaleW(_context)),
      phone: this * .7);
}

double fs44([context]) =>
    responsiveByWidth(context ?? _context, 44.spw, phone: 32.0);

double fs36([context]) =>
    responsiveByWidth(context ?? _context, 36.spw, phone: 28.0);

double fs32([context]) =>
    responsiveByWidth(context ?? _context, 32.spw, phone: 24.0);

double fs28([context]) =>
    responsiveByWidth(context ?? _context, 28.spw, phone: 20.0);

double fs24([context]) =>
    responsiveByWidth(context ?? _context, 24.spw, phone: 18.0);

double fs20([context]) =>
    responsiveByWidth(context ?? _context, 20.spw, phone: 16.0);

double fs18([context]) =>
    responsiveByWidth(context ?? _context, 18.spw, phone: 16.0);

double fs16([context]) =>
    responsiveByWidth(context ?? _context, 16.spw, phone: 14.0);

double fs14([context]) =>
    responsiveByWidth(context ?? _context, 14.spw, phone: 12.0);

double fs12([context]) =>
    responsiveByWidth(context ?? _context, 12.spw, phone: 10.0);

double fs10([context]) =>
    responsiveByWidth(context ?? _context, 10.spw, phone: 8.0);
