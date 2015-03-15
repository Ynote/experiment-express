var Q, R, ansi, cursor, fs, getChannelData, getItemData, http, parseString, podcast;

fs = require('fs');

parseString = require('xml2js').parseString;

ansi = require('ansi');

cursor = ansi(process.stdout);

R = require('ramda');

Q = require('q');

http = require('http');

getItemData = R.curry(function(item) {
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
    podcasts: R.map(getItemData)(channel.item)
  };
});

podcast = {
  parseXml: function(xml) {
    return xml.then(function(res) {
      return parseString(res, {
        trim: true
      }, function(err, result) {
        var podcasts;
        return podcasts = R.pipe(R.map(getChannelData))(result.rss.channel);
      });
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
  getAll: function(list) {
    var xmlPromises;
    return xmlPromises = R.pipeP(R.values(), R.map(R.values()), R.map(R.map(podcast.getXml)), R.map(R.map(podcast.parseXml)), Q.all)(list);
  }
};

module.exports = podcast;
