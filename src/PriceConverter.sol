//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//all functions should br internal and no state variables
library PriceConverter{
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //priceFeed.latestRoundData(uint80 roundID, int price, uint startedAt, uint timeStamp, uint answeredInRound)
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversion(uint256 _ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256){
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) /1e18;
        return ethAmountInUsd;
    }

}