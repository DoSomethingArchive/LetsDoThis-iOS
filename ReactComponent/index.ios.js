/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
  AppRegistry,
  ActivityIndicatorIOS,
  ListView,
  Component,
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  View
} from 'react-native';


var REQUEST_URL = 'http://dev-ltd-news.pantheon.io/?json=1';
var TAKE_ACTION_TEXT = 'Take action';

var NewsFeedView = React.createClass({
  getInitialState: function() {
    return {
      dataSource: new ListView.DataSource({
        rowHasChanged: (row1, row2) => row1 !== row2,
      }),
      loaded: false,
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
        });
      })
      .done();
  },
  render: function() {
    if (!this.state.loaded) {
      return this.renderLoadingView();
    }

    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderPost}
        style={styles.listView}
      />
    );
  },
  renderLoadingView: function() {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicatorIOS animating={this.state.animating} style={[{height: 80}]} size="small" />
        <Text style={styles.subtitle}>
          Loading news...
        </Text>
      </View>
    );
  },
  renderPost: function(post) {
    var imgBackground;
    if (typeof post !== 'undefined'
        && typeof post.attachments[0] !== 'undefined'
        && typeof post.attachments[0].images !== 'undefined'
        && typeof post.attachments[0].images.full !== 'undefined') {
        imgBackground = <Image
          style={{flex: 1, height: 128, alignItems: 'stretch'}}
          source={{uri: post.attachments[0].images.full.url}}>
            <View style={styles.titleContainer}>
              <Text style={styles.title}>{post.title.toUpperCase()}</Text>
            </View>
          </Image>;
    }
    else {
      imgBackground = <Text style={styles.title}>{post.title.toUpperCase()}</Text>;
    }

    return(
      <View style={styles.postContainer}>
        <View style={styles.postHeader}>
          <Text style={styles.date}>{post.date}</Text>
        </View>
        {imgBackground}
        <View style={styles.postBody}>
          <Text style={styles.subtitle}>{post.custom_fields.subtitle}</Text>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryText}>* {post.custom_fields.summary_1}</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryText}>* {post.custom_fields.summary_2}</Text>
          </View>
          <View style={styles.summaryItem}>
            <Text style={styles.summaryText}>* {post.custom_fields.summary_3}</Text>
          </View>
          <Text
            onPress={this.fullArticlePressed.bind(this, post.custom_fields.full_article_url)}
            style={styles.articleLink}>
            Read the full article
          </Text>
        </View>
        <TouchableHighlight onPress={this.ctaButtonPressed.bind(this, post)} style={styles.btn}>
          <Text style={styles.btnText}>{TAKE_ACTION_TEXT.toUpperCase()}</Text>
        </TouchableHighlight>
      </View>
    );
  },
  ctaButtonPressed: function(post) {
    var campaignID = post.custom_fields.campaign_id[0];
    var NewsFeedViewController = require('react-native').NativeModules.LDTNewsFeedViewController;
    NewsFeedViewController.presentCampaign(campaignID);
  },
  fullArticlePressed: function(url) {
    console.log(url);
  },
});

var styles = React.StyleSheet.create({
  postBody: {
    padding: 10,
  },
  postContainer: {
    backgroundColor: '#ffffff',
    marginTop: 10
  },
  loadingContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
  postHeader: {
    backgroundColor: '#00e4c8',
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
    padding: 4,
  },
  postHeaderText: {
    color: '#ffffff',
  },
  articleLink: {
    color: '#3932A9',
    fontFamily: 'BrandonGrotesque-Bold',
  },
  btn: {
    backgroundColor: '#3932A9',
    borderBottomLeftRadius: 4,
    borderBottomRightRadius: 4,
    paddingBottom: 10,
    paddingTop: 10,
  },
  btnText: {
    color: '#ffffff',
    fontFamily: 'Brandon Grotesque',
    fontSize: 16,
    textAlign: 'center',
  },
  date: {
    color: '#ffffff',
    fontFamily: 'Brandon Grotesque',
  },
  listView: {
    backgroundColor: '#eeeeee',
    paddingLeft: 10,
    paddingRight: 10,
    paddingBottom: 10,
  },
  subtitle: {
    color: '#454545',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 16,
  },
  summaryItem: {
    flex: 1,
    flexDirection: 'row',
    marginBottom: 8,
    marginTop: 8,
  },
  summaryText: {
    flex: 1,
    flexDirection: 'column',
    fontFamily: 'Brandon Grotesque',
    marginLeft: 4,
  },
  title: {
    color: '#ffffff',
    flex: 1,
    flexDirection: 'column',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 20,
    textAlign: 'center',
  },
  titleContainer: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    alignItems: 'center',
    flex: 1,
    flexDirection: 'row',
    padding: 20,
  },
});
AppRegistry.registerComponent('NewsFeedView', () => NewsFeedView);
