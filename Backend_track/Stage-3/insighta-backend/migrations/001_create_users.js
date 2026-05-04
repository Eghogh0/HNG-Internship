exports.up = async function(knex) {
  await knex.schema.createTable('users', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('github_id').unique().notNullable();
    table.string('username').notNullable();
    table.string('email');
    table.string('avatar_url');
    table.string('role').defaultTo('analyst');
    table.boolean('is_active').defaultTo(true);
    table.timestamp('last_login_at').defaultTo(knex.fn.now());
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('refresh_tokens', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.text('token').notNullable();
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('refresh_tokens');
  await knex.schema.dropTableIfExists('users');
};