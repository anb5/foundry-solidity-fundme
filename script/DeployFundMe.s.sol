//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external returns(FundMe){
        //the code before broadcast doesn't cost gas cause it is not a real tx
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        //after broadcast everything is real tx
        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();
        return (fundMe);
    }
}