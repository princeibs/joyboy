use starknet::ContractAddress;
use super::profile::{NostrProfile, NostrProfileTrait};

type NostrKey = u256;

#[derive(Drop, Serde)]
pub struct Transfer {
    amount: u256,
    token: felt252,
    joyboy: NostrProfile,
    recipient: NostrProfile
}

#[generate_trait]
pub impl TransferImpl of TransferTraitImpl {
    fn encode(self: @Transfer) -> @ByteArray {
        @format!(
            "{} send {} {} to {}",
            self.joyboy.encode(),
            self.amount,
            self.token,
            self.recipient.encode()
        )
    }
}


#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use super::{Transfer, TransferTraitImpl};
    use super::super::profile::{NostrProfile};

    #[test]
    fn test_fmt() {
        let joyboy = NostrProfile {
            public_key: 0x84603b4e300840036ca8cc812befcc8e240c09b73812639d5cdd8ece7d6eba40,
            relays: array!["wss://relay.joyboy.community.com"]
        };

        let recipient = NostrProfile {
            public_key: 0xa87622b57b52f366457e867e1dccc60ea631ccac94b7c74ab08254c489ef12c6,
            relays: array![]
        };

        let request = Transfer { amount: 1, token: 'USDC', joyboy, recipient };

        let expected =
            "nprofile1qys8wumn8ghj7un9d3shjtn2daukymme9e3k7mtdw4hxjare9e3k7mgqyzzxqw6wxqyyqqmv4rxgz2l0ej8zgrqfkuupycuatnwcannad6ayqx7zdcy send 1 1431520323 to nprofile1qqs2sa3zk4a49umxg4lgvlsaenrqaf33ejkffd78f2cgy4xy38h393s2w22mm";

        assert_eq!(request.encode(), @expected);
    }
}
