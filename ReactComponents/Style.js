'use strict';

var React = require('react-native');

var {
  StyleSheet,
} = React;

var Theme = require('react-native').NativeModules.LDTTheme;
var colorCtaBlue = '#3932A9';
var colorTextDefault = '#4A4A4A';
var fontFamilyName = Theme.fontName;
var fontFamilyBoldName = Theme.fontNameBold;
var fontSizeCaption = Theme.fontSizeCaption;
var fontSizeBody = Theme.fontSizeBody;
var fontSizeHeading = Theme.fontSizeHeading;
var fontSizeTitle = Theme.fontSizeTitle;

module.exports = StyleSheet.create({
  backgroundColorCtaBlue: {
    backgroundColor: colorCtaBlue,
  },
  textColorCtaBlue: {
    color: colorCtaBlue,
  },
  textCaption: {
    color: colorTextDefault,
    fontFamily: fontFamilyName,
    fontSize: fontSizeCaption,
  },
  textCaptionBold: {
    color: colorTextDefault,
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeCaption,
  },
  textBody: {
    color: colorTextDefault,
    fontFamily: fontFamilyName,
    fontSize: fontSizeBody,
  },
  textBodyBold: {
    color: colorTextDefault,
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeBody,
  },
  textSubheading: {
    color: colorTextDefault,
    fontFamily: fontFamilyName,
    fontSize: fontSizeHeading,
  },
  textHeading: {
    color: colorTextDefault,
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeHeading,
  },
  textTitle: {
    color: colorTextDefault,
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeTitle,
  },
});