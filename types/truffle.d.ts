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
  owner: String,
}

declare interface WalletInstance {
  owner: () => Promise<string>,
}

declare interface MetaCoinInstance {
  getBalance(account: string): number,
  getBalanceInEth(account: string): number,
  sendCoin(account: string, amount: number, meta?: TransactionMeta): Promise<void>,
}

declare interface WalletContract {
  'new'(options?: TransactionOptions): WalletInstance,
  deployed(): Promise<Wallet>,
  at(address: string): Wallet,
  owner(): Promise<String>,
}

interface Artifacts {
  require(name: "./MetaCoin.sol"): Contract<MetaCoinInstance>,
  require(name: "./Wallet.sol"): WalletContract,
}



