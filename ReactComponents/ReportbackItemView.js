'use strict';

import React, {
  StyleSheet,
  Text,
  Image,
  TouchableHighlight,
  View
} from 'react-native';
import Dimensions from 'Dimensions';

var Style = require('./Style.js');
var Bridge = require('react-native').NativeModules.LDTReactBridge;
var NetworkImage = require('./NetworkImage.js');

var ReportbackItemView = React.createClass({
  render: function() {
    var reportbackItem = this.props.reportbackItem;
    var reportback = this.props.reportback;
    var campaign = this.props.campaign;
    var quantityLabel;
    if (campaign.reportback_info) {
      quantityLabel = campaign.reportback_info.noun + ' ' + campaign.reportback_info.verb;
    }
    var user = this.props.user;

    // @todo: Need countryName from iOS
    if ((!user.country) || user.country.length == 0) {
      user.country = '';
    }
    if ((!user.first_name) || user.first_name.length == 0) {
      user.first_name = 'Doer';
    }
    if ((user.photo && user.photo.length == 0) || (!user.photo)) {
      // @todo: Default avatar
      user.photo = 'https://placekitten.com/g/600/600';
    }
    // Sanity check:
    if ((!reportbackItem.media) || reportbackItem.media.uri.length == 0) {
      reportbackItem.media.uri = 'Placeholder Image Download Fails';
    }
    var shareButton = null;
    if (this.props.share) {
      var shareButton = (
        <TouchableHighlight 
          style={[Style.actionButton, {padding: 8, marginTop: 16,}]} 
          onPress={() => Bridge.shareReportback(this.getShareMessage(), reportbackItem.media.uri)}
          >
          <Text style={Style.actionButtonText}>
            {"Share your photo".toUpperCase()}
          </Text>
        </TouchableHighlight>
      );
    }
    return(
      <View style={styles.container}>
       <Text style={[Style.textCaption, styles.countryNameText]}>
         {user.country.toUpperCase()}
        </Text>
        <NetworkImage
          style={styles.reportbackItemImage}
          source={{uri:reportbackItem.media.uri}}
          displayProgress={true}
        />
        <View style={styles.contentContainer}>
          <View style={{flexDirection: 'row'}}>
            <Text style={[Style.textBodyBold, Style.textColorCtaBlue, {flex: 1}]}>
              {campaign.title}
            </Text>
            <Text style={[Style.textCaptionBold, {textAlign: 'right'}]}>
              {reportback.quantity} {quantityLabel}
            </Text>
          </View>
          <Text style={Style.textBody}>{reportbackItem.caption}</Text>
          {shareButton}
        </View>
        <View style={styles.userContainer}>
          <Image
            style={styles.avatarImage}
            source={{uri:user.photo}}
          />
          <Text style={[Style.textBodyBold, Style.textColorCtaBlue, styles.usernameText]}>
            {user.first_name.toUpperCase()}
          </Text>
        </View>
      </View>
    );
  },
  getShareMessage: function() {
    var campaign = this.props.campaign;
    var message = "BAM. I just rocked the " + campaign.title + " campaign on the ";
    message += "DoSomething app and " + campaign.reportback_info.verb + " ";
    message += this.props.reportback.quantity.toString() + " ";
    message += campaign.reportback_info.noun + ". Wanna do it with me?";
    return message;
  },
});

var styles = React.StyleSheet.create({
  container: {
    backgroundColor: 'white',
    paddingTop: 16,
  },
  headerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  userContainer: {
    backgroundColor: 'transparent',
    position: 'absolute',
    flexDirection: 'row',
    top: 14,
    left: 8,
  },
  usernameText: {
    paddingLeft: 5,
  },
  countryNameText: {
    textAlign: 'right',
    paddingRight: 8,
    height: 20,
  },
  avatarImage: {
    width: 50,
    height: 50,
    borderRadius: 25,
    borderColor: 'white',
    borderWidth: 2,
  },
  reportbackItemImage: {
    height: Dimensions.get('window').width,
  },
  contentContainer: {
    padding: 8,
  },
});

module.exports = ReportbackItemView;
