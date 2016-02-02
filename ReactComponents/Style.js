'use strict';

var React = require('react-native');

var colorCtaBlue = '#3932A9';
var colorTextDefault = '#4A4A4A';

var fontFamilyName = 'Brandon Grotesque';
var fontFamilyBoldName = 'BrandonGrotesque-Bold';
var fontSizeCaption = 13;
var fontSizeBody = 16;
var fontSizeHeading = 20;
var fontSizeTitle = 24;

var {
  StyleSheet,
} = React;

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