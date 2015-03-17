var Q, ansi, app, cursor, express, getPodcasts, list, podcast, server;

ansi = require('ansi');

cursor = ansi(process.stdout);

podcast = require('./podcast');

list = require('./../../conf/podcasts.json');

Q = require('q');

express = require('express');

app = express();

getPodcasts = function() {
  var podcastsP;
  podcastsP = podcast.getAll(list.podcasts);
  return podcastsP.spread(function() {
    var args;
    return args = Array.prototype.slice.call(arguments);
  });
};

app.set('views', './views');

app.set('view engine', 'jade');

app.get('/', function(req, res) {
  cursor.grey().write('[dl-podcasts] - Fetching podcasts...\n');
  return getPodcasts().then(function(podcasts) {
    cursor.write('[dl-podcasts] - Podcasts fetched!\n').reset();
    return res.render('index', {
      podcasts: podcasts
    });
  });
});

server = app.listen('3000', function() {
  return cursor.green().write("[dl-podcasts] - App listening on http://" + (server.address().address) + ":" + (server.address().port) + "\n");
});
