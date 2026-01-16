# YUMO Contract

## About YUMO

YUMO is **The AI Behavior Foundation for Web3** built on Binance Smart Chain (BSC). This project aims to bridge AI-driven behaviors with decentralized applications, creating a foundation for intelligent Web3 interactions.

## Smart Contract Overview

The `YUMOController` contract provides core functionalities for the YUMO ecosystem:

### Features

- **Daily Sign-In System**: Users can sign in once per day to participate in the YUMO ecosystem
- **Project Funding Mechanism**: Support Web3 projects by contributing USDT tokens
- **Secure Operations**: Built with ReentrancyGuard protection and owner-controlled functions

### Contract Details

- **Network**: BSC (Binance Smart Chain)
- **Solidity Version**: ^0.8.30
- **Token Used**: USDT (0x55d398326f99059fF775485246999027B3197955)
- **License**: MIT

## Main Functions

### `sign()`
Allows users to sign in once per day. Each sign-in is recorded with the user's address and timestamp.

### `projectUsdt(string id, uint256 _usdtAmt)`
Enables funding for Web3 projects using USDT:
- Minimum funding: 1 USDT
- Each project ID can only be funded once
- USDT is transferred to the designated receiver address

### `setReciver(address _receiveAddr)` (Owner Only)
Updates the address that receives USDT from project funding.

### `rescueToken(address tokenAddress, uint256 tokens)` (Owner Only)
Emergency function to rescue tokens from the contract.

## Contract Address

Verified on BscScan: [View on BscScan](https://bscscan.com/)

## Security

- Implements OpenZeppelin's Ownable pattern for access control
- Uses ReentrancyGuard to prevent reentrancy attacks
- Safe token transfer operations via TransferHelper library

## License

This project is licensed under the MIT License.
