const assert = require('assert');
const axios = require('axios');
const getPokemon = require('./index');

axios.get = async function () {
    return {
        data: {
            name: 'bulbasaur',
            id: 1,
            height: 7,
            weight: 69,
            base_experience: 64,
            types: [
                {
                    type: {
                        name: 'grass'
                    }
                },
                {
                    type: {
                        name: 'poison'
                    }
                }
            ]
        }
    };
};

async function runTest() {
    const context = {
        res: null
    };

    const req = {
        params: {
            name: 'bulbasaur'
        },
        query: {}
    };

    await getPokemon(context, req);

    assert.strictEqual(context.res.status, 200, 'Expected HTTP status 200');
    assert.strictEqual(context.res.body.name, 'bulbasaur', 'Expected Pokémon name to be bulbasaur');
    assert.strictEqual(context.res.body.id, 1, 'Expected Pokémon ID to be 1');
    assert.deepStrictEqual(context.res.body.types, ['grass', 'poison'], 'Expected Pokémon types grass and poison');
    assert.strictEqual(context.res.body.favoriteFood, 'Avocado Roll', 'Expected favorite food for grass type');

    console.log('✅ getPokemon unit test passed');
}

runTest().catch((err) => {
    console.error('❌ getPokemon unit test failed');
    console.error(err);
    process.exit(1);
});
