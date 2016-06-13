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
		'app': path.join(BASE_DIR, 'front-end-sources', 'admin', 'scripts', 'main.ls'),
		'vendor': [
			'jquery',
			'jquery-ui/sortable',
			'jquery.dragndrop-file-upload',
			'backbone',
			'backbone.marionette',
			'backbone.wreqr',
			'ckeditor/adapters/jquery',
			'jade/jade'
		]
	},
	resolve: {
		alias: {
			base: path.resolve(BASE_DIR, 'front-end-sources', 'admin')
		},
		extensions: ['', '.js', '.ls']
	},
	output: {
		path: path.join(BASE_DIR, 'static'),
		filename: 'admin-[name].bundle.js'
	},
	plugins: [
		new ExtractTextPlugin('admin-[name].bundle.css')
	]
});
