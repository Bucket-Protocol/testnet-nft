module testnet_nft::bucket_testnet_nft {

    use std::string::utf8;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::package;
    use sui::display;
    use sui::sui::SUI;
    use sui::table::{Self, Table};
    use bucket_protocol::buck::{Self, BUCK, BucketProtocol};
    use bucket_protocol::bucket;
    use bucket_protocol::tank::{Self, ContributorToken};
    use bucket_protocol::bottle;

    const NAME: vector<u8> = b"Bucket Testnet NFT";
    const IMAGE_URL: vector<u8> = b"https://ipfs.io/ipfs/QmXA3GV52pa4qYYqN21hUhovfn9eKMwobHVF9qxTCMPg38";
    const DESCRIPTION: vector<u8> = b"CDP Protocol Built On Sui Network, providing zero interest loan and decentralized native stablecoin";
    const OFFICIAL_URL: vector<u8> = b"https://bucketprotocol.io";
    const CREATOR: vector<u8> = b"Bucket Protocol";

    const ENoBottleInBucket: u64 = 0;
    const ENoBuckInTank: u64 = 1;
    const EAlreadyMinted: u64 = 2;

    struct BUCKET_TESTNET_NFT has drop {}

    struct BucketTestnetNFT has key, store { id: UID }

    struct CheckTable has key {
        id: UID,
        user_table: Table<address, bool>,
        token_table: Table<ID, bool>,
    }

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
        transfer::share_object(CheckTable {
            id: object::new(ctx),
            user_table: table::new(ctx),
            token_table: table::new(ctx),
        });
    }

    public entry fun mint(
        protocol: &BucketProtocol,
        token: &ContributorToken<BUCK, SUI>,
        check_table: &mut CheckTable,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        assert!(has_bottle_in_bucket(protocol, sender), ENoBottleInBucket);
        assert!(has_buck_in_tank(protocol, token), ENoBuckInTank);
        let token_id = *object::borrow_id(token);
        assert!(
            !table::contains(&check_table.user_table, sender) &&
            !table::contains(&check_table.token_table, token_id),
            EAlreadyMinted,
        );

        transfer::transfer(
            BucketTestnetNFT { id: object::new(ctx) },
            tx_context::sender(ctx),
        );

        table::add(&mut check_table.user_table, sender, true);
        table::add(&mut check_table.token_table, token_id, true);
    }

    public fun has_bottle_in_bucket(protocol: &BucketProtocol, user: address): bool {
        let bucket = buck::borrow_bucket<SUI>(protocol);
        let bottle_table = bucket::borrow_bottle_table(bucket);
        bottle::bottle_exists(bottle_table, user)
    }

    public fun has_buck_in_tank(protocol: &BucketProtocol, token: &ContributorToken<BUCK, SUI>): bool {
        let tank = buck::borrow_tank<SUI>(protocol);
        tank::get_token_weight(tank, token) > 0
    }
}