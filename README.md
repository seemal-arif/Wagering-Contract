# Wagering-Contract
A secure TLN-based wagering contract enabling player deposits, match creation, resolution, refunds, and admin-controlled fees.

## Description
This project was developed to enhance the transaction volume and circulation of the TLN token. The contract allows up to two players to participate in a match by depositing a specified amount of TLN, with a minimum deposit requirement of 5 TLN. Once the match is initiated, there are three possible outcomes: a win, a draw, or an unresolved state where no conclusion is reached. Additionally, if a player does not find an opponent, they can request a refund, which will be processed based on a predefined percentage. The contract ensures a fair and secure wagering system while maintaining the integrity of TLN token transactions.

## Challenges  
One of the main challenges in this contract was ensuring that match results could not be altered while also maintaining a fair system for all participants. To prevent manipulation, we restricted the ability to finalize match results to a designated moderator. However, this introduced another issue—the game would have to cover the gas fees for every match resolution, which was not a sustainable approach.  

## Solution  
To address this, we introduced a service charge that players pay along with their match deposit. This fee is used to cover the gas costs associated with processing match results, ensuring that the contract remains secure while also being economically viable. This approach balances security and efficiency, allowing for fair match resolutions without burdening the game operators with additional expenses.

## Deployment Details  
- **Network:** Arbitrum Sepolia  
- **Contract Address:** `0xc7d764237E54cCE77aE38a431f83A6cC85B781D7`  
- **Block Explorer:** [Arbiscan Link](https://sepolia.arbiscan.io/address/0xc7d764237E54cCE77aE38a431f83A6cC85B781D7#code)

 --- 
