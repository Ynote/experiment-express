ansi    = require 'ansi'
cursor  = ansi process.stdout
podcast = require './podcast'
list    = require './../../conf/podcasts.json'
Q       = require 'q'
express = require 'express'
app     = express()

getPodcasts = () ->
    podcastsP = podcast.getAll(list.podcasts)
    podcastsP.spread () ->
        args = Array.prototype.slice.call(arguments)

app.set 'views', './views'
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    cursor.grey().write '[dl-podcasts] - Fetching podcasts...\n'
    getPodcasts().then (podcasts) ->
        cursor.write '[dl-podcasts] - Podcasts fetched!\n'
            .reset()
        res.render 'index',
            podcasts: podcasts


server = app.listen '3000', () ->
    cursor.green().write "[dl-podcasts] - App listening on http://#{server.address().address}:#{server.address().port}\n"
