'use strict';

import React from 'react';

import {
  Image,
  StyleSheet,
  Text,
  View,
} from 'react-native';

var Style = require('./Style.js');

var SponsorView = React.createClass({
  render: function() {
    var label = "Powered by".toUpperCase();
    return (
      <View style={styles.container}>
        <Text style={[Style.textBodyBold, styles.content]}>{label}</Text>
        <Image 
          resizeMode="contain"
          source={{uri: this.props.imageUrl}}
          style={styles.image} 
        />
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    paddingTop: 8,
  },
  content: {
    color: '#D6D6D6',
    textAlign: 'center',
  },
  image: {
    height: 23,
  }
});

module.exports = SponsorView;
