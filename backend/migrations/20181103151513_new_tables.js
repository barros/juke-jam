exports.up = function (knex) {
  return createLobbiesTable().then(createRecommendationsTable);

  function createLobbiesTable() {
    return knex.schema.dropTableIfExists('lobbies').createTable('lobbies', function (t) {
      t.string('lobby_id').primary();
      t.integer('max_recommendations');
    });
  }

  function createRecommendationsTable() {
    return knex.schema.dropTableIfExists('recommendations').createTable('recommendations', function (t) {
      t.increments('rec_id').primary();
      t.string('lobby_id');
      t.string('song_id');
      t.string('ip_address'); // used for setting recommendation limits
      t.string('status').defaultTo('new'); // added, ignored
    });
  }
};

exports.down = function (knex) {
  return knex.schema.dropTable('lobbies').dropTable('recommendations');
};
