import { BigNumber } from 'bignumber.js';
import { PromiEvent } from "web3/types";
import * as Web3 from 'web3';
import { TransactionResult } from 'truffle';


declare interface ContractBase {
  address: string;
}

declare interface Contract<T> extends ContractBase {
  deployed(): Promise<T>;
}

declare type TransactionOptions = {
  from?: string;
  gas?: number;
  gasPrice?: number;
  value?: number | string;
};

declare type TransactionReceipt = {
  transactionHash: string;
  transactionIndex: number;
  blockHash: string;
  blockNumber: number;
  gasUsed: number;
  cumulativeGasUsed: number;
  contractAddress: string | null;
  logs: [TransactionLog];
};

declare type TransactionLog = {
  logIndex: number;
  transactionIndex: number;
  transactionHash: string;
  blockHash: string;
  blockNumber: number;
  address: string;
  type: string;
  event: string;
  args: any;
};

/* declare type TransactionResult = {
  tx: string;
  receipt: TransactionReceipt;
  logs: [TransactionLog];
}; */

declare interface MigrationsContract extends Contract<Migrations> {
  'new'(options?: TransactionOptions): Promise<Migrations>;
}

declare interface AddressSetLibrary extends Contract<AddressSet> {
  'new'(options?: TransactionOptions): Promise<AddressSet>;
}

declare interface WalletContract extends Contract<Wallet> {
  'new'(owners: string[], options?: TransactionOptions): Promise<Wallet>;
}

declare interface Wallet {
  creator(options?: TransactionOptions): Promise<string>;
  confirmationCounts(transactionHahs: String): Promise<BigNumber>;
  owners(index: number, options?: TransactionOptions): Promise<string>;
  isOwner(address: string, options?: TransactionOptions): boolean;
  transfer(destination: string, value: number, options?: TransactionOptions): Promise<TransactionResult>;
  deposit(options?: TransactionOptions): Promise<TransactionResult>;
}

declare interface Migrations {
  setCompleted(
    completed: number,
    options?: TransactionOptions
  ): Promise<TransactionResult>;

  upgrade(
    address: string,
    options?: TransactionOptions
  ): Promise<TransactionResult>;
}

declare interface AddressSet {
  get(): Promise<string[]>;

  add(
    element: string,
    options?: TransactionOptions
  ): Promise<TransactionResult>;
}

declare interface Artifacts {
  require(name: './Migrations.sol'): MigrationsContract;
  require(name: './AddressSet.sol'): AddressSetLibrary;
  require(name: './Wallet.sol'): WalletContract;
  require(name: string): ContractBase;
}

declare interface Deployer extends Promise<void> {
  deploy(object: ContractBase): Promise<void>;

  link(
    library: ContractBase,
    contracts: ContractBase | [ContractBase]
  ): Promise<void>;
}

interface ContractContextDefinition extends Mocha.IContextDefinition {
  (description: string, callback: (accounts: string[]) => void): Mocha.ISuite;
}

declare interface TransactionMeta {
  from: string,
}

declare interface MetaCoinInstance {
  getBalance(account: string): number,
  getBalanceInEth(account: string): number,
  sendCoin(account: string, amount: number, meta?: TransactionMeta): Promise<void>,
}

declare global {
  var artifacts: Artifacts;
  var web3: Web3;
  var assert: Chai.AssertStatic;
  var contract: ContractContextDefinition;
}
