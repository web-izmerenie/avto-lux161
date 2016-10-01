'use strict';
/*jshint esversion: 6 */
/*jshint node: true */

const webpack = require('webpack');
const webpackMerge = require('webpack-merge');

module.exports = (extractCss) => (config) => webpackMerge.smart({
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
				loader: extractCss.extract(
					'style-loader',
				   	'css-loader?sourceMap!stylus-loader'
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
	].concat(
		(process.env.NODE_ENV === 'production') ?
		new webpack.optimize.UglifyJsPlugin({
			compress: {
				warnings: false,
				drop_console: false,
				unsafe: true
			}
		}) : []
	)
}, config);
