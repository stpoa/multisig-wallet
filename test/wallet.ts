const WalletContract: WalletContract = artifacts.require('./Wallet.sol');

import { assert } from 'chai';

contract('Wallet', accounts => {
  const defaultAccount = accounts[0];
  const deployerAccount = accounts[9];

  let instance: WalletInstance;

  beforeEach(async () => {
    instance = await WalletContract.new({ from: deployerAccount });
  });

  it("creates a wallet and assigns an owner", async () => {
    const owner: string = await instance.owner();
    assert.equal(owner, defaultAccount);
  });
});
