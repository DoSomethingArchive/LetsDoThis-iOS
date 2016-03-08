'use strict';

var React = require('react-native');

var {
  StyleSheet,
} = React;

var Bridge = require('react-native').NativeModules.LDTReactBridge;
var colorCtaBlue = Bridge.colorCtaBlue;
var colorTextDefault = Bridge.colorCopyGray;
var fontFamilyName = Bridge.fontName;
var fontFamilyBoldName = Bridge.fontNameBold;
var fontSizeCaption = Bridge.fontSizeCaption;
var fontSizeBody = Bridge.fontSizeBody;
var fontSizeHeading = Bridge.fontSizeHeading;
var fontSizeTitle = Bridge.fontSizeTitle;

module.exports = StyleSheet.create({
  backgroundColorCtaBlue: {
    backgroundColor: colorCtaBlue,
  },
  textColorCtaBlue: {
    color: colorCtaBlue,
  },
  actionButton: {
    backgroundColor: colorCtaBlue,
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    paddingBottom: 10,
    paddingTop: 10,
  },
  actionButtonText: {
    color: 'white',
    textAlign: 'center',
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeBody,
  },
  sectionHeader: {
    backgroundColor: '#EEEEEE',
  },
  sectionHeaderText: {
    textAlign: 'center', 
    color: colorTextDefault,
    fontFamily: fontFamilyBoldName,
    fontSize: fontSizeHeading,
    padding: 14,

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