'use strict';

import React, {Component} from 'react';

import {
  AppRegistry,
  ActivityIndicatorIOS,
  ListView,
  StyleSheet,
  Text,
  RefreshControl,
  View,
  // Lame way to fix https://github.com/DoSomething/LetsDoThis-iOS/issues/865
  NativeAppEventEmitter
} from 'react-native';
// @see https://github.com/facebook/react-native/issues/5224
NativeAppEventEmitter;

var Style = require('./Style.js');
var NewsFeedPost = require('./NewsFeedPost.js');
var NetworkErrorView = require('./NetworkErrorView.js');

var NewsFeedView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      isRefreshing: false,
      loaded: false,
      error: null,
    };
  },
  componentDidMount: function() {
    this.fetchData();
  },
  fetchData: function() {
    this.setState({
      loaded: false,
      error: null,
    });
    fetch(this.props.url)
      .then((response) => response.json())
      .catch((error) => this.catchError(error))
      .then((responseData) => {
        if (!responseData) {
          return;
        }
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(responseData.posts),
          loaded: true,
          error: null,
        });
      })
      .done();
  },
  catchError: function(error) {
    console.log("NewsFeed.catchError");
    this.setState({
      error: error,
    });
  },
  render: function() {
    if (this.state.error) {
      return (
        <NetworkErrorView
          title="News isn't loading right now"
          retryHandler={this.fetchData}
          errorMessage={this.state.error.message}
        />);
    }
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }

    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        style={styles.listView}
        refreshControl={
          <RefreshControl
            refreshing={this.state.isRefreshing}
            onRefresh={this._onRefresh}
            tintColor="#CCC"
            colors={['#ff0000', '#00ff00', '#0000ff']}
            progressBackgroundColor="#ffff00"
          />
        }
      />
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
  renderLoadingView: function() {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          Loading news...
        </Text>
      </View>
    );
  },
  renderRow: function(post) {
    return (
      <NewsFeedPost
        key={post.id}
        post={post} />
    );
  },
});


var styles = StyleSheet.create({
  listView: {
    backgroundColor: '#DFDFDF',
    paddingLeft: 10,
    paddingRight: 10,
    paddingBottom: 10,
  },
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
});

module.exports = NewsFeedView;
