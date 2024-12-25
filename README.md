# Bitcoin Tokenizer Smart Contract

A secure and efficient wrapped Bitcoin (wBTC) implementation on the Stacks blockchain that enables users to deposit BTC, mint wBTC tokens, and participate in the Stacks DeFi ecosystem.

## Features

- **BTC Deposits**: Securely deposit BTC to mint wBTC tokens
- **BTC Withdrawals**: Burn wBTC tokens to withdraw BTC
- **Token Transfers**: Transfer wBTC between accounts
- **Operator Approval System**: Delegate token management to approved operators
- **Fee Management**: Configurable protocol fee rate
- **Emergency Controls**: Emergency shutdown capability for enhanced security
- **Treasury Management**: Dedicated treasury for fee collection

## Technical Specifications

- **Minimum Deposit**: 100 satoshis
- **Maximum Deposit**: 1,000,000,000 satoshis (10 BTC)
- **Default Fee Rate**: 0.5% (5/1000)
- **Token Decimals**: 8

## Contract Functions

### User Functions

- `deposit-btc`: Deposit BTC to mint wBTC tokens
- `withdraw-btc`: Burn wBTC tokens to withdraw BTC
- `transfer`: Transfer wBTC between accounts
- `approve-operator`: Approve an operator to manage tokens
- `revoke-operator`: Revoke operator approval

### Admin Functions

- `initialize`: Initialize the contract with treasury address
- `update-fee-rate`: Update the protocol fee rate
- `update-treasury`: Update the treasury address
- `transfer-ownership`: Transfer contract ownership
- `emergency-shutdown`: Halt contract operations in emergency

### Read-Only Functions

- `get-name`: Get token name
- `get-symbol`: Get token symbol
- `get-decimals`: Get token decimals
- `get-total-supply`: Get total token supply
- `get-balance`: Get account balance
- `get-user-deposits`: Get user deposit history
- `is-approved-operator`: Check operator approval status
- `get-fee-rate`: Get current fee rate

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: Unauthorized access attempt
- `ERR-INSUFFICIENT-BALANCE (u101)`: Insufficient token balance
- `ERR-INVALID-AMOUNT (u102)`: Invalid transaction amount
- `ERR-TRANSFER-FAILED (u103)`: Token transfer failure
- `ERR-ALREADY-INITIALIZED (u104)`: Contract already initialized
- `ERR-NOT-INITIALIZED (u105)`: Contract not initialized
- `ERR-INVALID-RECIPIENT (u106)`: Invalid recipient address

## Security Features

1. **Access Control**

   - Owner-only administrative functions
   - Operator approval system
   - Emergency shutdown capability

2. **Transaction Safety**

   - Amount validation
   - Balance checks
   - Transfer restrictions

3. **State Management**
   - Initialization checks
   - Supply tracking
   - Deposit history

## Getting Started

### Prerequisites

- Stacks wallet
- BTC for deposits
- Understanding of wrapped token mechanics

### Usage Example

```clarity
;; Initialize contract
(contract-call? .bitcoin-tokenizer initialize 'SP000000000000000000002Q6VF78)

;; Deposit BTC
(contract-call? .bitcoin-tokenizer deposit-btc u1000000)

;; Transfer wBTC
(contract-call? .bitcoin-tokenizer transfer u500000 tx-sender 'SP456...)

;; Withdraw BTC
(contract-call? .bitcoin-tokenizer withdraw-btc u500000)
```

## Development and Testing

1. Clone the repository
2. Install dependencies
3. Run tests using Clarinet
4. Deploy using Stacks CLI

## License

MIT License - See LICENSE file for details
