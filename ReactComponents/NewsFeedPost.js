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
  _onPressFullArticle: function() {
    var urlString = this.props.post.custom_fields.full_article_url[0];
    NewsFeedViewController.presentFullArticle(this.props.post.id, urlString);
  },
  _onPressImageCreditButton: function() {
    this.setState({
      imageCreditHidden: !this.state.imageCreditHidden,
    });
  },
  renderImage: function() {
    var post = this.props.post;
    
    if (typeof post.attachments[0] !== 'undefined'
        && typeof post.attachments[0].images !== 'undefined'
        && typeof post.attachments[0].images.full !== 'undefined') {

      var viewImageCredit = null;
      if (post.custom_fields.photo_credit[0].length > 0) {
        var imageCreditOpacity = 1;
        if (this.state.imageCreditHidden) {
          imageCreditOpacity = 0;
        }
        viewImageCredit = (
          <View style={styles.imageCreditContainer}>
            <View style={[styles.imageCreditTextContainer, styles.rounded, {opacity: imageCreditOpacity}]} >
              <Text style={styles.imageCreditText}>
                {post.custom_fields.photo_credit[0]}
              </Text>
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
          style={styles.postImage}
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
          <View style={styles.listItemOvalContainer}>
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

    var linkToArticle;
    if (typeof post.custom_fields.full_article_url !== 'undefined'
        && typeof post.custom_fields.full_article_url[0] !== 'undefined'
        && post.custom_fields.full_article_url[0]) {
      linkToArticle = <Text
        onPress={this._onPressFullArticle}
        style={styles.articleLink}>
        Read the full article
      </Text>;
    }
    else {
      linkToArticle = null;
    }

    var causeTitle, causeStyle = null;
    if (post.categories.length > 0) {
      causeTitle = post.categories[0].title;
      causeStyle = {backgroundColor: Helpers.causeBackgroundColor(causeTitle)};
    }

    return(
      <View style={[styles.postContainer, styles.rounded]}>
        <View style={[styles.postHeader, causeStyle]}>
          <Text style={styles.date}>{Helpers.formatDate(post.date)}</Text>
          <View style={styles.categoryContainer}>
            <Text style={styles.category}>{causeTitle}</Text>
          </View>
        </View>
        {this.renderImage()}
        <View style={styles.postBody}>
          <Text style={styles.title}>{post.title.toUpperCase()}</Text>
          {this.renderSummaryItem(post.custom_fields.summary_1[0])}
          {this.renderSummaryItem(post.custom_fields.summary_2[0])}
          {this.renderSummaryItem(post.custom_fields.summary_3[0])}
          {linkToArticle}
        </View>
        <TouchableHighlight onPress={this._onPressActionButton} style={styles.btn}>
          <Text style={styles.btnText}>{'Take action'.toUpperCase()}</Text>
        </TouchableHighlight>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  postBody: {
    padding: 20,
  },
  postContainer: {
    backgroundColor: '#ffffff',
    marginTop: 14,
    marginLeft: 7,
    marginRight: 7,
  },
  postHeader: {
    flex: 1,
    flexDirection: 'row',
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
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
    paddingBottom: 10,
    paddingTop: 10,
  },
  btnText: {
    color: '#ffffff',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 16,
    textAlign: 'center',
  },
  category: {
    color: '#ffffff',
    fontFamily: 'Brandon Grotesque',
  },
  categoryContainer: {
    flex: 1,
    alignItems: 'flex-end',
  },
  date: {
    color: '#ffffff',
    fontFamily: 'Brandon Grotesque',
  },
  postImage: {
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
  },
  imageCreditText: {
    color: '#FFFFFF',
    fontFamily: 'Brandon Grotesque',
    fontSize: 15,
  },
  // View container to center the image against just a single line of text
  listItemOvalContainer: {
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
  title: {
    color: '#4A4A4A',
    flex: 1,
    flexDirection: 'column',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 20,
  },
  rounded: {
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    borderBottomLeftRadius: 6,
    borderBottomRightRadius: 6,
  },
});

module.exports = NewsFeedPost;