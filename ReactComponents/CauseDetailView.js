'use strict';

import React, {
  AppRegistry,
  ListView,
  Component,
  StyleSheet,
  Text,
  Image,
  RefreshControl,
  TouchableHighlight,
  View
} from 'react-native';

var Style = require('./Style.js');
var CauseDetailViewController = require('react-native').NativeModules.LDTCauseDetailViewController;

var CauseDetailView = React.createClass({
  getInitialState: function() {
    var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    return {
      dataSource: ds.cloneWithRows(this.props.campaigns),
    };
  },
  render: function() {
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderHeader={this.renderHeader}
      />
    );
  },
  renderHeader: function() {
    if (this.props.cause.image_url.length == 0) {
      // @todo: Load error loading image instead of kitty cat.
      // Its failing to bundle into assets.
      this.props.cause.image_url = 'https://placekitten.com/g/600/300';
    }
    return (
      <View>
        <Image
          style={{flex: 1, height: 150, alignItems: 'stretch'}}
          source={{uri: this.props.cause.image_url}}>
          <View style={styles.centeredTitleContainer}>
            <Text style={[Style.textTitle, styles.centeredTitleText]}>
              {this.props.cause.title.toUpperCase()}
            </Text>
          </View>
        </Image>
        <Text style={[Style.textSubheading, styles.tagline]}>{this.props.cause.tagline}</Text>
      </View>
    );
  },
  renderRow: function(campaign) {
    if (campaign.image_url.length == 0) {
      // @todo: Load error loading image instead of kitty cat.
      // Its failing to bundle into assets.
      campaign.image_url = 'https://placekitten.com/g/600/300';
    }
    return (
      <TouchableHighlight onPress={() => this._onPressRow(campaign)}>
        <Image
          style={{flex: 1, height: 150, alignItems: 'stretch'}}
          source={{uri: campaign.image_url}}>
          <View style={styles.centeredTitleContainer}>
            <Text style={[Style.textTitle, styles.centeredTitleText]}>
              {campaign.title.toUpperCase()}
            </Text>
          </View>
        </Image>
      </TouchableHighlight>
    );
  },
  _onPressRow(campaign) {
    CauseDetailViewController.presentCampaign(campaign.id);
  },
});

var styles = React.StyleSheet.create({
  centeredTitleContainer: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    alignItems: 'center',
    flex: 1,
    flexDirection: 'row',
    padding: 20,
  },
  centeredTitleText: {
    color: 'white',
    flex: 1,
    flexDirection: 'column',
    textAlign: 'center',
  },
  tagline: {
    paddingLeft: 20,
    paddingRight: 20,
    paddingTop: 18,
    paddingBottom: 33,
    textAlign: 'center',
  },
});

module.exports = CauseDetailView;
