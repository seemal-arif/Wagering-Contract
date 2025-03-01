# Wagering-Contract
A secure USDT-based wagering contract enabling player deposits, match creation, resolution, refunds, and admin-controlled fees.

## Deployment Details  
- **Network:** Arbitrum Sepolia  
- **Contract Address:** `0xC1FF2ebaf5a6F96cfD2dF9B3EF9d9E80c1e1bbe7`  
- **Block Explorer:** [Arbiscan Link]([https://sepolia.arbiscan.io/address/0xYourDeployedContractAddressHere](https://sepolia.arbiscan.io/address/0xC1FF2ebaf5a6F96cfD2dF9B3EF9d9E80c1e1bbe7#code))
  
 --- 
### Modifiers:
### onlyModerator

```solidity
modifier onlyModerator()
```

 --- 
### Functions:
### constructor

```solidity
constructor(address USDTTokenContract, address owner, address _moderator, address feeHolderAccount) public
```

### resetPlayer

```solidity
function resetPlayer(address player) internal
```

### deposit

```solidity
function deposit(uint256 depositAmount, uint256 serviceCharges) external
```

Allows a user to deposit depositAmount of USDT for match participation.

_Caller must first approve the contract to spend depositAmount + serviceCharges USDT._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| depositAmount | uint256 | The amount of USDT to be deposited for the match. |
| serviceCharges | uint256 | The USDT fee to cover gas costs. |

### matchPlayers

```solidity
function matchPlayers(string matchId, address player1, address player2) external
```

Matches two players for a wager and records the match details.

_Ensures both players have deposited and are not already in a match._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| matchId | string | A unique identifier for the match. |
| player1 | address | The address of the first player. |
| player2 | address | The address of the second player. |

### resolveMatch

```solidity
function resolveMatch(string matchId, address winner, bool isXrpNftHolder) external
```

Resolves a match by distributing the wager amount between the winner and the admin.

_The winner receives a percentage of the total wager based on whether they hold an XRP NFT._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| matchId | string | The unique identifier for the match. |
| winner | address | The address of the winning player. |
| isXrpNftHolder | bool | Boolean indicating if the winner holds an XRP NFT. |

### unsuccessfulMatch

```solidity
function unsuccessfulMatch(string matchId) external
```

Handles an unsuccessful match by transferring all wagered funds to the admin.

_Used in cases where a match cannot proceed, ensuring funds are not left in the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| matchId | string | The unique identifier for the match. |

### matchDraw

```solidity
function matchDraw(string matchId) external
```

Handles a match that ends in a draw by splitting the wager amount between both players.

_A portion of the wager is allocated to the admin, with the remaining amount split equally between the players._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| matchId | string | The unique identifier for the match. |

### requestRefund

```solidity
function requestRefund(address userWallet) external
```

Processes a refund for a player who was not matched in a game.

_The user receives a percentage of their deposit, while the admin keeps the remaining amount._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| userWallet | address | The address of the player requesting a refund. |

### updateModerator

```solidity
function updateModerator(address newModerator) external
```

### updateGasFeeHolderAccount

```solidity
function updateGasFeeHolderAccount(address newAccount) external
```

### updateWinnerPercentage

```solidity
function updateWinnerPercentage(uint256 newWinnerPercentage) external
```

### updateXrpNFTHolderPercentage

```solidity
function updateXrpNFTHolderPercentage(uint256 newXrpNFTHolderPercentage) external
```

### updateUserRefundPercentage

```solidity
function updateUserRefundPercentage(uint256 newUserRefundPercentage) external
```

### updateMinDeposit

```solidity
function updateMinDeposit(uint256 newMinDeposit) external
```

inherits ReentrancyGuard:
### _reentrancyGuardEntered

```solidity
function _reentrancyGuardEntered() internal view returns (bool)
```

_Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
`nonReentrant` function in the call stack._

inherits Ownable:
### owner

```solidity
function owner() public view virtual returns (address)
```

_Returns the address of the current owner._

### _checkOwner

```solidity
function _checkOwner() internal view virtual
```

_Throws if the sender is not the owner._

### renounceOwnership

```solidity
function renounceOwnership() public virtual
```

_Leaves the contract without owner. It will not be possible to call
`onlyOwner` functions. Can only be called by the current owner.

NOTE: Renouncing ownership will leave the contract without an owner,
thereby disabling any functionality that is only available to the owner._

### transferOwnership

```solidity
function transferOwnership(address newOwner) public virtual
```

_Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner._

### _transferOwnership

```solidity
function _transferOwnership(address newOwner) internal virtual
```

_Transfers ownership of the contract to a new account (`newOwner`).
Internal function without access restriction._

 --- 
### Events:
### MinDepositUpdated

```solidity
event MinDepositUpdated(uint256 newMinDeposit)
```

### ModeratorUpdated

```solidity
event ModeratorUpdated(address newWallet)
```

### FeeHolderAccountUpdated

```solidity
event FeeHolderAccountUpdated(address newWallet)
```

### Refunded

```solidity
event Refunded(address user, uint256 refundedAmount)
```

### PercentageUpdated

```solidity
event PercentageUpdated(string updatedField, uint256 newValue)
```

### Deposited

```solidity
event Deposited(address user, uint256 depositedAmount, uint256 serviceCharges)
```

### MatchUnsuccessful

```solidity
event MatchUnsuccessful(string matchId, address adminWallet, uint256 adminAmount)
```

### MatchDraw

```solidity
event MatchDraw(string matchId, uint256 amountTransferredToEachPlayer, uint256 ownerShare)
```

### Matched

```solidity
event Matched(address player1, address player2, uint256 wagerAmount, string matchId)
```

### MatchResolved

```solidity
event MatchResolved(string matchId, address winner, uint256 winnerAmount, uint256 ownerShare)
```

inherits ReentrancyGuard:
inherits Ownable:
### OwnershipTransferred

```solidity
event OwnershipTransferred(address previousOwner, address newOwner)
```

