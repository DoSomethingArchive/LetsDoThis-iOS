'use strict';

import React, {
  Component,
  StyleSheet,
  Text,
  Image,
  ActivityIndicatorIOS,
  View,
} from 'react-native';
import Dimensions from 'Dimensions';
var Style = require('./Style.js');

// Borrowed heavily from the React Native Image example
// @see https://facebook.github.io/react-native/docs/image.html#examples

var NetworkImage = React.createClass({
  getInitialState: function() {
    return {
      error: false,
      loading: false,
      progress: 0
    };
  },
  render: function() {
    // This code isn't displaying inside image when I move it to different renderLoader function ;(
    var progressView = null;
    if (this.props.displayProgress) {
      progressView = 
        <View style={styles.progressView}>
          <ActivityIndicatorIOS style={{marginRight:5}}/>
          <Text style={[Style.textCaption, styles.progressText]}>{this.state.progress}%</Text>
        </View>;
    }
    var loaderView = 
      <View style={styles.progress}>
        <View style={styles.loadingImageContainer}>
          <Image source={{uri: 'Placeholder Image Loading'}} style={styles.loadingImage} />
        </View>
        {progressView}
      </View>;

    var content = this.state.loading ? loaderView : this.props.content;
    return this.state.error ?
      <Image
        source={{uri: 'Placeholder Image Download Fails'}}
        style={this.props.style}
      /> :
      <Image
        source={this.props.source}
        style={this.props.style}
        onLoadStart={(e) => this.setState({loading: true})}
        onError={(e) => this.setState({error: e.nativeEvent.error, loading: false})}
// HOTFIX -- This line crashes on iPhone 5
// @see https://github.com/DoSomething/LetsDoThis-iOS/issues/1013
//        onProgress={(e) => this.setState({progress: Math.round(100 * e.nativeEvent.loaded / e.nativeEvent.total)})}
        onLoad={() => this.setState({loading: false, error: false})}>
        {content}
      </Image>;
  }
});

var styles = StyleSheet.create({
  progress: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
    backgroundColor: '#EEE',
    justifyContent: 'center',
  },
  progressView: {
    flexDirection: 'row',
    backgroundColor: '#EEE',
    borderRadius: 6,
    padding: 8,
  },
  loadingImageContainer: {
    position: 'absolute',
    top: 0, 
    bottom: 0,
    left: 0,
    right: 0,
  },
  loadingImage: {
    flex: 1,
    resizeMode: 'stretch',
  },
});

module.exports = NetworkImage;
