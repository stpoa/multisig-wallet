const WalletContract = artifacts.require('./Wallet.sol');

import { assert } from 'chai';
import { assertEtherAlmostEqual, getBalance, fromEtherToWei, findLastLog } from './helpers';
import { WalletContract, Wallet } from 'types/globals';

contract('Wallet', (accounts) => {
  const OWNER_ONE = accounts[0];
  const OWNER_TWO = accounts[1];
  const OWNER_THREE = accounts[2];
  const NEW_OWNER = accounts[3];
  const NOT_OWNER = accounts[9];
  const OWNERS = [OWNER_ONE, OWNER_TWO, OWNER_THREE];
  const NEW_OWNERS = [OWNER_ONE, OWNER_TWO, NEW_OWNER];
  const DEPOSIT_AMOUNT = fromEtherToWei(5);
  const TRANSFER_AMOUNT = fromEtherToWei(1);

  let instance: Wallet;

  beforeEach(async () => {
    instance = await WalletContract.new(OWNERS, { from: OWNER_TWO });
  });

  it('assigns proper owners on creation', async () => {
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
    await instance.deposit({ from: OWNER_ONE, value: DEPOSIT_AMOUNT });
    const balanceAfter = await getBalance(OWNER_ONE);

    assertEtherAlmostEqual(balanceAfter, balanceBefore.sub(DEPOSIT_AMOUNT));
  });

  it('confirms a transfer', async () => {
    const trans = await instance.transfer(OWNER_ONE, TRANSFER_AMOUNT, { from: OWNER_ONE });
    const log = findLastLog(trans, 'TransferCalled');
    const event = log.args;
    const confirmationsCount = await instance.confirmationsCount(event.transactionHash);

    assert.equal('1', confirmationsCount.toString());
  });

  it('starts a transaction', async () => {
    const balanceBefore = await getBalance(OWNER_ONE);

    // Deposit
    await instance.deposit({ from: OWNER_ONE, value: DEPOSIT_AMOUNT });

    // Transfer
    await instance.transfer(OWNER_ONE, TRANSFER_AMOUNT, { from: OWNER_ONE });
    await instance.transfer(OWNER_ONE, TRANSFER_AMOUNT, { from: OWNER_TWO });
    await instance.transfer(OWNER_ONE, TRANSFER_AMOUNT, { from: OWNER_THREE });

    const balanceAfter = await getBalance(OWNER_ONE);

    assertEtherAlmostEqual(balanceAfter, balanceBefore.sub(DEPOSIT_AMOUNT).add(TRANSFER_AMOUNT));
  });

  it('changes owners', async () => {
    const ownerBefore = await instance.owners(2);
    await instance.changeOwner(NEW_OWNERS, { from: OWNER_ONE });
    await instance.changeOwner(NEW_OWNERS, { from: OWNER_TWO });
    await instance.changeOwner(NEW_OWNERS, { from: OWNER_THREE });
    const ownerAfter = await instance.owners(2);

    assert.notEqual(ownerBefore, ownerAfter);
  });
});
