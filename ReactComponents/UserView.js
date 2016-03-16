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
var Helpers = require('./Helpers.js');
var NetworkErrorView = require('./NetworkErrorView.js');
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
      // Because selfProfile can change user data, we need to store user in state.
      user: this.props.user,
    };
  },
  componentDidMount: function() {
    if (this.props.isSelfProfile) {
      this.userActivitySubscription = NativeAppEventEmitter.addListener(
        'currentUserActivity',
        (signup) => this.handleUserActivityEvent(signup),
      );
      this.userChangedSubscription = NativeAppEventEmitter.addListener(
        'currentUserChanged',
        (user) => this.handleUserChangedEvent(user),
      );
    }
    this.fetchData();
  },
  componentWillUnmount: function() {
    if (this.props.isSelfProfile) {
      this.userActivitySubscription.remove();
      this.userChangedSubscription.remove();
    }
  },
  handleUserChangedEvent: function(user) {
    console.log("handleUserChangedEvent");
    this.state.user = user;
    this.fetchData();
  },
  handleUserActivityEvent: function(campaignActivity) {
    this.fetchData();
  },
  fetchData: function() {
    this.setState({
      error: false,
      loaded: false,
    });
    var options = { 
      method: 'GET',
      timeout: 30000,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Session': this.props.sessionToken,
        'X-DS-REST-API-Key': this.props.apiKey,
      },
    };
    // Grab 200 records for now until we add paginated requests.
    var url = this.props.baseUrl + 'signups?user=' + this.state.user.id + '&count=200';
    fetch(url, options)
      .then((response) => response.json())
      .catch((error) => this.catchError(error))
      .then((responseData) => {
        // This was added because of this https://github.com/DoSomething/LetsDoThis-iOS/pull/853#discussion_r54018442
        if (!responseData) {
          // You'd assume error should be undefined here since the catch isn't firing
          console.log(error);
          this.setState({
            error: error,
          });
          return;
        }
        if (responseData.error) {
          this.setState({
            error: responseData.error,
          });
          return;
        }
        if (responseData.data) {
          this.loadSignups(responseData.data);
        }
      })
      .done();
  },
  loadSignups: function(signups) {
    var dataBlob = {},
      sectionIDs = [],
      rowIDs = [],
      doing = [],
      done = [];

    sectionIDs.push(0);
    dataBlob[0] = firstSectionHeaderText;
    rowIDs[0] = [];
    sectionIDs.push(1);
    dataBlob[1] = secondSectionHeaderText;
    rowIDs[1] = [];

    for (let i = 0; i < signups.length; i++) {
      let signup = signups[i];

      // Data safety check:
      if ((!signup.campaign) || (!signup.campaign_run)) {
        continue;
      }
      
      if (Helpers.reportbackItemExistsForSignup(signup)) {
        signup.reportbackItem = signup.reportback.reportback_items.data[0];
        done.push(signup);
      }
      else {
        if (!signup.campaign_run.current) {
          continue;
        }
        if (signup.campaign.status != 'active' || signup.campaign.type != 'campaign') {
          continue;
        }
        doing.push(signup);
      }
    }

    doing.sort(function(a, b) { 
      return b.id - a.id;
    }); 
    for (let i = 0; i < doing.length; i++) {
      let signup = doing[i];
      rowIDs[0].push(signup.id);
      dataBlob['0:' + signup.id] = signup;
    }

    done.sort(function(a, b) { 
      return b.reportbackItem.id - a.reportbackItem.id;
    });
    for (let i = 0; i < done.length; i++) {
      let signup = done[i];
      rowIDs[1].push(signup.id);
      dataBlob['1:' + signup.id] = signup;
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
    console.log("UserView.catchError");
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
      // @todo Refactor NetworkErrorView to accept error object, instead of errorMessage
      return (
        <NetworkErrorView
          title="Profile isn't loading right now"
          retryHandler={this.fetchData}
          errorMessage={this.state.error.message}
        />
      );
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
    var avatarUri = this.state.user.photo;
    if (avatarUri.length == 0) {
      avatarUri =  'Avatar';
    }
    var headerText = null;
    if (this.state.user.country && this.state.user.country.length > 0) {
      headerText = this.state.user.country.toUpperCase();
    }
    var avatar = (
      <Image
        style={styles.avatar}
        defaultSource={{uri: 'Placeholder Image Loading'}}
        source={{uri: avatarUri}}
      />
    );
    if (this.props.isSelfProfile) {
      avatar = (
        <TouchableHighlight onPress={() => Bridge.presentAvatarAlertController()}>
          {avatar}
        </TouchableHighlight>
      );
    }
    return (
      <View style={styles.headerContainer}>
        <Image
          style={styles.headerBackgroundImage}
          source={require('image!Gradient Background')}>
          <View style={styles.avatarContainer}>
            {avatar}
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
    if (rowData.reportbackItem) {
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
          <View style={styles.contentContainer}>
            <Text style={[Style.textHeading, Style.textColorCtaBlue]}>
              {signup.campaign.title}
            </Text>
            <Text style={Style.textBody}>
              {signup.campaign.tagline}
            </Text>
          </View>
          <View style={styles.detailContainer}>
            <View style={styles.arrowContainer}>
              <Image
                style={styles.arrowImage}
                source={require('image!Arrow')}
              />
            </View>
          </View>
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
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarContainer: {
    paddingTop: 20,
    alignItems: 'center',
  },
  headerBackgroundImage: {
    height: 160,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderColor: 'white',
    borderWidth: 2,
  },
  headerText: {
    color: 'white',
    opacity: 0.50,
    paddingTop: 4,
    alignItems: 'center',
    backgroundColor: 'transparent',
  },
  row: {
    backgroundColor: 'white',
    padding: 8,
    flex: 1,
    flexDirection: 'row',
  },
  contentContainer: {
    flex: 1,
  },
  detailContainer: {
    width: 28,
    padding: 12,
  },
  arrowContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  arrowImage: {
    width: 12,
    height: 21,
  }
});

module.exports = UserView;