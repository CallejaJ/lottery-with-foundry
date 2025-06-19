// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Lottery
 * @dev Un contrato de lotería simple donde los usuarios pueden comprar tickets
 * y un ganador es elegido aleatoriamente
 */
contract Lottery {
    // Variables de estado
    address public owner;
    address payable[] public players;
    uint256 public ticketPrice;
    bool public lotteryActive;
    
    // Eventos
    event PlayerEntered(address indexed player, uint256 ticketNumber);
    event WinnerPicked(address indexed winner, uint256 amount);
    event LotteryStarted(uint256 ticketPrice);
    event LotteryEnded();
    
    // Modificadores
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier lotteryIsActive() {
        require(lotteryActive, "Lottery is not active");
        _;
    }
    
    // Constructor
    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryActive = true;
        emit LotteryStarted(_ticketPrice);
    }
    
    /**
     * @dev Permite a un usuario comprar un ticket de lotería
     */
    function enterLottery() external payable lotteryIsActive {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, players.length);
    }
    
    /**
     * @dev Genera un número pseudoaleatorio (NO usar en producción)
     * En producción se debería usar Chainlink VRF u otro oracle
     */
    function generateRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.difficulty,
            players.length,
            msg.sender
        )));
    }
    
    /**
     * @dev Elige un ganador y transfiere el premio
     */
    function pickWinner() external onlyOwner lotteryIsActive {
        require(players.length > 0, "No players in lottery");
        
        uint256 randomIndex = generateRandomNumber() % players.length;
        address payable winner = players[randomIndex];
        uint256 prize = address(this).balance;
        
        // Resetear el estado
        lotteryActive = false;
        
        // Transferir premio
        winner.transfer(prize);
        
        emit WinnerPicked(winner, prize);
        emit LotteryEnded();
        
        // Limpiar array de jugadores
        delete players;
    }
    
    /**
     * @dev Inicia una nueva lotería
     */
    function startNewLottery(uint256 _newTicketPrice) external onlyOwner {
        require(!lotteryActive, "Previous lottery must be ended first");
        
        ticketPrice = _newTicketPrice;
        lotteryActive = true;
        
        emit LotteryStarted(_newTicketPrice);
    }
    
    /**
     * @dev Obtiene el número de jugadores
     */
    function getPlayersCount() external view returns (uint256) {
        return players.length;
    }
    
    /**
     * @dev Obtiene el balance total del contrato
     */
    function getTotalPrize() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Obtiene todos los jugadores
     */
    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}