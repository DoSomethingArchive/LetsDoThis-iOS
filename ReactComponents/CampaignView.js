'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  ListView,
  View,
  ActivityIndicatorIOS,
  RefreshControl,
  NativeAppEventEmitter
} from 'react-native';
import Dimensions from 'Dimensions';

var Style = require('./Style.js');
var Helpers = require('./Helpers.js');
var NetworkErrorView = require('./NetworkErrorView.js');
var ReportbackItemView = require('./ReportbackItemView.js');
var Bridge = require('react-native').NativeModules.LDTReactBridge;
var NetworkImage = require('./NetworkImage.js');

var CampaignView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      isRefreshing: false,
      id: this.props.id,
      campaign: this.props.campaign,
      loaded: false,
      error: false,
      signup: false,
      reportback: false,
    };
  },
  componentDidMount: function() {
    this.fetchData();
    this.activitySubscription = NativeAppEventEmitter.addListener(
      'currentUserActivity',
      (signup) => this.handleActivityEvent(signup),
    );
    this.campaignLoadedSubscription = NativeAppEventEmitter.addListener(
      'campaignLoaded',
      (campaign) => this.handleCampaignLoadedEvent(campaign),
    );
  },
  componentWillUnmount: function() {
    this.activitySubscription.remove();
    this.campaignLoadedSubscription.remove();
  },
  handleCampaignLoadedEvent: function(campaign) {
    if (Number(campaign.id) == this.props.id) {
      if (campaign.error) {
        this.setState({
          error: true,
        });
        return;
      }
      this.setState({
        campaign: campaign,
      });
      this.fetchData();
    }
  },
  handleActivityEvent: function(campaignActivity) {
    if (campaignActivity.campaign.id != this.props.id) {
      return;
    }
    if (!this.state.signup) {
      this.setState({
        signup: true,
      });
      return;
    }
    // If we have a quantity, this campaignActivityEvent is a Reportback.
    // @todo: Different handleEvent? This feels hacky.
    if (campaignActivity.quantity) {
      this.setState({
        reportback: campaignActivity,
      });    
    }
  },
  fetchData: function() {
    this.setState({
      error: false,
      loaded: false,
    });
    if (!this.state.campaign.id) {
      return;
    }
    var statusUrl = this.props.signupUrl;
    statusUrl += '&campaigns=' + this.props.id.toString();
    fetch(statusUrl)
      .then((response) => response.json())
      .catch((error) => this.catchError(error))
      .then((responseData) => {
        if (!responseData) {
          return;
        }
        this.fetchGalleryData();
        var signups = responseData.data;
        for (var i = 0; i < signups.length; i++) {
          var signup = signups[i];
          if (!signup.campaign_run.current) {
            continue;
          }
          this.setState({
            signup: true,
          });
          if (Helpers.reportbackItemExistsForSignup(signup)) {
            this.setState({
              reportback: signup.reportback,
            });
          }
        }
      })
      .done();
  },
  fetchGalleryData: function() {
    fetch(this.props.galleryUrl)
      .then((response) => response.json())
      .catch((error) => this.catchError(error))
      .then((responseData) => {
        if (!responseData) {
          return;
        }
        this.setState({
          dataSource: this.state.dataSource.cloneWithRows(responseData.data),
          loaded: true,
          error: null,
        });
      })
      .done();
  },
  catchError: function(error) {
    this.setState({
      error: error,
      loaded: true,
    });
  },
  renderLoadingView: function() {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          Loading action...
        </Text>
      </View>
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
  render: function() {
    if (this.state.error) {
      return (
        <NetworkErrorView
          title="Action isn't loading right now"
          retryHandler={null}
          errorMessage={this.state.error.message}
        />);
    }
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }
    return (      
      <ListView
      dataSource={this.state.dataSource}
      renderHeader={this.renderHeader}
      renderRow={this.renderRow}
      refreshControl= {
        <RefreshControl
          refreshing={this.state.isRefreshing}
          onRefresh={this._onRefresh}
          tintColor="#CCC"
          colors={['#ff0000', '#00ff00', '#0000ff']}
          progressBackgroundColor="#ffff00"
        />}
      />
    );
  },
  _onPressActionButton: function() {
    if (!this.state.signup) {
      Bridge.postSignup(Number(this.props.id));
    }
    else {
      Bridge.presentProveIt(Number(this.props.id));
    }
  },
  renderActionButton: function() {
    var actionButtonText;
    if (this.state.reportback.id) {
      return null;
    }
    else if (this.state.signup) {
      actionButtonText = 'Prove it';
    }
    else {
      actionButtonText = 'Do this now';
    }
    return (
      <View style={styles.content}>
        <TouchableHighlight style={[Style.actionButton, styles.content]} onPress={() => this._onPressActionButton()}>
          <Text style={Style.actionButtonText}>
            {actionButtonText.toUpperCase()}
          </Text>
        </TouchableHighlight>
      </View>
    );
  },
  renderClosedContent: function(message) {
    return (
      <View>
        <Text style={[Style.textBody, {textAlign: 'center', padding: 20}]}>
          {message}
        </Text>
      </View>
    );
  },
  renderCampaignContent: function() {
    if (!this.state.signup) {
      return null;
    }
    var solutionText, solutionSupportText;
    if (this.state.campaign.solutionCopy.length > 0) {
      solutionText = this.renderCampaignContentText(this.state.campaign.solutionCopy);
    }
    if (this.state.campaign.solutionSupportCopy.length > 0) {
      solutionSupportText = this.renderCampaignContentText(this.state.campaign.solutionSupportCopy);
    }
    var submitCopy = "When you're done, submit a pic of yourself in action. #picsoritdidnthappen";
    var submitText = this.renderCampaignContentText(submitCopy);

    var selfReportback;
    if (this.state.reportback.id) {
      selfReportback = (
        <ReportbackItemView
          key={this.state.reportback.id}
          reportbackItem={this.state.reportback.reportback_items.data[0]}
          reportback={this.state.reportback}
          campaign={this.state.campaign}
          user={this.props.currentUser}
          share={true}
        />
      );
    }
    return (
      <View>
        <View style={Style.sectionHeader}>
          <Text style={Style.sectionHeaderText}>
            {'Do it'.toUpperCase()}
          </Text>
        </View>
        <View style={styles.content}>
          {solutionText}
          {solutionSupportText}
          {submitText}
        </View>
        {selfReportback}
      </View>
    );
  },
  renderCampaignContentText: function(copy) {
    return (
      <Text style={[Style.textBody, styles.contentText]}>{copy}</Text>
    );
  },
  renderCover: function() {
    var campaign = this.state.campaign;
    if (campaign.image_url.length == 0) {
      campaign.image_url = 'Placeholder Image Download Fails';
    }
    var titleView = (
      <View style={styles.titleContainer}>
        <Text style={[Style.textTitle, styles.centeredTitleText]}>
          {campaign.title.toUpperCase()}
        </Text>
      </View>
    );

    return (
      <View>
        <View>
          <NetworkImage
            style={styles.coverImage}
            source={{uri: campaign.image_url}}
            content={titleView}
            displayProgress={true}
          />
        </View>
        <Text style={[Style.textSubheading, styles.tagline]}>
          {campaign.tagline}
        </Text>
      </View>
    );
  },
  renderHeader: function() {
    var content;
    if (this.state.campaign.status != 'active') {
      var message = "Ayy! This campaign is closed. Go back a page for actions you can do right now.";
      content = this.renderClosedContent(message);
    }
    else if (this.state.campaign.type != 'campaign') {
      var message = "This action is only available via SMS.";
      content = this.renderClosedContent(message);
    }
    else {
      content = (
        <View>
          {this.renderCampaignContent()}
          {this.renderActionButton()}
        </View>
      );
    }
    return (
      <View>
        {this.renderCover()}
        {content}
        <View style={[Style.sectionHeader, {marginTop: 4,}]}>
          <Text style={Style.sectionHeaderText}>
            {"Who's doing it now".toUpperCase()}
          </Text>
        </View>
      </View>
    );
  },
  renderRow: function(rowData) {
    return (
      <TouchableHighlight onPress={() => this._onPressRow(rowData.user)}>
        <View>
          <ReportbackItemView
            key={rowData.id}
            reportbackItem={rowData}
            reportback={rowData.reportback}
            campaign={rowData.campaign}
            user={rowData.user}
            share={false}
          />
        </View>
      </TouchableHighlight>
    );
  },
  _onPressRow: function(user) {
    Bridge.pushUser(user);
  }
});

var styles = React.StyleSheet.create({
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  coverImage: {
    flex: 1,
    height: 242,
    alignItems: 'stretch',
  },
  titleContainer: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    alignItems: 'flex-end',
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
    padding: 20,
    textAlign: 'center',
  },
  content: {
    padding: 8,
  },
  contentText: {
    paddingBottom: 12,
  }
});


module.exports = CampaignView;
