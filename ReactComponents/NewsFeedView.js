'use strict';

import React, {
  AppRegistry,
  ActivityIndicatorIOS,
  ListView,
  Component,
  StyleSheet,
  Text,
  RefreshControl,
  View
} from 'react-native';

var Style = require('./Style.js');
var NewsFeedPost = require('./NewsFeedPost.js');

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
    fetch(this.props.url)
      .then((response) => response.json())
      .then((responseData) => {
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(responseData.posts),
          loaded: true,
          error: null,
        });
      })
      .catch((error) => this.catchError(error))
      .done();
  },
  catchError: function(error) {
    console.log(error);
    this.setState({
      error: error,
    });
  },
  renderError: function() {
    return (
      <View style={styles.loadingContainer}>
        <Text style={Style.textBody}>
          Epic Fail
        </Text>
      </View>
    );
  },
  render: function() {
    if (this.state.error) {
      return this.renderError();
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
            tintColor="#3932A9"
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


var styles = React.StyleSheet.create({
  listView: {
    backgroundColor: '#eeeeee',
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
