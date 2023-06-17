module testnet_nft::bucket_logo_nft {

    use std::string::utf8;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::package;
    use sui::display;

    const NAME: vector<u8> = b"Bucket Logo";
    const IMAGE_URL: vector<u8> = b"https://ipfs.io/ipfs/QmTKZ2CX8RzkJeqCpaYPHbS5sFyCQdtasxyYb96Xmns1Cv";
    const DESCRIPTION: vector<u8> = b"CDP Protocol Built On Sui Network, providing 0% interest loan and decentralized native stablecoin";
    const OFFICIAL_URL: vector<u8> = b"https://bucketprotocol.io";
    const CREATOR: vector<u8> = b"Bucket Protocol";

    struct BUCKET_LOGO_NFT has drop {}

    struct BucketLogoNFT has key, store { id: UID }

    fun init(otw: BUCKET_LOGO_NFT, ctx: &mut TxContext) {
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
        let display = display::new_with_fields<BucketLogoNFT>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public entry fun mint(ctx: &mut TxContext) {
        transfer::transfer(
            BucketLogoNFT { id: object::new(ctx) },
            tx_context::sender(ctx),
        );
    }
}