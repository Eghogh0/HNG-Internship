exports.up = async function(knex) {
  await knex.schema.createTable('profiles', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('name').unique().notNullable();
    table.string('gender');
    table.float('gender_probability');
    table.integer('age');
    table.string('age_group');
    table.string('country_id', 2);
    table.string('country_name');
    table.float('country_probability');
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('profiles');
};