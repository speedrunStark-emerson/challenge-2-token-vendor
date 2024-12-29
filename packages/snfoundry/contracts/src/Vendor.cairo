use starknet::ContractAddress;
#[starknet::interface]
pub trait IVendor<T> {
    fn buy_tokens(ref self: T, eth_amount_wei: u256);
    fn withdraw(ref self: T);
    fn sell_tokens(ref self: T, amount_tokens: u256);
    fn tokens_per_eth(self: @T) -> u256;
    fn your_token(self: @T) -> ContractAddress;
    fn eth_token(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod Vendor {
    use contracts::YourToken::{IYourTokenDispatcher, IYourTokenDispatcherTrait};
    use core::traits::TryInto;
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_access::ownable::interface::IOwnable;
    use openzeppelin_token::erc20::interface::{IERC20CamelDispatcher, IERC20CamelDispatcherTrait};
    use starknet::{get_caller_address, get_contract_address};
    use super::{ContractAddress, IVendor};
    const TokensPerETh: u256 = 100;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ToDo Checkpoint 2: Define const TokensPerEth

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        eth_token: IERC20CamelDispatcher,
        your_token: IYourTokenDispatcher,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        BuyTokens: BuyTokens,
        SellTokens: SellTokens,
    }

    #[derive(Drop, starknet::Event)]
    struct BuyTokens {
        buyer: ContractAddress,
        eth_amount: u256,
        tokens_amount: u256,
    }

    //  ToDo Checkpoint 3: Define the event SellTokens
    #[derive(Drop, starknet::Event)]
    struct SellTokens {
        seller: ContractAddress,
        tokens_amount: u256,
        eth_amount: u256,
    }

    #[constructor]
    // Todo Checkpoint 2: Edit the constructor to initialize the owner of the contract.
    fn constructor(
        ref self: ContractState,
        eth_token_address: ContractAddress,
        your_token_address: ContractAddress,
        owner: ContractAddress
    ) {
        self.eth_token.write(IERC20CamelDispatcher { contract_address: eth_token_address });
        self.your_token.write(IYourTokenDispatcher { contract_address: your_token_address });
        // ToDo Checkpoint 2: Initialize the owner of the contract here.
        OwnableInternalImpl::initializer(ref self.ownable, owner);
    }
    #[abi(embed_v0)]
    impl VendorImpl of IVendor<ContractState> {
        // ToDo Checkpoint 2: Implement your function buy_tokens here.
        fn buy_tokens(ref self: ContractState, eth_amount_wei: u256) {
            let caller = get_caller_address();
            let tokens_amount = eth_amount_wei * TokensPerETh;

            let vendor_balance = self.your_token.read().balance_of(get_contract_address());

            assert!(vendor_balance >= tokens_amount, "Vendor does not have enough tokens");

            // Transfer tokens from the contract to the buyer
            self.your_token.read().transfer(caller, tokens_amount);

            // Emit BuyTokens event
            self.emit(BuyTokens { buyer: caller, eth_amount: eth_amount_wei, tokens_amount, });
        }

        // ToDo Checkpoint 2: Implement your function withdraw here.
        fn withdraw(ref self: ContractState) {
            let caller = get_caller_address();
            // Make sure caller is the owner
            let actual_owner = self.owner();

            assert!(caller == actual_owner, "Only the owner can call this function");

            // Check how much ETH (ERC20) the contract holds
            let contract_eth_balance = self.eth_token.read().balanceOf(get_contract_address());

            if contract_eth_balance > 0 {
                // Transfer entire contract ETH balance to the owner
                self.eth_token.read().transfer(caller, contract_eth_balance);
            }
        }

        // ToDo Checkpoint 3: Implement your function sell_tokens here.
        fn sell_tokens(ref self: ContractState, amount_tokens: u256) {
            let caller = get_caller_address();

            self.your_token.read().transfer_from(caller, get_contract_address(), amount_tokens);

            let eth_amount = amount_tokens / TokensPerETh;

            let vendor_eth_balance = self.eth_token.read().balanceOf(get_contract_address());
            assert!(
                vendor_eth_balance >= eth_amount,
                "Vendor does not have enough ETH to complete this sale"
            );

            self.eth_token.read().transfer(caller, eth_amount);

            self.emit(SellTokens { seller: caller, tokens_amount: amount_tokens, eth_amount, });
        }

        // ToDo Checkpoint 2: Modify to return the amount of tokens per 1 ETH.
        fn tokens_per_eth(self: @ContractState) -> u256 {
            TokensPerETh
        }

        fn your_token(self: @ContractState) -> ContractAddress {
            self.your_token.read().contract_address
        }

        fn eth_token(self: @ContractState) -> ContractAddress {
            self.eth_token.read().contract_address
        }
    }
}
