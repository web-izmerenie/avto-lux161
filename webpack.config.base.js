'use strict';
/*jshint esversion: 6 */
/*jshint node: true */

const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
	devtool: 'source-map',
	module: {
		loaders: [
			{ test: /\.ls$/,   loader: 'livescript-loader' },
			{ test: /\.json$/, loader: 'json-loader' },
			{ test: /\.jade$/, loader: 'raw-loader' },
			{ test: require.resolve('jquery'), loader: 'expose?$!expose?jQuery' },
			{ test: /\.modernizrrc$/, loader: 'modernizr' },
			{
				test: /\.styl$/,
				loader: ExtractTextPlugin.extract(
					'style-loader',
				   	'css-loader!stylus-loader'
				)
			}
		]
	},
	stylus: {
		use: [require('nib')(), require('bootstrap-styl')()]
	},
	plugins: [
		new webpack.optimize.CommonsChunkPlugin({
			names: ['app', 'vendor'],
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
