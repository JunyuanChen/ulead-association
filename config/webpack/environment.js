const { environment } = require('@rails/webpacker');

const webpack = require('webpack');

environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery'
}));

environment.config.set('externals', {
    jquery: 'jQuery'
});

module.exports = environment;
