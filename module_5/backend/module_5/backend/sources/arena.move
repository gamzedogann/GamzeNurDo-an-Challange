module challenge::arena;

use challenge::hero::{Self, Hero};
use sui::event;
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    // TODO: Create an arena object
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: ctx.sender(),
    };
    // TODO: Emit ArenaCreated event with arena ID and timestamp
    event::emit(ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: ctx.epoch_timestamp_ms(),
    });
    // TODO: Use transfer::share_object() to make it publicly tradeable
    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    
    // TODO: Implement battle logic
    // Destructure arena to get id, warrior, and owner
    let Arena { id, warrior, owner } = arena;

    let challenger_power = hero::hero_power(&hero);
    let warrior_power = hero::hero_power(&warrior);

    let challenger_id = object::id(&hero);
    let warrior_id = object::id(&warrior);

    let winner_addr: address;
    let winner_id: ID;
    let loser_id: ID;

    // TODO: Compare hero.hero_power() with warrior.hero_power()
    if (challenger_power > warrior_power) {
        // If hero (challenger) wins: both heroes go to ctx.sender() (challenger)
        winner_addr = ctx.sender();
        winner_id = challenger_id;
        loser_id = warrior_id;
    } else {
        // If warrior (defender) wins: both heroes go to battle place owner
        winner_addr = owner;
        winner_id = warrior_id;
        loser_id = challenger_id;
    };

    // Her iki kahraman da kazananın adresine transfer edilir
    transfer::public_transfer(hero, winner_addr);
    transfer::public_transfer(warrior, winner_addr);

    // TODO: Emit ArenaCompleted event with winner/loser IDs
    event::emit(ArenaCompleted {
        winner_hero_id: winner_id,
        loser_hero_id: loser_id,
        timestamp: ctx.epoch_timestamp_ms(),
    });

    // TODO: Delete the battle place ID
    object::delete(id);
}
