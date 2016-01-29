'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  View
} from 'react-native';

var Helpers = require('./Helpers.js');
var NewsFeedViewController = require('react-native').NativeModules.LDTNewsFeedViewController;

var NewsFeedPost = React.createClass({
  getInitialState() {
    return {
      imageCreditHidden: true,
    };
  },
  _onPressActionButton: function() {
    var campaignID = this.props.post.custom_fields.campaign_id[0];
    NewsFeedViewController.presentCampaignWithCampaignID(campaignID);
  },
  _onPressFullArticleButton: function() {
    var urlString = this.props.post.custom_fields.full_article_url[0];
    NewsFeedViewController.presentFullArticle(this.props.post.id, urlString);
  },
  _onPressImageCreditButton: function() {
    this.setState({
      imageCreditHidden: !this.state.imageCreditHidden,
    });
  },
  renderFullArticleButton: function () {
    var post = this.props.post;
    if (typeof post.custom_fields.full_article_url !== 'undefined'
        && typeof post.custom_fields.full_article_url[0] !== 'undefined'
        && post.custom_fields.full_article_url[0]) {
      return (
        <Text
          onPress={this._onPressFullArticleButton}
          style={styles.fullArticleButton}>
            Read the full article
        </Text>
      );
    }
    return null;
  },
  renderImage: function() {
    var post = this.props.post;
    
    if (typeof post.attachments[0] !== 'undefined'
        && typeof post.attachments[0].images !== 'undefined'
        && typeof post.attachments[0].images.full !== 'undefined') {

      var viewImageCredit = null;
      var imageCreditText = post.custom_fields.photo_credit[0];
      if (imageCreditText.length > 0) {
        var imageCreditOpacity = 1;
        if (this.state.imageCreditHidden) {
          imageCreditOpacity = 0;
        }
        viewImageCredit = (
          <View style={styles.imageCreditContainer}>
            <View style={[styles.imageCreditTextContainer, {opacity: imageCreditOpacity}]} >
              <Text style={styles.imageCreditText}>{imageCreditText}</Text>
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
          source={{uri: post.attachments[0].images.full.url}}>
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
          <Text style={styles.summaryText}>{summaryItemText}</Text>
        </View>
      );
    }
    return null;
  },
  render: function() {
    var post = this.props.post;
    var causeTitle, causeStyle = null;
    if (post.categories.length > 0) {
      causeTitle = post.categories[0].title;
      causeStyle = {backgroundColor: Helpers.causeBackgroundColor(causeTitle)};
    }

    return(
      <View style={[styles.wrapper]}>
        <View style={[styles.header, causeStyle]}>
          <Text style={styles.headerText}>{Helpers.formatDate(post.date)}</Text>
          <View style={styles.causeContainer}>
            <Text style={styles.headerText}>{causeTitle}</Text>
          </View>
        </View>
        {this.renderImage()}
        <View style={styles.content}>
          <Text style={styles.title}>{post.title.toUpperCase()}</Text>
          {this.renderSummaryItem(post.custom_fields.summary_1[0])}
          {this.renderSummaryItem(post.custom_fields.summary_2[0])}
          {this.renderSummaryItem(post.custom_fields.summary_3[0])}
          {this.renderFullArticleButton()}
        </View>
        <TouchableHighlight onPress={this._onPressActionButton} style={styles.actionButton}>
          <Text style={styles.actionButtonText}>{'Take action'.toUpperCase()}</Text>
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
  },
  header: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: '#00e4c8',
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    padding: 4,
  },
  headerText: {
    color: '#ffffff',
    fontFamily: 'Brandon Grotesque',
  },
  causeContainer: {
    flex: 1,
    alignItems: 'flex-end',
  },
  content: {
    padding: 20,
  },
  fullArticleButton: {
    color: '#3932A9',
    fontFamily: 'BrandonGrotesque-Bold',
    marginTop: 14,
  },
  actionButton: {
    backgroundColor: '#3932A9',
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
    paddingBottom: 10,
    paddingTop: 10,
  },
  actionButtonText: {
    color: '#ffffff',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 16,
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
    fontFamily: 'Brandon Grotesque',
    fontSize: 15,
  },
  title: {
    color: '#4A4A4A',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 20,
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
    color: '#4A4A4A',
    flex: 1,
    flexDirection: 'column',
    fontFamily: 'Brandon Grotesque',
    fontSize: 15,
    marginLeft: 4,
  },
});

module.exports = NewsFeedPost;