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
var Bridge = require('react-native').NativeModules.LDTReactBridge;
var NetworkImage = require('./NetworkImage.js');

var CauseDetailView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
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
      this.props.cause.image_url = 'Placeholder Image Download Fails';
    }
    var titleView = (
      <View style={styles.centeredTitleContainer}>
        <Text style={[Style.textTitle, styles.centeredTitleText]}>
          {this.props.cause.title.toUpperCase()}
        </Text>
      </View>
    );
    return (
      <View>
        <NetworkImage
          style={{flex: 1, height: 150, alignItems: 'stretch'}}
          source={{uri: this.props.cause.image_url}}
          content={titleView}
        />
        <Text style={[Style.textSubheading, styles.tagline]}>
          {this.props.cause.tagline}
        </Text>
      </View>
    );
  },
  renderRow: function(campaign) {
    if (campaign.image_url.length == 0) {
      campaign.image_url = 'Placeholder Image Download Fails';
    }
    return (
      <TouchableHighlight onPress={() => this._onPressRow(campaign)}>
        <Image
          style={{flex: 1, height: 150, alignItems: 'stretch'}}
          source={{uri: campaign.image_url}}
          defaultSource={{uri: 'Placeholder Image Loading'}}>
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
    Bridge.pushCampaign(campaign.id);
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
