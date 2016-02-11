'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  ListView,
  View,
  ActivityIndicatorIOS,
  RefreshControl
} from 'react-native';
import Dimensions from 'Dimensions';

var Style = require('./Style.js');
var ReportbackItemView = require('./ReportbackItemView.js');
var CampaignViewController = require('react-native').NativeModules.LDTCampaignViewController;

var CampaignView = React.createClass({
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
          dataSource: this.state.dataSource.cloneWithRows(responseData.data),
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
      <View>
        {this.renderCover()}
        <View style={styles.loadingContainer}>
          <Text style={Style.textBody}>
            Epic Fail
          </Text>
        </View>
      </View>
    );
  },
  renderLoadingView: function() {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={Style.textBody}>
          Loading photos...
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
      return this.renderError();
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
    console.log('Tappy');
  },
  renderActionButton: function() {
    // @todo: If reportback, return selfReportback;
    var actionButtonText = 'Do this now';
    if (this.props.currentUserSignup.id) {
      var actionButtonText = 'Prove it';
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
  renderClosedContent: function() {
    return (
      <View>
        <Text style={[Style.textBody, {textAlign: 'center', padding: 20}]}>
          This action is no longer available. 
        </Text>
      </View>
    );
  },
  renderCampaignContent: function() {
    if (!this.props.currentUserSignup.id) {
      return null;
    }

    return (
      <View>
        <View style={Style.sectionHeader}>
          <Text style={Style.sectionHeaderText}>
            {'Do it'.toUpperCase()}
          </Text>
        </View>
        <View style={styles.content}>
          <Text style={[Style.textBody, styles.paragraph]}>
            {this.props.campaign.solutionCopy}
          </Text>
          <Text style={[Style.textBody, styles.paragraph]}>
            {this.props.campaign.solutionSupportCopy}
          </Text>
          <Text style={[Style.textBody, styles.paragraph]}>
            When you’re done, submit a pic of yourself in action. #picsoritdidnthappen
          </Text>
        </View>
      </View>
    );
  },
  renderCover: function() {
    var campaign = this.props.campaign;
    if (campaign.image_url.length == 0) {
      campaign.image_url = 'https://placekitten.com/g/600/600';
    }
    return (
      <View>
        <View style={styles.coverImageContainer}>
          <Image
            style={styles.coverImage}
            source={{uri: campaign.image_url}}>
            <View style={styles.titleContainer}>
              <Text style={[Style.textTitle, styles.centeredTitleText]}>
                {campaign.title.toUpperCase()}
              </Text>
            </View>
          </Image>
        </View>
        <Text style={[Style.textSubheading, styles.tagline]}>
          {campaign.tagline}
        </Text>
      </View>
    );
  },
  renderHeader: function() {
    var content;
    if (this.props.campaign.status == 'closed') {
      content= this.renderClosedContent();
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
          />
        </View>
      </TouchableHighlight>
    );
  },
  _onPressRow: function(user) {
    CampaignViewController.presentUser(user);
  }
});

// @todo: shadownotworking 
// @see https://github.com/facebook/react-native/issues/449#issuecomment-157874168
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
  paragraph: {
    paddingBottom: 12,
  }
});


module.exports = CampaignView;