module.exports =
    entry: './coffee/podcast.coffee'
    output:
        path: __dirname + '/public/js',
        filename: 'caca.js'

    module:
        loaders: [
            test: /\.coffee$/, loader: 'coffee-loader'
        ]

    resolve:
        extensions: ['', '.webpack.js', '.web.js', '.js', '.coffee']
        modulesDirectories: ['coffee', 'node_modules']
