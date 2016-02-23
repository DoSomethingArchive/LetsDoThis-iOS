'use strict';

import React, {
  Component,
  ListView,
  StyleSheet,
  Text,
  Image,
  RefreshControl,
  TouchableHighlight,
  ActivityIndicatorIOS,
  View,
  NativeAppEventEmitter
} from 'react-native';

var Style = require('./Style.js');
var UserViewController = require('react-native').NativeModules.LDTUserViewController;
var Bridge = require('react-native').NativeModules.LDTReactBridge;
var ReportbackItemView = require('./ReportbackItemView.js');
var firstSectionHeaderText = "Actions I'm Doing";
var secondSectionHeaderText = "Actions I've Done";

var UserView = React.createClass({
  getInitialState: function() {
    var getSectionData = (dataBlob, sectionID) => {
      return dataBlob[sectionID];
    }
    var getRowData = (dataBlob, sectionID, rowID) => {
      return dataBlob[sectionID + ':' + rowID];
    }
    return {
      dataSource : new ListView.DataSource({
        getSectionData          : getSectionData,
        getRowData              : getRowData,
        rowHasChanged           : (row1, row2) => row1 !== row2,
        sectionHeaderHasChanged : (s1, s2) => s1 !== s2
      }),
      isRefreshing: false,
      loaded: false,
      error: null,
    };
  },
  componentDidMount: function() {
    if (this.props.isSelfProfile) {
      this.subscription = NativeAppEventEmitter.addListener(
        'currentUserActivity',
        (signup) => this.handleEvent(signup),
      );
    }
    this.fetchData();
  },
  componentWillUnmount: function() {
    if (typeof this.subscription != "undefined") {
      this.subscription.remove();
    }
  },
  handleEvent: function(campaignActivity) {
    this.fetchData();
  },
  fetchData: function() {
    var options = { 
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Session': this.props.sessionToken,
        'X-DS-REST-API-Key': this.props.apiKey,
      },
    };
    fetch(this.props.url, options)
      .then((response) => response.json())
      .then((responseData) => {
        this.loadSignups(responseData.data);
      })
      .catch((error) => this.catchError(error))
      .done();
  },
  loadSignups: function(signups) {
    var dataBlob = {},
      sectionIDs = [],
      rowIDs = [],
      i;
    sectionIDs.push(0);
    dataBlob[0] = firstSectionHeaderText;
    rowIDs[0] = [];
    sectionIDs.push(1);
    dataBlob[1] = secondSectionHeaderText;
    rowIDs[1] = [];
    for (i = 0; i < signups.length; i++) {
      var signup = signups[i];
      var sectionNumber = 0;
      if (signup.reportback) {
        sectionNumber = 1;
        signup.reportbackItem = signup.reportback.reportback_items.data[0];
      }
      else {
        if (!signup.campaign_run.current) {
          continue;
        }
        if (signup.campaign.status != 'active') {
          continue;
        }
        if (signup.campaign.type != 'campaign') {
          continue;
        }
      }
      rowIDs[sectionNumber].push(signup.id);
      dataBlob[sectionNumber + ':' + signup.id] = signup;
    }
    this.setState({
      dataSource : this.state.dataSource.cloneWithRowsAndSections(dataBlob, sectionIDs, rowIDs),
      loaded: true,
      error: null,
    });
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
  catchError: function(error) {
    console.log(error);
    this.setState({
      error: error,
    });
  },
  renderLoadingView: function() {
    // @todo DRY LoadingView ReactComponent
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          Loading profile...
        </Text>
      </View>
    );
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
  renderEmptySelfProfile: function() {
    return (
      <View>
        {this.renderHeader()}
        <View style={Style.sectionHeader}>
          <Text style={Style.sectionHeaderText}>
            {firstSectionHeaderText.toUpperCase()}
          </Text>
        </View>
        <View style={styles.noActionsContainer}>
          <Text style={Style.textHeading}>
            You haven’t started any actions yet.
          </Text>
          <Text style={[Style.textBody, {paddingTop: 8}]}>
            And you totally should! Shit is happening in the world -- find out how to do something about it.
          </Text>
        </View>
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
    if (this.state.dataSource.getRowCount() == 0 && this.props.isSelfProfile) {
      return this.renderEmptySelfProfile();
    }

    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderHeader={this.renderHeader}
        renderSectionHeader = {this.renderSectionHeader}
        refreshControl={
          <RefreshControl
            refreshing={this.state.isRefreshing}
            onRefresh={this._onRefresh}
            tintColor="#ccc"
            colors={['#ff0000', '#00ff00', '#0000ff']}
            progressBackgroundColor="#ffff00"
          />
        }
      />
    );
  },
  renderHeader: function() {
    if (this.props.user.photo.length == 0) {
      this.props.user.photo = 'https://placekitten.com/g/600/600';
    }
    var headerText = null;
    if (this.props.user.country.length > 0) {
      headerText = this.props.user.country.toUpperCase();
    }
    return (
      <View>
        <Image
          style={styles.headerBackgroundImage}
          source={require('image!Gradient Background')}>
          <View style={styles.headerContainer}>
             <Image
               style={styles.avatar}
               source={{uri: this.props.user.photo}}
             />
             <Text style={[Style.textHeading, styles.headerText]}>
               {headerText}
             </Text>
          </View>
        </Image>
      </View>
    );
  },
  renderSectionHeader(sectionData, sectionID) {
    return (
      <View style={Style.sectionHeader}>
        <Text style={Style.sectionHeaderText}>
          {sectionData.toUpperCase()}
        </Text>
      </View>
    );
  },
  renderRow: function(rowData) {
    if (rowData.reportback) {
      return this.renderDoneRow(rowData);
    }
    else {
      return this.renderDoingRow(rowData);
    }
  },
  renderDoingRow: function(signup) {
    return (
      <TouchableHighlight onPress={() => this._onPressRow(signup)}>
        <View style={styles.row}>
          <Text style={[Style.textHeading, Style.textColorCtaBlue]}>
            {signup.campaign.title}
          </Text>
          <Text style={Style.textBody}>
            {signup.campaign.tagline}
          </Text>
        </View>
      </TouchableHighlight>
    );
  },
  renderDoneRow: function(rowData) {
    return (
      <TouchableHighlight onPress={() => this._onPressRow(rowData)}>
        <View>
          <ReportbackItemView
            key={rowData.reportbackItem.id}
            reportbackItem={rowData.reportbackItem}
            reportback={rowData.reportback} 
            campaign={rowData.campaign}
            user={this.props.user}
            share={this.props.isSelfProfile}
          />
        </View>
      </TouchableHighlight>
    );
  },
  _onPressRow(rowData) {
    Bridge.pushCampaign(Number(rowData.campaign.id));
  },
});

var styles = React.StyleSheet.create({
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
  noActionsContainer : {
    flex: 1,  
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 33,
    paddingRight: 33,
    paddingTop: 18,
  },
  headerContainer: {
    alignItems: 'center',
    flex: 1,
    backgroundColor: 'transparent',
    paddingTop: 20,
  },
  headerBackgroundImage: {
    flex: 1,
    height: 160,
    alignItems: 'stretch',    
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderColor: 'white',
    borderWidth: 2,
    alignItems: 'center',
  },
  headerText: {
    color: 'white',
    opacity: 0.50,
    flex: 1,
    textAlign: 'center',
    paddingTop: 4,
  },
  row: {
    backgroundColor: 'white',
    padding: 8,
  },
});

module.exports = UserView;