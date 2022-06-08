const CosmicLPT = artifacts.require('CosmicLPT')
const CosmicToken = artifacts.require('CosmicToken')
const TokenFarm = artifacts.require('TokenFarm')


require('chai')
    .use(require('chai-as-promised'))
    .should()

function tokens(n) {
    return web3.utils.toWei(n, 'ether');
}


// REVIEW -> Tests' logic looks good :)
// However as another good practice we may separate the into more granular tests (instead of asserting that many things inside the it('rewards investors for staking cosmic LP tokens',)
// This is one more suggestion for organization and clarity's sake, because your tests are correct regardless 
// Also try to test the CHECKS/requires in all of your methods (Although in this case it's very straight forward to assure it will work, it's also a good practice)


contract('TokenFarm', ([owner, investor]) => {
    let cosmicLPT, cosmicToken, tokenFarm

    before(async() => {
        // Load Contracts
        cosmicLPT = await CosmicLPT.new()
        cosmicToken = await CosmicToken.new()
        tokenFarm = await TokenFarm.new(cosmicToken.address, cosmicLPT.address)

        // Transfer all Cosmic tokens to farm (2.5 million)
        await cosmicToken.transfer(tokenFarm.address, tokens('2500000'))

        // Send tokens to investor
        await cosmicLPT.transfer(investor, tokens('100'), { from: owner })
    })

    describe('CosmicLPT deployment', async() => {
        it('has a name', async() => {
            const name = await cosmicLPT.name()
            assert.equal(name, 'CosmicLPToken')
        })
    })

    describe('CosmicToken deployment', async() => {
        it('has a name', async() => {
            const name = await cosmicToken.name()
            assert.equal(name, 'CosmicToken')
        })
    })

    describe('TokenFarm deployment', async() => {
        it('has a name', async() => {
            const name = await tokenFarm.name()
            assert.equal(name, 'Cosmic Single Pool Farm')
        })

        it('contract has tokens', async() => {
            let balance = await cosmicToken.balanceOf(tokenFarm.address)
            assert.equal(balance.toString(), tokens('2500000'))
        })
    })

    describe('Farming tokens', async() => {

        it('rewards investors for staking cosmic LP tokens', async() => {
            let result

            // Check investor balance before staking
            result = await cosmicLPT.balanceOf(investor)
            assert.equal(result.toString(), tokens('100'), 'investor cosmic LP token wallet balance correct before staking')

            // Stake Cosmic LP Tokens
            await cosmicLPT.approve(tokenFarm.address, tokens('100'), { from: investor })
            await tokenFarm.stakeTokens(tokens('100'), { from: investor })

            // Check staking result
            result = await cosmicLPT.balanceOf(investor)
            assert.equal(result.toString(), tokens('0'), 'investor Cosmic LP token wallet balance correct after staking')

            result = await cosmicLPT.balanceOf(tokenFarm.address)
            assert.equal(result.toString(), tokens('100'), 'Token Farm Cosmic Token  balance correct after staking')

            result = await tokenFarm.stakingBalance(investor)
            assert.equal(result.toString(), tokens('100'), 'investor staking balance correct after staking')

            result = await tokenFarm.isStaking(investor)
            assert.equal(result.toString(), 'true', 'investor staking status correct after staking')

            // Issue Tokens
            await tokenFarm.issueTokens({ from: owner })

            // Check balances after issuance
            result = await cosmicToken.balanceOf(investor)
            assert.equal(result.toString(), tokens('100'), 'investor Cosmic Token wallet balance correct affter issuance')

            // Ensure that only onwer can issue tokens
            await tokenFarm.issueTokens({ from: investor }).should.be.rejected;

            // Unstake tokens
            await tokenFarm.unstakeTokens({ from: investor })

            // Check results after unstaking
            result = await cosmicLPT.balanceOf(investor)
            assert.equal(result.toString(), tokens('100'), 'investor Cosmic LP token wallet balance correct after staking')

            result = await cosmicLPT.balanceOf(tokenFarm.address)
            assert.equal(result.toString(), tokens('0'), 'Token Farm Cosmic Token  balance correct after staking')

            result = await tokenFarm.stakingBalance(investor)
            assert.equal(result.toString(), tokens('0'), 'investor staking balance correct after staking')

            result = await tokenFarm.isStaking(investor)
            assert.equal(result.toString(), 'false', 'investor staking status correct after staking')
        })
    })

})