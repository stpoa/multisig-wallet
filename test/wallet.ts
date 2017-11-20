const WalletContract: WalletContract = artifacts.require('./Wallet.sol');

import { assert } from 'chai';

contract('Wallet', accounts => {
  const defaultAccount = accounts[0];
  const deployerAccount = accounts[1];
  const OWNER_ONE = accounts[0];
  const OWNER_TWO = accounts[1];
  const OWNER_THREE = accounts[2];

  let instance: WalletInstance;

  beforeEach(async () => {
    instance = await WalletContract.new(
      [OWNER_ONE, OWNER_TWO, OWNER_THREE],
      { from: deployerAccount }
    );
  });

  it('creates a wallet and assigns an owner', async () => {
    const creator: string = await instance.creator();
    assert.equal(creator, deployerAccount);
  });

  it('assigns owners', async () => {
    const ownerOne: string = await instance.owners(0);
    const ownerTwo: string = await instance.owners(1);
    assert.equal(ownerOne, OWNER_ONE);
    assert.equal(ownerTwo, OWNER_TWO);
  })
});
