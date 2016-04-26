'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
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
          source={{uri: this.props.imageUrl}}
          style={styles.image} 
        />
      </View>
    );
  }
});

var styles = React.StyleSheet.create({
  container: {
    padding: 20,
  },
  content: {
    color: '#D6D6D6',
    textAlign: 'center',
  },
  image: {
    height: 50,
  }
});

module.exports = SponsorView;
