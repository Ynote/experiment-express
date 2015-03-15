fs            = require 'fs'
{parseString} = require 'xml2js'
ansi          = require 'ansi'
cursor        = ansi process.stdout
R             = require 'ramda'
Q             = require 'q'
http          = require 'http'


getItemData = R.curry((item) ->
    podcast =
        title : item.title[0],
        date  : item.pubDate[0],
        mp3   : item.guid[0]
)

getChannelData= R.curry((channel) ->
    res =
        title: channel.title[0],
        podcasts: R.map(getItemData)(channel.item)
)

podcast =
    parseXml: (xml) ->
        xml.then (res) ->
            parseString res, {trim : true}, (err, result) ->
                podcasts = R.pipe(
                    R.map(getChannelData)
                )(result.rss.channel)

    getXml: (path) ->
        deferred = Q.defer()

        http.get path, (res) ->
            xml = ''

            res.on 'data', (chunk) ->
                xml += chunk

            res.on 'end', ->
                deferred.resolve xml

        deferred.promise

    getAll: (list) ->
        xmlPromises = R.pipeP(
            R.values(),
            R.map(R.values()),
            R.map(R.map(podcast.getXml)),
            R.map(R.map(podcast.parseXml)),
            Q.all
        )(list)

module.exports = podcast
