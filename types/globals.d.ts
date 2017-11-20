declare interface Web3 {
    toAscii(hex: string): string;
    fromAscii(ascii: string, padding?: number): string;
    sha3(str: string, options?: { encoding: 'hex' }): string;
  }
  
  declare interface ContractBase {
    address: string;
  }

  
  declare type TransactionOptions = {
    from?: string;
    gas?: number;
    gasPrice?: number;
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
  
  declare type TransactionResult = {
    tx: string;
    receipt: TransactionReceipt;
    logs: [TransactionLog];
  };
  
  
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
  
  declare const artifacts: Artifacts;
  declare const contract: ContractContextDefinition;
  declare const assert: Chai.Assert;
  declare const web3: Web3;