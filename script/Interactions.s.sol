//SPDX-License-Identifier : MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script{

    uint256 SEND_VALUE = 0.1 ether;
    function fundFundMe(address mostRecentlyDeployedContract) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("FundMe funded with %s",SEND_VALUE);

    }
    function run() external{
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        // the above line looks up for the moset recently deployed contract in broadcast folder and runs it
        fundFundMe(mostRecentlyDeployedContract);
    }
}

contract WithDrawFundMe is Script{

    uint256 SEND_VALUE = 0.01 ether;
    function withDrawFundMe(address mostRecentlyDeployedContract) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).withDraw();
        vm.stopBroadcast();
        console.log("FundMe funded with %s",SEND_VALUE);

    }
    function run() external{
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        // the above line looks up for the moset recently deployed contract in broadcast folder and runs it
        withDrawFundMe(mostRecentlyDeployedContract);
    }
}