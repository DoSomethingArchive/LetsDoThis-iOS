'use strict';
import React, {
  AppRegistry,
} from 'react-native';

var NewsFeedView = require('./ReactComponents/NewsFeedView.js');
AppRegistry.registerComponent('NewsFeedView', () => NewsFeedView);

var CauseListView = require('./ReactComponents/CauseListView.js');
AppRegistry.registerComponent('CauseListView', () => CauseListView);

var CauseDetailView = require('./ReactComponents/CauseDetailView.js');
AppRegistry.registerComponent('CauseDetailView', () => CauseDetailView);

var UserView = require('./ReactComponents/UserView.js');
AppRegistry.registerComponent('UserView', () => UserView);

var CampaignView = require('./ReactComponents/CampaignView.js');
AppRegistry.registerComponent('CampaignView', () => CampaignView);
