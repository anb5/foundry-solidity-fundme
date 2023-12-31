//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

//console used to log the things in the terminal handy when doing debugging
//run forge test -vv to run the test and vv here represents visibility of logs
contract FundMeTest is Test{

    //uint256 number = 5;
    FundMe fundMe;
    address USER = makeAddr("user"); //part of forge-std and we use this user to send all out tx's
    uint256 constant SEND_VALUE = 0.1 ether; // decimals won't work in solidity but when using with ether it works 
    //0.1 ether can be converted into 1000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external{
        //this function will run first
        //number = 2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.deal(USER,STARTING_BALANCE); // user is not having any bal intially we'll give some
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

    }

    function testMinimumDollarIsFive() public{
        // console.log(number);
        // console.log("Hello!!!");
        // console.log("testing");
        assertEq(fundMe.minimumUsd(),5e18); // checking minimumusd is 5 or not
    }

    function testOwnerIsMsgSender() public{
        //us->fundMeTest->FundMe
        //assertEq(fundMe.owner(),address(this));
        //since deployFundMe is deploying th contract we can go back t the msg.msg.sender
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }

    function testFailWithoutEnoughETH() public{
        vm.expectRevert();
        fundMe.fund{value:0}(); //this should fail
        //fundMe.fund() should work but it is not working if we are not passing anything it means value is 0
    }

    function testFundUpdateFundMeDataStructure() public{
        vm.prank(USER); // part of forge-std can be used to send our tx's 
        fundMe.fund{value:SEND_VALUE}();
        //uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        //address(this) because if we use msg.sender is not calling fundMe FundMeTest is the one who is calling fundMe so we've to use address(this)
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // it fails because this user doesn't have any funds to pay
        assertEq(amountFunded,SEND_VALUE);

    }

    function testAddFundersToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded(){
        //best practices 
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerWithdraw() funded public{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withDraw();
    }

    function testWithdrawWithASingleFunder() public{
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Anvil gas price is default zero so we need to use original on chain gas price So we can use txGasPrice() cheat code for that
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withDraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart-gasEnd)*tx.gasprice;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        console.log(gasUsed);
        assertEq(endingFundMeBalance,0);
        assertEq(startingOwnerBalance + startingFundMeBalance,endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() funded public{
        //uint256 numberOfFunders = 10;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i<= numberOfFunders;i++){
            //vm.prank() to add new funder address
            //vm.deal() to fund the new address added by the vm.prank
            //finally fund the contract
            //hoax() can do both prank and deal
            //uint160 has same number of bytes as the address
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withDraw();
        vm.stopPrank();

        assert(address(fundMe).balance==0);
        assert(fundMe.getOwner().balance == startingOwnerBalance+startingFundMeBalance);

    }

    function testWithdrawFromMultipleFundersCheaper() funded public{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i<= numberOfFunders;i++){
             hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheapWithDraw();
        vm.stopPrank();

        assert(address(fundMe).balance==0);
        assert(fundMe.getOwner().balance == startingOwnerBalance+startingFundMeBalance);

    }

}