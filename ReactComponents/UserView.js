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
  View
} from 'react-native';

var Style = require('./Style.js');
var UserViewController = require('react-native').NativeModules.LDTUserViewController;
var ReportbackItemView = require('./ReportbackItemView.js');

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
    };
  },
  componentDidMount: function() {
    this.fetchData();
  },
  componentWillUpdate: function() {
    this.fetchData();
  },
  fetchData: function() {
    var options = { 
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Session': UserViewController.session,
        'X-DS-REST-API-Key': UserViewController.apiKey,
      },
    };
    fetch(this.props.url, options)
      .then((response) => response.json())
      .then((responseData) => {
        var signups = responseData.data,
          dataBlob = {},
          sectionIDs = [],
          rowIDs = [],
          i;

        sectionIDs.push(0);
        dataBlob[0] = "Actions I'm doing";
        rowIDs[0] = [];
        sectionIDs.push(1);
        dataBlob[1] = "Actions I've done";
        rowIDs[1] = [];
        for (i = 0; i < signups.length; i++) {
          var signup = signups[i];
          var sectionNumber = 0;
          if (signup.reportback_data) {
            sectionNumber = 1;
          }
          rowIDs[sectionNumber].push(signup.signup_id);
          dataBlob[sectionNumber + ':' + signup.signup_id] = signup;
        }

        this.setState({
          dataSource : this.state.dataSource.cloneWithRowsAndSections(dataBlob, sectionIDs, rowIDs),
          loaded: true,
        });
      })
      .done();
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
  render: function() {
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }
    return (
      <ListView
        style={Style.backgroundColorCtaBlue}
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderHeader={this.renderHeader}
        renderSectionHeader = {this.renderSectionHeader}
        refreshControl={
          <RefreshControl
            refreshing={this.state.isRefreshing}
            onRefresh={this._onRefresh}
            tintColor="white"
            colors={['#ff0000', '#00ff00', '#0000ff']}
            progressBackgroundColor="#ffff00"
          />
        }
      />
    );
  },
  renderHeader: function() {
    var avatarURL = this.props.user.avatarURL;
    if (avatarURL.length == 0) {
      this.props.user.avatarURL = 'https://placekitten.com/g/600/600';
    }
    return (
      <View style={[Style.backgroundColorCtaBlue, styles.headerContainer]}>
        <Image
          style={styles.avatar}
          source={{uri: this.props.user.avatarURL}}
        />
        <Text style={[Style.textTitle, styles.headerText]}>
          {this.props.user.displayName.toUpperCase()}
        </Text>
        <Text style={[Style.textHeading, styles.headerText]}>
          {this.props.user.countryName.toUpperCase()}
        </Text>
      </View>
    );
  },
  renderSectionHeader(sectionData, sectionID) {
    return (
      <View style={styles.sectionContainer}>
        <Text style={[Style.textHeading, {textAlign: 'center'}]}>
          {sectionData.toUpperCase()}
        </Text>
      </View>
    );
  },
  renderRow: function(signup) {
    if (!signup.drupal_id) {
      return null;
    }
    if (signup.reportback_data) {
      return this.renderDoneRow(signup);
    }
    else {
      return this.renderDoingRow(signup);
    }
  },
  renderDoingRow: function(signup) {
    var campaignIDString = signup.drupal_id.toString();
    var campaign = UserViewController.campaigns[campaignIDString];
    if (this.props.isSelfProfile) {
      // Render Prove It button
    }
    return (
      <TouchableHighlight onPress={() => this._onPressDoingRow(signup)}>
        <View style={styles.row}>
          <Text style={[Style.textHeading, Style.textColorCtaBlue]}>
            {campaign.title}
          </Text>
          <Text style={Style.textBody}>
            {campaign.tagline}
          </Text>
        </View>
      </TouchableHighlight>
    );
  },
  renderDoneRow: function(signup) {
    return (
      <ReportbackItemView
        key={signup.reportback_id}
        reportback={signup.reportback_data} />
    );
  },
  _onPressRow(signup) {
    UserViewController.presentCampaign(Number(signup.drupal_id));
  },
  _onPressDoingRow(signup) {
    var campaignID = Number(signup.drupal_id);
    if (this.props.isSelfProfile) {
      UserViewController.presentProveIt(campaignID);
    }
    else {
      UserViewController.presentCampaign(campaignID);
    }
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
  headerContainer: {
    alignItems: 'center',
    flex: 1,
    padding: 20,
  },
  sectionContainer: {
    backgroundColor: '#F8F8F6',
    padding: 14,
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
    flex: 1,
    textAlign: 'center',
  },
  row: {
    backgroundColor: 'white',
    padding: 8,
  },
});

module.exports = UserView;