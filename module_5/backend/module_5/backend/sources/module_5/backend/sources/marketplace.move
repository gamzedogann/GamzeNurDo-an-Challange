module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::object::{Self, UID, ID};
use sui::sui::SUI;
use sui::tx_context::{Self, TxContext};
use sui::transfer;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {

    // NOTE: The init function runs once when the module is published
    // TODO: Initialize the module by creating AdminCap
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    // TODO: Transfer it to the module publisher (ctx.sender()) using transfer::public_transfer() function
    transfer::public_transfer(admin_cap, ctx.sender());
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {

    // TODO: Create a list_hero object for marketplace
    let list_hero = ListHero {
        id: object::new(ctx),
        nft,
        price,
        seller: ctx.sender(),
    };
    // TODO: Emit HeroListed event with listing details
    event::emit(HeroListed {
        list_hero_id: object::id(&list_hero),
        price,
        seller: ctx.sender(),
        timestamp: ctx.epoch_timestamp_ms(),
    });
    // TODO: Use transfer::share_object() to make it publicly tradeable
    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {

    // TODO: Destructure list_hero to get id, nft, price, and seller
    let ListHero { id, nft, price, seller } = list_hero;
    let hero_id = object::id(&nft);

    // TODO: Use assert! to verify coin value equals listing price
    assert!(coin::value(&coin) == price, EInvalidPayment);

    // TODO: Transfer coin to seller
    transfer::public_transfer(coin, seller);

    // TODO: Transfer hero NFT to buyer (ctx.sender())
    transfer::public_transfer(nft, ctx.sender());

    // TODO: Emit HeroBought event with transaction details
    event::emit(HeroBought {
        list_hero_id: object::uid_to_inner(&id),
        price,
        buyer: ctx.sender(),
        seller,
        timestamp: ctx.epoch_timestamp_ms(),
    });

    // TODO: Delete the listing ID (object::delete(id))
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {

    // NOTE: The AdminCap parameter ensures only admin can call this
    // TODO: Implement admin delist functionality
    // Destructure list_hero (ignore price with "price: _")
    let ListHero { id, nft, price: _, seller } = list_hero;

    // TODO: Transfer NFT back to original seller
    transfer::public_transfer(nft, seller);

    // TODO: Delete the listing ID (object::delete(id))
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    
    // NOTE: The AdminCap parameter ensures only admin can call this
    // list_hero has &mut so price can be modified
    // TODO: Update the listing price
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}
