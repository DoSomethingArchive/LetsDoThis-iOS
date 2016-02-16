'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  View
} from 'react-native';

var Helpers = require('./Helpers.js');
var Style = require('./Style.js');
var Bridge = require('react-native').NativeModules.LDTReactBridge;

var NewsFeedPost = React.createClass({
  getInitialState() {
    return {
      imageCreditHidden: true,
    };
  },
  _onPressActionButton: function() {
    Bridge.pushCampaign(this.props.post.campaign_id);
  },
  _onPressFullArticleButton: function() {
    Bridge.presentNewsArticle(this.props.post.id, this.props.post.full_article_url);
  },
  _onPressImageCreditButton: function() {
    this.setState({
      imageCreditHidden: !this.state.imageCreditHidden,
    });
  },
  renderFullArticleButton: function () {
    var post = this.props.post;
    if (post.full_article_url.length > 0) {
      return (
        <Text
          onPress={this._onPressFullArticleButton}
          style={[Style.textBodyBold, Style.textColorCtaBlue]}>
            Read the full article
        </Text>
      );
    }
    return null;
  },
  renderImage: function() {
    var post = this.props.post;
    
    if (post.image_url.length > 0) {
      var viewImageCredit = null;
      if (post.photo_credit.length > 0) {
        var imageCreditOpacity = 1;
        if (this.state.imageCreditHidden) {
          imageCreditOpacity = 0;
        }
        viewImageCredit = (
          <View style={styles.imageCreditContainer}>
            <View style={[styles.imageCreditTextContainer, {opacity: imageCreditOpacity}]} >
              <Text style={[Style.textBody, {color: 'white'}]}>{post.photo_credit}</Text>
            </View>
            <TouchableHighlight onPress={this._onPressImageCreditButton}>
              <Image
                style={styles.imageCreditButton}
                source={require('image!Info Icon')}
              />  
            </TouchableHighlight>
          </View>
        );
      }
      return (
        <Image
          style={styles.image}
          source={{uri: post.image_url}}>
          {viewImageCredit}
        </Image>
      );
    }
    return null;
  },
  renderSummaryItem: function(summaryItemText) {
    if (summaryItemText.length > 0) {
      return (
        <View style={styles.summaryItem}>
          <View style={styles.summaryItemOvalContainer}>
            <Image source={require('image!listitem-oval')} />
          </View>
          <Text style={[Style.textBody, styles.summaryText]}>{summaryItemText}</Text>
        </View>
      );
    }
    return null;
  },
  render: function() {
    var post = this.props.post;
    var postTitle = Helpers.convertUnicode(post.title);
    var causeTitle, causeStyle = null;
    if (post.categories.length > 0) {
      causeTitle = post.categories[0].title;
      causeStyle = {backgroundColor: '#' + post.categories[0].hex};
    }

    return(
      <View style={[styles.wrapper]}>
        <View style={[styles.header, causeStyle]}>
          <Text style={[Style.textCaptionBold, {color: 'white'}]}>{Helpers.formatDate(post.date)}</Text>
          <View style={styles.causeContainer}>
            <Text style={[Style.textCaptionBold, {color: 'white'}]}>{causeTitle}</Text>
          </View>
        </View>
        {this.renderImage()}
        <View style={styles.content}>
          <Text style={Style.textHeading}>{postTitle.toUpperCase()}</Text>
          {this.renderSummaryItem(post.summary_1)}
          {this.renderSummaryItem(post.summary_2)}
          {this.renderSummaryItem(post.summary_3)}
          {this.renderFullArticleButton()}
        </View>
        <TouchableHighlight onPress={this._onPressActionButton} style={styles.actionButton}>
          <Text style={[Style.textBodyBold, styles.actionButtonText]}>
            {'Take action'.toUpperCase()}
          </Text>
        </TouchableHighlight>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  wrapper: {
    backgroundColor: '#FFFFFF', 
    marginTop: 14,
    marginLeft: 7,
    marginRight: 7,
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
  },
  header: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#00e4c8',
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    padding: 4,
  },
  causeContainer: {
    flex: 1,
    alignItems: 'flex-end',
  },
  content: {
    padding: 20,
  },
  fullArticleButton: {
    marginTop: 14,
  },
  actionButton: {
    backgroundColor: '#3932A9',
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
    paddingBottom: 12,
    paddingTop: 12,
    height: 50,
  },
  actionButtonText: {
    color: '#ffffff',
    textAlign: 'center',
  },
  image: {
    flex: 1, 
    height: 180, 
    justifyContent: 'flex-end',
  },
  imageCreditContainer: {
    backgroundColor: 'transparent',
    margin: 8,
  },
  imageCreditButton: {
    tintColor: '#FFFFFF',
    width: 20, 
    height: 20,
    position: 'absolute',
    bottom: 0,
    right: 0,
  },
  imageCreditTextContainer: {
    backgroundColor: 'rgba(0,0,0,0.66)',
    paddingTop: 6,
    paddingBottom: 6,
    paddingLeft: 15,
    paddingRight: 15,
    marginRight: 37,
    flex: 1,
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
  },
  imageCreditText: {
    color: '#FFFFFF',
  },
  // View container to center the image against just a single line of text
  summaryItemOvalContainer: {
    // This height is based off the draw height of a single summaryText line
    height: 21.5,
    justifyContent: 'center',
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
    marginLeft: 4,
  },
});

module.exports = NewsFeedPost;