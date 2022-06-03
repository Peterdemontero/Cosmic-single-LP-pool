const TokenFarm = artifacts.require('TokenFarm')


module.exports = async function(callback) {

    // Call issue token function
    let tokenFarm = await TokenFarm.deployed()
    await tokenFarm.issueTokens()

    //code goes here
    console.log("Token issued");
    callback()

};