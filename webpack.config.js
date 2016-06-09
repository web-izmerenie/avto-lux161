'use strict';

const webpack = require('webpack');
const path = require('path');

const BASE_DIR = __dirname;

module.exports = {
	devtool: 'source-map',
	watch: process.env.NODE_ENV === 'development',
	entry: {
		'client-app': path.join(BASE_DIR, 'front-end-sources', 'client', 'scripts', 'main.ls'),
		'client-vendor': path.join(BASE_DIR, 'front-end-sources', 'client', 'scripts', 'vendor.ls'),
		// 'admin-app': path.join(BASE_DIR, 'front-end-sources', 'admin', 'scripts', 'main.ls'),
		// 'admin-vendor': path.join(BASE_DIR, 'front-end-sources', 'admin', 'scripts', 'vendor.ls')
	},
	output: {
		path: path.join(BASE_DIR, 'static'),
		filename: '[name].bundle.js'
	},
	resolve: {
		alias: {
			adminbase: path.resolve(BASE_DIR, 'front-end-sources', 'admin'),
			clientbase: path.resolve(BASE_DIR, 'front-end-sources', 'client'),
			modernizr$client: path.resolve(BASE_DIR, 'front-end-sources', 'client', '.modernizrrc'),
		},
		extensions: ['', '.js', '.ls']
	},
	module: {
		loaders: [
			{ test: /\.ls$/,   loader: 'livescript-loader' },
			{ test: /\.json$/, loader: 'json-loader' },
			{ test: /\.jade$/, loader: 'pug-loader' },
			{ test: require.resolve('jquery'), loader: 'expose?$!expose?jQuery' },
			{ test: /\.modernizrrc$/, loader: "modernizr" },
			{
				test: /\.styl$/,
				loader: 'style-loader!css-loader!stylus-loader'
			}
		]
	},
	stylus: {
		use: [require('nib')(), require('bootstrap-styl')()]
	},
	plugins: [
		new webpack.optimize.CommonsChunkPlugin({
			names: ['client-app', 'client-vendor'],
			minChunks: Infinity
		})
	]
};

if (process.env.NODE_ENV === 'production') {
	module.exports.plugins.push(
		new webpack.optimize.UglifyJsPlugin({
			compress: {
				warnings: false,
				drop_console: false,
				unsafe: true
			}
		})
	);
}
