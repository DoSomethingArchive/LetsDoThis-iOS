'use strict';

import React from 'react';

import {
  ActivityIndicatorIOS,
  StyleSheet,
  Text,
  View,
} from 'react-native';

var Style = require('./Style.js');

var NetworkingLoadingView = React.createClass({
  render: function() {
    return (
      <View style={styles.container}>
        <ActivityIndicatorIOS animating={true} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          {this.props.text}
        </Text>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
});

module.exports = NetworkingLoadingView;
