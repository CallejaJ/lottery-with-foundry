// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Lottery} from "../src/Lottery.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    address public owner;
    address public player1;
    address public player2;
    address public player3;
    
    uint256 public constant TICKET_PRICE = 0.01 ether;
    
    function setUp() public {
        owner = address(this);
        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");
        
        // Dar ETH a los jugadores para testing
        vm.deal(player1, 10 ether);
        vm.deal(player2, 10 ether);
        vm.deal(player3, 10 ether);
        
        lottery = new Lottery(TICKET_PRICE);
    }
    
    function test_ConstructorSetsCorrectValues() public {
        assertEq(lottery.owner(), owner);
        assertEq(lottery.ticketPrice(), TICKET_PRICE);
        assertTrue(lottery.lotteryActive());
        assertEq(lottery.getPlayersCount(), 0);
    }
    
    function test_PlayerCanEnterLottery() public {
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        assertEq(lottery.getPlayersCount(), 1);
        assertEq(lottery.getTotalPrize(), TICKET_PRICE);
    }
    
    function test_RevertWhenIncorrectTicketPrice() public {
        vm.prank(player1);
        vm.expectRevert("Incorrect ticket price");
        lottery.enterLottery{value: TICKET_PRICE - 1}();
    }
    
    function test_MultiplePlayersCanEnter() public {
        // Player 1 entra
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        // Player 2 entra
        vm.prank(player2);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        // Player 3 entra
        vm.prank(player3);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        assertEq(lottery.getPlayersCount(), 3);
        assertEq(lottery.getTotalPrize(), TICKET_PRICE * 3);
    }
    
    function test_OnlyOwnerCanPickWinner() public {
        // Agregar un jugador
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        // Intentar que player2 elija ganador (debería fallar)
        vm.prank(player2);
        vm.expectRevert("Only owner can call this function");
        lottery.pickWinner();
    }
    
    function test_CannotPickWinnerWithNoPlayers() public {
        vm.expectRevert("No players in lottery");
        lottery.pickWinner();
    }
    
    function test_PickWinnerTransfersPrize() public {
        // Agregar jugadores
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        vm.prank(player2);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        uint256 totalPrize = lottery.getTotalPrize();
        uint256 player1BalanceBefore = player1.balance;
        uint256 player2BalanceBefore = player2.balance;
        
        // Elegir ganador
        lottery.pickWinner();
        
        // Verificar que la lotería se desactivó
        assertFalse(lottery.lotteryActive());
        assertEq(lottery.getPlayersCount(), 0);
        assertEq(lottery.getTotalPrize(), 0);
        
        // Verificar que uno de los jugadores recibió el premio
        bool player1Won = player1.balance == player1BalanceBefore + totalPrize;
        bool player2Won = player2.balance == player2BalanceBefore + totalPrize;
        
        assertTrue(player1Won || player2Won, "One of the players should have won");
    }
    
    function test_CannotEnterInactiveLottery() public {
        // Agregar un jugador y elegir ganador
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        lottery.pickWinner();
        
        // Intentar entrar en lotería inactiva
        vm.prank(player2);
        vm.expectRevert("Lottery is not active");
        lottery.enterLottery{value: TICKET_PRICE}();
    }
    
    function test_OwnerCanStartNewLottery() public {
        // Terminar lotería actual
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        lottery.pickWinner();
        
        // Iniciar nueva lotería
        uint256 newTicketPrice = 0.02 ether;
        lottery.startNewLottery(newTicketPrice);
        
        assertTrue(lottery.lotteryActive());
        assertEq(lottery.ticketPrice(), newTicketPrice);
    }
    
    function test_EmitsCorrectEvents() public {
        // Test evento PlayerEntered
        vm.expectEmit(true, false, false, true);
        emit Lottery.PlayerEntered(player1, 1);
        
        vm.prank(player1);
        lottery.enterLottery{value: TICKET_PRICE}();
        
        // Test evento WinnerPicked
        vm.expectEmit(true, false, false, true);
        emit Lottery.WinnerPicked(player1, TICKET_PRICE);
        
        lottery.pickWinner();
    }
    
    function testFuzz_EnterLotteryWithDifferentTicketPrices(uint256 price) public {
        vm.assume(price > 0 && price <= 100 ether);
        
        Lottery newLottery = new Lottery(price);
        vm.deal(player1, price);
        
        vm.prank(player1);
        newLottery.enterLottery{value: price}();
        
        assertEq(newLottery.getPlayersCount(), 1);
        assertEq(newLottery.getTotalPrize(), price);
    }
}