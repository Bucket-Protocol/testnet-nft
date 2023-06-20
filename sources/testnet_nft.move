module testnet_nft::bucket_testnet_nft {

    use std::string::utf8;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::package;
    use sui::display;

    const NAME: vector<u8> = b"Bucket Protocol Testnet Early User NFT";
    const IMAGE_URL: vector<u8> = b"https://ipfs.io/ipfs/QmPqm3RkbxEqQVdQHXh8iVvrFe5x5fv9EYdJ6BwF4SJZHG";
    const DESCRIPTION: vector<u8> = b"Identity proof of testnet early user of Bucket Protocol";
    const OFFICIAL_URL: vector<u8> = b"https://bucketprotocol.io";
    const CREATOR: vector<u8> = b"Bucket Protocol";
    const SUI_WALLET_RECIPIENT: address = @0x73c88d432ad4b2bfc5170148faae6f11f39550fb84f9b83c8d152dd89bc8eda3;
    const ETHOS_WALLET_RECIPIENT: address = @0x96e8149973e094da6f42144693a9b135e9c6eb273415066c3f7a9bb2ebf1a35d;

    const ENoBottleInBucket: u64 = 0;
    const ENoBuckInTank: u64 = 1;
    const EAlreadyMinted: u64 = 2;

    struct BUCKET_TESTNET_NFT has drop {}

    struct BucketTestnetNFT has key, store { id: UID }

    fun init(otw: BUCKET_TESTNET_NFT, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            utf8(NAME),
            utf8(IMAGE_URL),
            utf8(DESCRIPTION),
            utf8(OFFICIAL_URL),
            utf8(CREATOR),
        ];

        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<BucketTestnetNFT>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        let deployer = tx_context::sender(ctx);
        transfer::public_transfer(publisher, deployer);
        transfer::public_transfer(display, deployer);
        transfer::transfer(BucketTestnetNFT { id: object::new(ctx) }, SUI_WALLET_RECIPIENT);
        transfer::transfer(BucketTestnetNFT { id: object::new(ctx) }, ETHOS_WALLET_RECIPIENT);
    }
}