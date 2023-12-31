//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract FundMe{
    //constant immutable
    error FundMe__NotOwner(); //custom error
    using PriceConverter for uint256;
    uint256 public constant minimumUsd = 5e18;
    address [] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded; // changed from public to private since private is more gas efficient
    address private immutable owner;
    AggregatorV3Interface private s_priceFeed;
    constructor(address priceFeed){
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
    function fund() public payable{
        //allow users to send $
        //minimum is 5usd
        require(msg.value.getConversion(s_priceFeed) >= minimumUsd, "didn't send enough ETH"); //1e18 = 1eth = 1*10**18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    function getVersion() public view returns(uint256){
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return s_priceFeed.version();
    }
    function withDraw() public onlyOwner{
        //require(msg.sender== owner,"must be owner");
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
          address funder = s_funders[funderIndex]; // here we are reading from storage so it costs approx 100 gas
          s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); // reset array
        //transfer send call
        /* payable(msg.sender).transfer(address(this).balance);
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess,"send failed"); */
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"call failed");
    }
    function cheapWithDraw() public onlyOwner{
        address[] memory funders = s_funders;
        for(uint256 funderIndex = 0; funderIndex<funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"call failed");
    }
    //modifier
    modifier onlyOwner(){
        //_; executes function code first and then modifier
        //require(msg.sender==owner, "not owner");
        if(msg.sender!=owner){revert FundMe__NotOwner();} // more gas efficient than require
        _; // execute modifier first an the resst of the code in the function
    }
    //receive fallback functions
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }

    //view and pure functions aka getters

    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address){
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return owner;
    }

}
