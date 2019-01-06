const express = require('express');
const http = require('http');
const path = require('path');
const store = require('./backend/store');

const port = process.env.PORT || 5555;
const app = express();
const server = http.createServer(app);

app.use(express.json());

app.use(function (req, res, next) { // allow CORS
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

if (process.env.NODE_ENV === 'production') {
  app.use(express.static('client/build'));
}

app.post('/create', (req, res) => {
  const lobbyID = req.body.playlistID;
  const max = req.body.max;
  store.lobbyExists({ lobbyID }).then((result) => {
    if (result.length === 0) {
      store.newLobby({ lobbyID, max }).then(() => res.sendStatus(200));
    } else {
      res.sendStatus(200);
    }
  });
});

app.post('/recommend', (req, res) => {
  const lobbyID = req.body.playlistID;
  const songID = req.body.songID;
  const IpAddress = req.ip;
  store.recommendationExists({ lobbyID, songID }).then((result) => {
    if (result.length === 0) {
      store.addRecommendation({ lobbyID, songID, IpAddress }).then(() => res.sendStatus(200));
    } else {
      res.sendStatus(200);
    }
  });
});

app.post('/receive', (req, res) => {
  const lobbyID = req.body.playlistID;
  store.getRecommendations({ lobbyID }).then((result) => {
    const songs = [];
    for (let i = 0; i < result.length; i += 1) {
      songs.push(result[i].song_id);
    }
    res.send({ list: songs });
  });
});

app.post('/delete', (req, res) => {
  const lobbyID = req.body.playlistID;
  const songID = req.body.songID;
  const status = 'deleted';
  store.markRecommendation({ lobbyID, songID, status }).then(() => res.sendStatus(200));
});

app.post('/add', (req, res) => {
  const lobbyID = req.body.playlistID;
  const songID = req.body.songID;
  const status = 'added';
  store.markRecommendation({ lobbyID, songID, status }).then(() => res.sendStatus(200));
});

app.get('/exists', (req, res) => {
  const lobbyID = req.query.lobbyID;
  store.lobbyExists({ lobbyID }).then((result) => {
    if (result.length === 0) {
      res.sendStatus(404);
    } else {
      res.sendStatus(200);
    }
  });
});

app.get('/devToken', (req, res) => {
  const devToken = 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkdHSzVONUEyTkcifQ.eyJpYXQiOjE1MzE4NzE2NjcsImV4cCI6MTU0NzQyMzY2NywiaXNzIjoiOUwzRDY3NlUyNSJ9.yfVs40BYUDIqHTSWQspOvaJzqlGv0BGmtZVAbUDXiu4xRcIVL70Ke0KAxt_65J6PCMtsccck3cvMI6e-1vbssQ'
  console.log(`devToken: ${devToken}`);
  res.send({devToken: devToken});
});

app.get('*', (request, response) => {
  response.sendFile(path.join(__dirname, 'client/build', 'index.html'));
});

server.listen(port, () => console.log(`Listening on port ${port}`));
