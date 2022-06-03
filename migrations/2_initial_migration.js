const CosmicLPT = artifacts.require('CosmicLPT')
const CosmicToken = artifacts.require('CosmicToken')
const TokenFarm = artifacts.require('TokenFarm')






module.exports = async function(deployer, network, accounts) {

    // Deploy Cosmic LP Token
    await deployer.deploy(CosmicLPT)
    const cosmicLPT = await CosmicLPT.deployed()

    // Deploy cosmic reward Token
    await deployer.deploy(CosmicToken)
    const cosmicToken = await CosmicToken.deployed()

    // Deploy TokenFarm
    await deployer.deploy(TokenFarm, cosmicToken.address, cosmicLPT.address);
    const tokenFarm = await TokenFarm.deployed()


    //Transfer all Cosmic tokens to TokenFarm(Single liquidity-pool)
    await cosmicToken.transfer(tokenFarm.address, '2500000000000000000000000')

    //Transfer 100 Cosmic LP tokens to investors
    await cosmicLPT.transfer(accounts[1], '100000000000000000000')
};