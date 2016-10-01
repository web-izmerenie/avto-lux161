'use strict';
/*jshint esversion: 6 */
/*jshint node: true */

const adminConfig = require('./webpack.config.admin');
const clientConfig = require('./webpack.config.client');

module.exports = [
	adminConfig,
	clientConfig
];
