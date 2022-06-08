// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;


// REVIEW -> This looks pretty good Peter, just a few suggestion:

// 1st (Check stake/unstake methods)

// 2nd Function issueTokens seems to be correctly implemented, however, we need a way to automate token issue every few blocks
// My suggestion is something like the following
// Use Chainlink Keepers to enable your smart contract to be automatically called every x minutes (see: https://docs.chain.link/docs/chainlink-keepers/introduction/)
// Verify if a certain number of blocks has been elapsed (using checkUpkeepNeeded function)
// If yes, run function issueTokens inside performUpKeep (the example from Chainlink should be quite similar too what we need) 



import "./CosmicToken.sol";
import "./CosmicLPT.sol";

contract TokenFarm {
    
    string public name = "Cosmic Single Pool Farm";
    address public owner;
    CosmicToken public cosmicToken;
    CosmicLPT public cosmicLPT;

    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(CosmicToken _cosmicToken, CosmicLPT _cosmicLPT) public {
        cosmicToken = _cosmicToken;
        cosmicLPT = _cosmicLPT;
        owner = msg.sender;
    }

    // REVIEW -> stakeTokens and unstakeTokens logic is correct, there's just a good practice pattern that's usually followed when writting solidity code callse CHECKS->EFFECTS->INTERACTIONS
    // (see: https://medium.com/returnvalues/smart-contract-security-patterns-79e03b5a1659)
    // Although I don't think this is a major security issue in this particular case, it's best to always follow this approach :)
    // My suggestion therefore is to rewrite this functions like the following:
    // CHECKS
    // require(_amount > 0, "amount cannot be 0");
    // EFFECTS
    // if(!hasStaked[msg.sender]) {
    //      stakers.push(msg.sender);
    //  }
    // stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
    // isStaking[msg.sender] = true;
    // hasStaked[msg.sender] = true;
    // INTERACTIONS
    // cosmicLPT.transferFrom(msg.sender, address(this), _amount);


    function stakeTokens(uint _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "amount cannot be 0");

        // Trasnfer Mock Cosmic LP tokens to this contract for staking
        cosmicLPT.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }


    // REVIEW -> Same approach as stakeTokenFunction

    // Unstaking Tokens (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer cosmic LP tokens to this contract for staking
        cosmicLPT.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
    }

    // Issuing Tokens
    function issueTokens() public {
        // Only owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers
        for (uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0) {
                cosmicToken.transfer(recipient, balance);
            }
        }
    }
}