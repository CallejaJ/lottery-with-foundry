// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";

contract DeployLottery is Script {
    uint256 public constant TICKET_PRICE = 0.01 ether; // 0.01 ETH por ticket
    
    function run() external returns (Lottery) {
        vm.startBroadcast();
        
        Lottery lottery = new Lottery(TICKET_PRICE);
        
        console.log("Lottery deployed at:", address(lottery));
        console.log("Owner:", lottery.owner());
        console.log("Ticket price:", lottery.ticketPrice());
        console.log("Lottery active:", lottery.lotteryActive());
        
        vm.stopBroadcast();
        
        return lottery;
    }
}