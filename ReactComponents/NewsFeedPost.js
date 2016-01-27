'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  View
} from 'react-native';

var Helpers = require('./Helpers.js');
var TAKE_ACTION_TEXT = 'Take action';

var NewsFeedPost = React.createClass({
  ctaButtonPressed: function() {
    var campaignID = this.props.post.custom_fields.campaign_id[0];
    var NewsFeedViewController = require('react-native').NativeModules.LDTNewsFeedViewController;
    NewsFeedViewController.presentCampaignWithCampaignID(campaignID);
  },
  fullArticlePressed: function(url) {
    var NewsFeedViewController = require('react-native').NativeModules.LDTNewsFeedViewController;
    NewsFeedViewController.presentFullArticleWithUrlString(url);
  },
  render: function() {
    var imgBackground;
    var imgOval;
    var post = this.props.post;
    var postTitle = post.title.toUpperCase();

    if (typeof post !== 'undefined'
        && typeof post.attachments[0] !== 'undefined'
        && typeof post.attachments[0].images !== 'undefined'
        && typeof post.attachments[0].images.full !== 'undefined') {
        imgBackground = <Image
          style={{flex: 1, height: 128, alignItems: 'stretch'}}
          source={{uri: post.attachments[0].images.full.url}}>
            <View style={styles.titleContainer}>
              <Text style={styles.title}>{postTitle}</Text>
            </View>
          </Image>;
    }
    else {
      imgBackground = <Text style={styles.title}>{postTitle}</Text>;
    }

    imgOval = require('image!listitem-oval');

    var linkToArticle;
    if (typeof post.custom_fields.full_article_url !== 'undefined'
        && typeof post.custom_fields.full_article_url[0] !== 'undefined'
        && post.custom_fields.full_article_url[0]) {
        linkToArticle = <Text
            onPress={this.fullArticlePressed.bind(this, post.custom_fields.full_article_url[0])}
            style={styles.articleLink}>
            Read the full article
          </Text>;
    }
    else {
      linkToArticle = null;
    }

    var formattedDate = Helpers.formatDate(post.date);
    var causeStyle = null;
    var causeTitle = null;
    if (post.categories.length > 0) {
      causeTitle = post.categories[0].title;
      causeStyle = {backgroundColor: Helpers.causeBackgroundColor(causeTitle)};
    }

    return(
      <View style={styles.postContainer}>
        <View style={[styles.postHeader, causeStyle]}>
          <Text style={styles.date}>{formattedDate}</Text>
          <View style={styles.categoryContainer}>
            <Text style={styles.category}>{causeTitle}</Text>
          </View>
        </View>
        {imgBackground}
        <View style={styles.postBody}>
          <Text style={styles.subtitle}>{post.custom_fields.subtitle}</Text>
          <View style={styles.summaryItem}>
            <View style={styles.listItemOvalContainer}>
              <Image source={imgOval} />
            </View>
            <Text style={styles.summaryText}>{post.custom_fields.summary_1}</Text>
          </View>
          <View style={styles.summaryItem}>
            <View style={styles.listItemOvalContainer}>
              <Image source={imgOval} />
            </View>
            <Text style={styles.summaryText}>{post.custom_fields.summary_2}</Text>
          </View>
          <View style={styles.summaryItem}>
            <View style={styles.listItemOvalContainer}>
              <Image source={imgOval} />
            </View>
            <Text style={styles.summaryText}>{post.custom_fields.summary_3}</Text>
          </View>
          {linkToArticle}
        </View>
        <TouchableHighlight onPress={this.ctaButtonPressed} style={styles.btn}>
          <Text style={styles.btnText}>{TAKE_ACTION_TEXT.toUpperCase()}</Text>
        </TouchableHighlight>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  postBody: {
    padding: 10,
  },
  postContainer: {
    backgroundColor: '#ffffff',
    marginTop: 10
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
    borderBottomLeftRadius: 4,
    borderBottomRightRadius: 4,
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
  // View container to center the image against just a single line of text
  listItemOvalContainer: {
    // This height is based off the draw height of a single summaryText line
    height: 21.5,
    justifyContent: 'center',
  },
  subtitle: {
    color: '#4A4A4A',
    fontFamily: 'BrandonGrotesque-Bold',
    fontSize: 18,
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

module.exports = NewsFeedPost;