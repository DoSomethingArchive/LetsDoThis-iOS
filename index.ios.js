'use strict';
import React, {
  AppRegistry,
} from 'react-native';

var NewsFeedView = require('./ReactComponents/NewsFeedView.js');
AppRegistry.registerComponent('NewsFeedView', () => NewsFeedView);

var CauseListView = require('./ReactComponents/CauseListView.js');
AppRegistry.registerComponent('CauseListView', () => CauseListView);
