'use strict';

import React, {
  StyleSheet,
  Text,
  View,
} from 'react-native';
import Dimensions from 'Dimensions';

var Style = require('./Style.js');

var ActionGuidesView = React.createClass({
  render: function() {
    console.log(this.props.actionGuides);
    return (
      <View>
        <Text>Action Guides</Text>
      </View>
    );
  },
});

module.exports = ActionGuidesView;
