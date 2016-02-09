'use strict';

import React, {
  AppRegistry,
  ActivityIndicatorIOS,
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
var CauseListViewController = require('react-native').NativeModules.LDTCauseListViewController;

var CauseListView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      isRefreshing: false,
      loaded: false,
      error: false,
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
          dataSource: this.state.dataSource.cloneWithRows(responseData.categories),
          loaded: true,
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
          Loading causes...
        </Text>
      </View>
    );
  },
  _onPressRow(cause) {
    CauseListViewController.presentCause(cause);
  },
  renderRow: function(cause) {
    var causeColorStyle = {backgroundColor: '#' + cause.hex};
    return (
      <TouchableHighlight onPress={() => this._onPressRow(cause)}>
        <View style={styles.row}>
          <View style={[styles.causeColor, causeColorStyle]} />
          <View style={[styles.contentContainer, styles.bordered]}>
            <View>
              <Text style={Style.textHeading}>{cause.title}</Text>
              <Text style={Style.textCaption}>{cause.description}</Text>
            </View>
          </View>
          <View style={[styles.arrowContainer, styles.bordered]}>
              <Image
                style={styles.arrowImage}
                source={require('image!Arrow')}
              />  
          </View>
        </View>
      </TouchableHighlight>
    );
  },
});

var styles = React.StyleSheet.create({
  listView: {
    backgroundColor: '#FFFFFF',
    paddingBottom: 10,
  },
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
  row: {
    backgroundColor: '#FFFFFF',
    flex: 1,
    flexDirection: 'row',
  },
  causeColor: {
    width: 8,
    backgroundColor: '#00FF00',
    height: 84,
  },
  bordered: {
    borderColor: '#EDEDED',
    borderTopWidth: 2,
    borderBottomWidth: 2,    
  },
  contentContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: 8,
    height: 84,
  },
  arrowContainer: {
    width: 38,
    height: 84,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  arrowImage: {
    width: 12,
    height: 21,
  },
});

module.exports = CauseListView;
