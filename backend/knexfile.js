module.exports = {
  client: 'postgresql',
  connection: process.env.DATABASE_URL || {
    user: 'psql_admin',
    password: 'password',
    database: 'juke_jam',
  },
};
