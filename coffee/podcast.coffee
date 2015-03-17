fs            = require 'fs'
{parseString} = require 'xml2js'
ansi          = require 'ansi'
cursor        = ansi process.stdout
R             = require 'ramda'
Q             = require 'q'
http          = require 'http'

# Private methods
getPodcastData = R.curry (item) ->
    podcast =
        title : item.title[0],
        date  : item.pubDate[0],
        mp3   : item.guid[0]

getChannelData = R.curry (channel) ->
    res =
        title: channel.title[0],
        podcasts: R.map(getPodcastData)(channel.item)

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
        promise.then (xml) ->
            podcasts = getStreamData xml

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
        deferred = Q.defer()
        podcastsP = R.pipe(
            R.values(),
            R.map(podcast.getXml),
            R.map(podcast.parseXml),
            Q.all
        )(res.rss)

        podcastsP.spread (x) ->
            list =
                distributor: res.name,
                streams: x
            deferred.resolve list
        deferred.promise

    getAll: (list) ->
        podcastsP = R.pipeP(
            R.map(podcast.getListByDistributor),
            Q.all
        )(list)

module.exports = podcast
