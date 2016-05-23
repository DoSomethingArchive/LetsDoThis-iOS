'use strict';

import React from 'react';

import {
  ListView,
  StyleSheet,
  Text,
  View,
  WebView
} from 'react-native';

var Style = require('./Style.js');

var ActionGuidesView = React.createClass({
  render: function() {
    var self = this;
    var content = this.props.actionGuides.map(function(actionGuide) {
      return self.renderActionGuide(actionGuide)
    });
    // DS API returns Action Guides as formatted HTML, time to build a webpage!
    var html = "<html><body style='color:#4A4A4A'>" + content + "</body></html>";
    return <WebView
      source={{html: html}}
      scalesPageToFit={true} />
  },
  renderActionGuide: function(actionGuide) {
    var content = "";
    if (actionGuide.title) {
      content += this.renderTitle(actionGuide.title);
    }
    if (actionGuide.subtitle) {
      content += this.renderCopy(actionGuide.subtitle);
    }
    if (actionGuide.intro.title) {
      content += this.renderHeading(actionGuide.intro.title);
    }
    if (actionGuide.intro.copy) {
      content += this.renderCopy(actionGuide.intro.copy.formatted);
    }
    if (actionGuide.additional_text.title) {
      content += this.renderHeading(actionGuide.additional_text.title);
    }  
    if (actionGuide.additional_text.copy) {
      content += this.renderCopy(actionGuide.additional_text.copy.formatted);
    }    
    return content;
  },
  renderCopy: function(text) {
    return "<div style='font-family:BrandonGrotesque-Regular;font-size:32pt;padding:12pt 24pt'>" + text + "</div>";
  },
  renderHeading: function(text) {
    return "<div style='color:#9C9C9C;font-family:BrandonGrotesque-Bold;font-size:26pt;padding:24pt 24pt 0 24pt;'>" + text.toUpperCase() + "</div>";
  },
  renderTitle: function(text) {
    return "<div align='center' style='background:#EEEEEE;font-family:BrandonGrotesque-Bold;font-size:36pt;padding:24pt'>" + text.toUpperCase() + "</div>";
  }
});


module.exports = ActionGuidesView;
