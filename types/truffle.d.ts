declare type _contractTest = (accounts: string[]) => void;
declare interface TransactionMeta {
  from: string,
}

declare interface Contract<T> {
  "new"(): Promise<T>,
  deployed(): Promise<T>,
  at(address: string): T,
}

declare interface Wallet {
  creator: String,
}

declare interface WalletInstance {
  creator: () => Promise<string>,
  owners: (index: number) => Promise<string>,
}

declare interface MetaCoinInstance {
  getBalance(account: string): number,
  getBalanceInEth(account: string): number,
  sendCoin(account: string, amount: number, meta?: TransactionMeta): Promise<void>,
}

declare interface WalletContract {
  'new'(owners: string[], options?: TransactionOptions): WalletInstance,
  deployed(): Promise<Wallet>,
  at(address: string): Wallet,
  creator(): Promise<string>,
  owners(index: number): Promise<string>,
}

interface Artifacts {
  require(name: "./MetaCoin.sol"): Contract<MetaCoinInstance>,
  require(name: "./Wallet.sol"): WalletContract,
}

