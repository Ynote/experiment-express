var Q, R, app, express, list, podcast, podcastsP, server;

express = require('express');

app = express();

podcast = require('./podcast');

list = require('./../../conf/podcasts.json');

R = require('ramda');

Q = require('q');

podcastsP = podcast.getAll(list.podcasts);

R.map(function(x) {
  return Q.all(x).spread(function() {
    return console.log(arguments);
  });
})(podcastsP);

app.get('/', function(req, res) {});

server = app.listen(3000, function() {
  return console.log('listen');
});
