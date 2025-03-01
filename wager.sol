// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract USDTWager is Ownable, ReentrancyGuard {
    
    using SafeERC20 for IERC20;
    IERC20 public immutable USDTToken;

    address public moderator;
    address public gasFeeHolderAccount;
    uint256 public minDeposit = 5 * 1e18;                // Minimum 5 USDT 
    uint256 public winnerPercentage = 8000;              // Default 80% (1bps = 100) winnerPercentage for users
    uint256 public xrpNFTHolderPercentage = 9000;        // Default 90% winner percentage for users
    uint256 public userRefundPercentage = 9000;          // Default 90% refund for unmatched users
    
   
    struct Player {
        address wallet;
        uint256 depositAmount;
        uint256 serviceCharges;
        bool isMatched;
        bool refunded;
    }
    struct Wager {
        address player1;
        address player2;
        uint256 amount;
        bool isMatched;
    }
    
    mapping(address playerAddress => Player) public players;
    mapping(string matchId => Wager) public wagers;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     Events                                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event MinDepositUpdated(uint256 newMinDeposit);
    event ModeratorUpdated(address indexed newWallet);
    event FeeHolderAccountUpdated(address indexed newWallet);
    event Refunded(address indexed user, uint256 refundedAmount);
    event PercentageUpdated(string updatedField, uint256 newValue);
    event Deposited(address indexed user, uint256 depositedAmount, uint256 serviceCharges);
    event MatchUnsuccessful(string indexed matchId, address adminWallet, uint256 adminAmount);
    event MatchDraw(string indexed matchId, uint256 amountTransferredToEachPlayer, uint256 ownerShare);
    event Matched(address indexed player1, address indexed player2, uint256 wagerAmount, string matchId);
    event MatchResolved(string indexed matchId, address winner, uint256 winnerAmount, uint256 ownerShare);
    
    constructor(
        address USDTTokenContract,
        address owner,
        address _moderator,
        address feeHolderAccount
        ) Ownable(owner){

        require(feeHolderAccount != address(0), "Invalid fee holder account address");
        require(USDTTokenContract != address(0), "Invalid USDT token address");
        require(_moderator != address(0), "Invalid moderator address");
        require(owner != address(0), "Invalid owner address");
        
        USDTToken = IERC20(USDTTokenContract);
        moderator = _moderator;
        gasFeeHolderAccount = feeHolderAccount;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     Modifier                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier onlyModerator() {
        require(msg.sender == moderator || msg.sender == owner(), "Only owner or moderator can call this function");
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     Helper Function                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    
    function resetPlayer(address player) internal {
        delete players[player];
    }


    /**
     * @notice Allows a user to deposit depositAmount of USDT for match participation.
     * @dev Caller must first approve the contract to spend depositAmount + serviceCharges USDT.
     * @param depositAmount The amount of USDT to be deposited for the match.
     * @param serviceCharges The USDT fee to cover gas costs.
    */

    function deposit(uint256 depositAmount, uint256 serviceCharges) external nonReentrant  {
        require(players[msg.sender].isMatched == false, "Already deposited, waiting for match");
        // You cannot deposit again until your previous deposit is refunded or the match is completed.
        require(players[msg.sender].depositAmount == 0, "Already deposited.");
        require(depositAmount >= minDeposit, "Minimum deposit is 5 USDT");
        require(serviceCharges > 0, "Service charges cannot be zero");
        uint256 amount = depositAmount + serviceCharges;
        require(USDTToken.balanceOf(msg.sender) >= amount, "Insufficient USDT tokens");

        USDTToken.safeTransferFrom(msg.sender, address(this), depositAmount);
        USDTToken.safeTransferFrom(msg.sender, gasFeeHolderAccount, serviceCharges);
        players[msg.sender] = Player(msg.sender, depositAmount, serviceCharges, false,false);
        emit Deposited(msg.sender, depositAmount, serviceCharges);
    }

    /**
     * @notice Matches two players for a wager and records the match details.
     * @dev Ensures both players have deposited and are not already in a match.
     * @param matchId A unique identifier for the match.
     * @param player1 The address of the first player.
     * @param player2 The address of the second player.
    */

    function matchPlayers(string memory matchId, address player1, address player2) external onlyModerator {
        require(wagers[matchId].amount == 0, "Wager already exists for this match.");
        require(!players[player1].isMatched, "Player 1 already in match");
        require(!players[player2].isMatched, "Player 2 already in match");
        uint256 wagerAmount = players[player1].depositAmount + players[player2].depositAmount;
        wagers[matchId] = Wager(player1, player2, wagerAmount, true);
        players[player1].isMatched = true;
        players[player2].isMatched = true;
        emit Matched(player1, player2, wagerAmount, matchId);
    }

    /**
     * @notice Resolves a match by distributing the wager amount between the winner and the admin.
     * @dev The winner receives a percentage of the total wager based on whether they hold an XRP NFT.
     * @param matchId The unique identifier for the match.
     * @param winner The address of the winning player.
     * @param isXrpNftHolder Boolean indicating if the winner holds an XRP NFT.
    */


    function resolveMatch(string memory matchId, address winner, bool isXrpNftHolder) external onlyModerator nonReentrant {
        Wager storage wager = wagers[matchId];
        require(wager.isMatched, "Match not found.");

        uint256 totalWager = wager.amount;
        uint256 winnerShare = isXrpNftHolder ? (totalWager * xrpNFTHolderPercentage) / 10000 : (totalWager * winnerPercentage) / 10000;
        uint256 adminShare = totalWager - winnerShare;

        USDTToken.safeTransfer(winner, winnerShare);
        if (adminShare > 0) {
            USDTToken.safeTransfer(owner(), adminShare);
        }

        emit MatchResolved(matchId, winner, winnerShare, adminShare);

        resetPlayer(wager.player1);
        resetPlayer(wager.player2);
        delete wagers[matchId];
    }

    /**
     * @notice Handles an unsuccessful match by transferring all wagered funds to the admin.
     * @dev Used in cases where a match cannot proceed, ensuring funds are not left in the contract.
     * @param matchId The unique identifier for the match.
    */

    function unsuccessfulMatch(string memory matchId) external onlyModerator nonReentrant  {
        Wager storage wager = wagers[matchId];
        require(wager.isMatched, "Match not found.");

        uint256 totalWager = wager.amount;
        address ownerWallet = owner();
        // Transfer all funds to the admin
        if (totalWager > 0) {
            USDTToken.safeTransfer(ownerWallet, totalWager);
        }

        emit MatchUnsuccessful(matchId, ownerWallet, totalWager);

        resetPlayer(wager.player1);
        resetPlayer(wager.player2);

        delete wagers[matchId];
    }

    /**
     * @notice Handles a match that ends in a draw by splitting the wager amount between both players.
     * @dev A portion of the wager is allocated to the admin, with the remaining amount split equally between the players.
     * @param matchId The unique identifier for the match.
    */

    function matchDraw(string memory matchId) external onlyModerator nonReentrant {
        Wager storage wager = wagers[matchId];
        require(wager.isMatched, "Match not found");

        uint256 totalWager = wager.amount;
        uint256 adminShare = (totalWager * (10000 - winnerPercentage)) / 10000;
        uint256 splitAmount = (totalWager - adminShare) / 2;

        USDTToken.safeTransfer(owner(), adminShare);
        USDTToken.safeTransfer(wager.player1, splitAmount);
        USDTToken.safeTransfer(wager.player2, splitAmount);

        emit MatchDraw(matchId, splitAmount, adminShare);

        resetPlayer(wager.player1);
        resetPlayer(wager.player2);

        delete wagers[matchId];
    }

    
    /**
     * @notice Processes a refund for a player who was not matched in a game.
     * @dev The user receives a percentage of their deposit, while the admin keeps the remaining amount.
     * @param userWallet The address of the player requesting a refund.
    */

    function requestRefund(address userWallet) external onlyModerator nonReentrant {
        require(players[userWallet].depositAmount > 0, "No deposit found");
        require(!players[userWallet].refunded, "Already refunded");
        require(!players[userWallet].isMatched,"Cannot refund while in an active match");
        
        uint256 refundAmount = (players[userWallet].depositAmount * userRefundPercentage) / 10000;
        uint256 adminShare = players[userWallet].depositAmount - refundAmount;

        USDTToken.safeTransfer(userWallet, refundAmount);

        if (adminShare > 0) {
            USDTToken.safeTransfer(owner(), adminShare);
        }
        
        emit Refunded(userWallet, refundAmount);
        resetPlayer(userWallet);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    Admin Controls                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function updateModerator(address newModerator) external onlyOwner {
        require(newModerator != address(0), "Invalid moderator address");
        moderator = newModerator;
        emit ModeratorUpdated(newModerator);
    }

    function updateGasFeeHolderAccount(address newAccount) external onlyOwner {
        require(newAccount != address(0), "Invalid fee holder address address");
        gasFeeHolderAccount = newAccount;
        emit FeeHolderAccountUpdated(newAccount);
    }

    function updateWinnerPercentage(uint256 newWinnerPercentage) external onlyOwner {
        require(newWinnerPercentage <= 10000, "Winner percentage cannot exceed 100%");
        winnerPercentage = newWinnerPercentage;
        emit PercentageUpdated("winnerPercentage", newWinnerPercentage);
    }

    function updateXrpNFTHolderPercentage(uint256 newXrpNFTHolderPercentage) external onlyOwner {
        require(newXrpNFTHolderPercentage <= 10000, "XRP NFT holder percentage cannot exceed 100%");
        xrpNFTHolderPercentage = newXrpNFTHolderPercentage;
        emit PercentageUpdated("xrpNFTHolderPercentage", newXrpNFTHolderPercentage);
    }

    function updateUserRefundPercentage(uint256 newUserRefundPercentage) external onlyOwner {
        require(newUserRefundPercentage <= 10000, "Refund percentage cannot exceed 100%");
        userRefundPercentage = newUserRefundPercentage;
        emit PercentageUpdated("userRefundPercentage", newUserRefundPercentage);
    }

    function updateMinDeposit(uint256 newMinDeposit) external onlyOwner {
        require(newMinDeposit > 0, "Minimum deposit must be greater than zero");
        minDeposit = newMinDeposit;
        emit MinDepositUpdated(newMinDeposit);
    }


}