express = require 'express'
app     = express()
podcast = require './podcast'
list    = require './../../conf/podcasts.json'
R       = require 'ramda'
Q       = require 'q'

podcastsP = podcast.getAll(list.podcasts)
R.map((x) ->
    Q.all(x).spread () ->
        console.log arguments
)(podcastsP)

app.get '/', (req, res) ->


server = app.listen 3000, ->
    console.log 'listen'
