const knex = require('knex')(require('./knexfile'));

module.exports = {
  newLobby({
    lobbyID,
    max,
  }) {
    return knex.select()
      .from('lobbies')
      .whereNotExists('lobby_id', lobbyID)
      .insert({
        lobby_id: lobbyID,
        max_recommendations: max,
      });
  },

  lobbyExists({
    lobbyID,
  }) {
    return knex.select()
      .from('lobbies')
      .where('lobby_id', lobbyID)
      .then(res => res);
  },

  addRecommendation({
    lobbyID,
    songID,
    IpAddress,
  }) {
    return knex.select()
      .from('recommendations')
      .insert({
        lobby_id: lobbyID,
        song_id: songID,
        ip_address: IpAddress,
      });
  },

  recommendationExists({
    lobbyID,
    songID,
  }) {
    return knex.select()
      .from('recommendations')
      .where({
        'lobby_id': lobbyID,
        'song_id': songID,
      })
      .then(res => res);
  },

  getRecommendations({
    lobbyID,
  }) {
    return knex.select('song_id')
      .from('recommendations')
      .where({
        'lobby_id': lobbyID,
        'status': 'new',
      })
      .then(res => res);
  },

  markRecommendation({
    lobbyID,
    songID,
    status,
  }) {
    return knex.select()
      .from('recommendations')
      .where({
        'lobby_id': lobbyID,
        'song_id': songID,
      })
      .update('status', status);
  },

};
