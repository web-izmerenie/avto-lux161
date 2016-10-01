'use strict';
/*jshint esversion: 6 */
/*jshint node: true */

const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const baseConfig = require('./webpack.config.base.js');

const BASE_DIR = __dirname;

const extractCss = new ExtractTextPlugin('client-[name].bundle.css');

module.exports = baseConfig(extractCss)({
	entry: {
		'app': path.join(
			BASE_DIR, 'front-end-sources', 'client', 'scripts', 'main.ls'
		),
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
			modernizr: path.resolve(
				BASE_DIR, 'front-end-sources', 'client', '.modernizrrc'
			)
		},
		extensions: ['', '.js', '.ls']
	},
	output: {
		path: path.join(BASE_DIR, 'static'),
		filename: 'client-[name].bundle.js'
	},
	plugins: [
		extractCss
	]
});
