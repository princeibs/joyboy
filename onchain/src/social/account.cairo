use starknet::{ContractAddress, get_caller_address, get_contract_address, contract_address_const};
use super::profile::NostrProfile;
use super::request::SocialRequest;
use super::transfer::{Transfer};

#[starknet::interface]
pub trait ISocialAccount<TContractState> {
    fn get_public_key(self: @TContractState) -> u256;
    fn handle_transfer_request(ref self: TContractState, request: SocialRequest<Transfer>);
}

#[starknet::contract]
pub mod SocialAccount {
    use super::SocialRequest;
    use super::Transfer;

    #[storage]
    struct Storage {
        #[key]
        public_key: u256
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AccountCreated: AccountCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct AccountCreated {
        #[key]
        public_key: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: u256) {
        self.public_key.write(public_key);
        self.emit(AccountCreated { public_key: public_key });
    }

    #[abi(embed_v0)]
    impl SocialAccount of super::ISocialAccount<ContractState> {
        fn get_public_key(self: @ContractState) -> u256 {
            self.public_key.read()
        }
        fn handle_transfer_request(
            ref self: ContractState, request: SocialRequest<Transfer>
        ) { // TODO: implement handle transfer logic
        }
    }
}

#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::array::ArrayTrait;
    use starknet::{
        ContractAddress, get_caller_address, get_contract_address, contract_address_const
    };
    use snforge_std as snf;
    use snforge_std::{
        declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, spy_events, SpyOn,
        EventSpy, EventFetcher, Event, EventAssertions
    };
    use super::{
        ISocialAccountDispatcher, ISocialAccountDispatcherTrait, ISocialAccountSafeDispatcher,
        ISocialAccountSafeDispatcherTrait
    };


    const public_key: u256 = 45;


    fn deploy_social_account() -> ContractAddress {
        let contract = declare("SocialAccount").unwrap();

        let mut social_account_calldata = array![];
        public_key.serialize(ref social_account_calldata);

        let address = contract.precalculate_address(@social_account_calldata);

        let mut spy = spy_events(SpyOn::One(address));

        let (contract_address, _) = contract.deploy(@social_account_calldata).unwrap();

        spy.fetch_events();

        assert(spy.events.len() == 1, 'there should be one event');

        let (_, event) = spy.events.at(0);
        assert(event.keys.at(0) == @selector!("AccountCreated"), 'Wrong event name');

        let event_key = (*event.keys.at(1)).into();

        assert(event_key == public_key, 'Wrong Public Key');
        contract_address
    }


    #[test]
    fn test_get_public_key() {
        let contract_address = deploy_social_account();
        let dispatcher = ISocialAccountDispatcher { contract_address };

        let get_public_key = dispatcher.get_public_key();

        assert!(get_public_key == 45, "Public key is not the same");
    }
}
