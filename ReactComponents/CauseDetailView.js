'use strict';

import React from 'react';

import {
  AppRegistry,
  ListView,
  StyleSheet,
  Text,
  Image,
  RefreshControl,
  TouchableHighlight,
  View,
} from 'react-native';

var Style = require('./Style.js');
var Bridge = require('react-native').NativeModules.LDTReactBridge;
var NetworkImage = require('./NetworkImage.js');
var NetworkErrorView = require('./NetworkErrorView.js');
var NetworkLoadingView = require('./NetworkLoadingView.js');

var CauseDetailView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      loaded: false,
      error: null,
    };
  },
  componentDidMount: function() {
    this.fetchData();
  },
  catchError: function(error) {
    this.setState({
      error: error,
      loaded: true,
    });
  },
  fetchData: function() {
    fetch(this.props.campaignsUrl)
      .then((response) => response.json())
      .catch((error) => this.catchError(error))
      .then((responseData) => {
        if (!responseData) {
          return;
        }
        var campaigns = [];
        for (var i = 0; i < responseData.data.length; i++) {
          var campaign = responseData.data[i];
          if (campaign.status != 'active') {
            continue;
          }
          if (campaign.type != 'campaign') {
            continue;
          }
          campaigns.push(campaign);
        }
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(campaigns),
          loaded: true,
          error: null,
        });
      })
      .done();
  },
  render: function() {
    if (this.state.error) {
      return (
        <NetworkErrorView
          title="Action isn't loading right now"
          retryHandler={this.fetchData}
          errorMessage={this.state.error.message}
        />);
    }
    if (!this.state.loaded) {
      return <NetworkLoadingView text="Loading actions..." />;
    }
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderHeader={this.renderHeader}
        refreshControl= {<RefreshControl
          onRefresh={this._onRefresh}
          refreshing={this.state.isRefreshing}
          tintColor="#CCC" />}
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
    var coverImage;
    if (!campaign.cover_image.default) {
      coverImage = 'Placeholder Image Download Fails';
    }
    else {
      coverImage = campaign.cover_image.default.sizes.landscape.uri;
    }
    return (
      <TouchableHighlight onPress={() => this._onPressRow(campaign)}>
        <Image
          style={{flex: 1, height: 150, alignItems: 'stretch'}}
          source={{uri: coverImage}}
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
  _onRefresh: function () {
    this.setState({isRefreshing: true});
    setTimeout(() => {
      this.fetchData();
      this.setState({
        isRefreshing: false,
      });
    }, 1000);
  },
  _onPressRow(campaign) {
    Bridge.pushCampaign(Number(campaign.id));
  },
});

var styles = StyleSheet.create({
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
