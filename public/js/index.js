var R, app, express, list, podcast, server;

express = require('express');

app = express();

podcast = require('./podcast');

list = require('./../../conf/podcasts.json');

R = require('ramda');

app.get('/', function(req, res) {
  return res.send('Hi');
});

server = app.listen(3000, function() {
  return console.log('listen on port 3000');
});
