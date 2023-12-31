//SPDX-License-Identifier:MIT
//deploy mocks when we are on anvil chain 
//like deploying fake pricefeed chain on anvil 
//keep tack of contract address acroos different chains
//Example sepolia ETH/USD mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../../test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script{
    //if we are anvil deploy mock
    //otherwise will fetch address from the live network
    NetworkConfig public activeNetworkConfig;
    uint8 constant public DECIMALs = 8;
    int constant public INTIAL_PRICE = 2000e8;
    struct NetworkConfig{
    address priceFeed;
    }
    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory sepoliaNetworkConfig){
        sepoliaNetworkConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        //deploy the mocks
        //return the mock address
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALs,INTIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});

        return anvilConfig;

    }

}

