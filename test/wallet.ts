const WalletContract = artifacts.require('./Wallet.sol');

import { assert } from 'chai';
import { assertEtherAlmostEqual, getBalance, fromEtherToWei } from './helpers';
import { WalletContract, Wallet } from 'types/globals';

contract('Wallet', (accounts) => {
  const defaultAccount = accounts[0];
  const deployerAccount = accounts[1];
  const OWNER_ONE = accounts[0];
  const OWNER_TWO = accounts[1];
  const OWNER_THREE = accounts[2];

  let instance: Wallet;

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
  });

  it('checks if is owner', async () => {
    const isOwner = await instance.isOwner(OWNER_ONE);
    assert.isTrue(isOwner);
  });

  it('deposits ether', async () => {
    const balanceBefore = await getBalance(OWNER_ONE);
    const value = fromEtherToWei(1);
    await instance.deposit({ from: OWNER_ONE, value: value });
    const balanceAfter = await getBalance(OWNER_ONE);

    assertEtherAlmostEqual(balanceAfter, balanceBefore.sub(value));
  });
});
