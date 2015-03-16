fs            = require 'fs'
{parseString} = require 'xml2js'
ansi          = require 'ansi'
cursor        = ansi process.stdout
R             = require 'ramda'
Q             = require 'q'
http          = require 'http'

# Private methods
getItemData = R.curry (item) ->
    podcast =
        title : item.title[0],
        date  : item.pubDate[0],
        mp3   : item.guid[0]

getChannelData = R.curry (channel) ->
    res =
        title: channel.title[0],
        podcasts: R.map(getItemData)(channel.item)

getStreamData = R.curry (xml) ->
    deferred = Q.defer()
    parseString xml, {trim : true}, (err, result) ->
        podcasts = R.pipe(
            R.map(getChannelData)
        )(result.rss.channel)
        deferred.resolve podcasts
    deferred.promise

# Module & public methods / properties
podcast =
    parseXml: (promise) ->
        deferred = Q.defer()
        promise.then (xml) ->
            podcasts = getStreamData xml
            deferred.resolve podcasts
        deferred.promise

    getXml: (path) ->
        deferred = Q.defer()
        http.get path, (res) ->
            xml = ''
            res.on 'data', (chunk) ->
                xml += chunk
            res.on 'end', ->
                deferred.resolve xml
        deferred.promise

    getListByDistributor: (res) ->
        podcastsP = R.pipe(
            R.values(),
            R.map(podcast.getXml),
            R.map(podcast.parseXml)
        )(res.rss)

    getAll: (list) ->
        podcastsP = R.pipeP(
            R.map(podcast.getListByDistributor)
        )(list)

module.exports = podcast
