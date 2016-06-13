'use strict';
/*jshint esversion: 6 */
/*jshint node: true */

const path = require('path');
const webpackMerge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const baseConfig = require('./webpack.config.base.js');

const BASE_DIR = __dirname;

module.exports = webpackMerge.smart(baseConfig, {
	entry: {
		'app': path.join(BASE_DIR, 'front-end-sources', 'client', 'scripts', 'main.ls'),
		'vendor': [
			'jquery',
			'jquery-colorbox',
			'jquery-ui/datepicker',
			'modernizr'
		]
	},
	resolve: {
		alias: {
			base: path.resolve(BASE_DIR, 'front-end-sources', 'client'),
			modernizr: path.resolve(BASE_DIR, 'front-end-sources', 'client', '.modernizrrc')
		},
		extensions: ['', '.js', '.ls']
	},
	output: {
		path: path.join(BASE_DIR, 'static'),
		filename: 'client-[name].bundle.js'
	},
	plugins: [
		new ExtractTextPlugin('client-[name].bundle.css')
	]
});
