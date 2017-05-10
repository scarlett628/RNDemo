'use strict';

import React, { Component } from 'react';
import {
  AppRegistry,
  Text,
} from 'react-native';

export default class RNDemo extends Component {
  render() {
    return(
        <Text>Hello World!</Text>
    );
  }
}

AppRegistry.registerComponent('RNDemo', () => RNDemo);
