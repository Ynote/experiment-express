express = require 'express'
app     = express()
podcast = require './podcast'
list    = require './../../conf/podcasts.json'
R       = require 'ramda'

app.get '/', (req, res) ->
    res.send 'Hi'

server = app.listen 3000, ->
    console.log 'listen on port 3000'
