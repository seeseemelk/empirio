const path = require('path');

module.exports = {
	mode: 'production',
	context: path.resolve(__dirname, 'websource'),
	entry: './empirio.ts',
	module: {
		rules: [
			{
				test: /\.ts$/,
				use: 'ts-loader'
			}
		]
	},
	resolve: {
		extensions: ['.ts']
	},
	output: {
		path: path.resolve(__dirname, 'public'),
		filename: 'empirio.js'
	}
};
