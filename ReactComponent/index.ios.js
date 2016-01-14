/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
  AppRegistry,
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
        renderRow={this.renderNewsStory}
        style={styles.listView}
      />
    );
  },
  renderLoadingView: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.year}>
          Loading news...
        </Text>
      </View>
    );
  },
  renderNewsStory: function(newsStory) {
    return (
      <View style={styles.container}>
        <View style={styles.newsStory}>
          <Image
          source={{uri: newsStory.attachments[0].url}}
          style={styles.thumbnail}
          />
          <Text style={styles.title}>{newsStory.title.toUpperCase()}</Text>
          <Text style={styles.year}>{newsStory.custom_fields.subtitle}</Text>
          <TouchableHighlight onPress={this.ctaButtonPressed.bind(this, newsStory)} style={styles.button} underlayColor='#3731A9'>
            <Text style={styles.buttonText}>{TAKE_ACTION_TEXT.toUpperCase()}</Text>
          </TouchableHighlight>
        </View>
      </View>
    );
  },
  ctaButtonPressed: function(newsStory) {
    var campaignID = newsStory.custom_fields.campaign_id[0];
    var NewsFeedViewController = require('react-native').NativeModules.LDTNewsFeedViewController;
    NewsFeedViewController.presentCampaign(campaignID);
  },
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#EEE',
  },
  thumbnail: {
    height: 100,
  },
  newsStory: {
    flex: 1,
    margin: 16,
    backgroundColor: '#FFF',
    borderColor: '#ccc',
    borderWidth: 1,
  },
  title: {
    fontSize: 20,
    marginBottom: 8,
    fontFamily: 'BrandonGrotesque-Bold',
  },
  year: {
    fontFamily: 'Brandon Grotesque',
  },
  listView: {
    paddingTop: 20,
    backgroundColor: '#F5FCFF',
  },
  buttonText: {
    fontSize: 18,
    color: 'white',
    alignSelf: 'center',
    fontFamily: 'BrandonGrotesque-Bold',
  },
  button: {
    height: 50,
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#3731A9',
    borderColor: '#FFF',
    marginBottom: 10,
    alignSelf: 'stretch',
    justifyContent: 'center'
  },
});

AppRegistry.registerComponent('NewsFeedView', () => NewsFeedView);
