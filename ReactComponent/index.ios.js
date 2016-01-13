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

var NewsStoryBox = React.createClass({
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
    fetch(REQUEST_URL)
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
        <Text style={styles.year}>>
          Loading news...
        </Text>
      </View>
    );
  },
  renderNewsStory: function(newsStory) {
    return (
      <View style={styles.container}>
        <Image
          source={{uri: newsStory.attachments[0].url}}
          style={styles.thumbnail}
        />
        <View style={styles.rightContainer}>
          <Text style={styles.title}>{newsStory.title.toUpperCase()}</Text>
          <Text style={styles.year}>{newsStory.custom_fields.subtitle}</Text>
          <TouchableHighlight onPress={this._onPressButton}>
            <Text style={styles.title}>{TAKE_ACTION_TEXT.toUpperCase()}</Text>
          </TouchableHighlight>
        </View>
      </View>
    );
  },
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  thumbnail: {
    width: 53,
    height: 81,
  },
  rightContainer: {
    flex: 1,
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
});

AppRegistry.registerComponent('NewsStoryBox', () => NewsStoryBox);
