var Q, R, ansi, cursor, fs, getChannelData, getPodcastData, getStreamData, http, parseString, podcast;

fs = require('fs');

parseString = require('xml2js').parseString;

ansi = require('ansi');

cursor = ansi(process.stdout);

R = require('ramda');

Q = require('q');

http = require('http');

getPodcastData = R.curry(function(item) {
  var podcast;
  return podcast = {
    title: item.title[0],
    date: item.pubDate[0],
    mp3: item.guid[0]
  };
});

getChannelData = R.curry(function(channel) {
  var res;
  return res = {
    title: channel.title[0],
    podcasts: R.map(getPodcastData)(channel.item)
  };
});

getStreamData = R.curry(function(xml) {
  var deferred;
  deferred = Q.defer();
  parseString(xml, {
    trim: true
  }, function(err, result) {
    var podcasts;
    podcasts = R.pipe(R.map(getChannelData))(result.rss.channel);
    return deferred.resolve(podcasts);
  });
  return deferred.promise;
});

podcast = {
  parseXml: function(promise) {
    return promise.then(function(xml) {
      var podcasts;
      return podcasts = getStreamData(xml);
    });
  },
  getXml: function(path) {
    var deferred;
    deferred = Q.defer();
    http.get(path, function(res) {
      var xml;
      xml = '';
      res.on('data', function(chunk) {
        return xml += chunk;
      });
      return res.on('end', function() {
        return deferred.resolve(xml);
      });
    });
    return deferred.promise;
  },
  getListByDistributor: function(res) {
    var deferred, podcastsP;
    deferred = Q.defer();
    podcastsP = R.pipe(R.values(), R.map(podcast.getXml), R.map(podcast.parseXml), Q.all)(res.rss);
    podcastsP.spread(function(x) {
      var list;
      list = {
        distributor: res.name,
        streams: x
      };
      return deferred.resolve(list);
    });
    return deferred.promise;
  },
  getAll: function(list) {
    var podcastsP;
    return podcastsP = R.pipeP(R.map(podcast.getListByDistributor), Q.all)(list);
  }
};

module.exports = podcast;
