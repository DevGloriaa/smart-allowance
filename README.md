# Smart Allowance

A Solidity smart contract for *self-discipline budgeting* and *children allowance*.  
It allows funders (parents or individuals) to deposit stablecoins and release them automatically to beneficiaries based on a *time-based schedule*.

---


## Features

- *Self-Discipline Budgeting*: Restrict your own spending by setting daily/weekly allowance.
- *Children Allowance*: Parents can automate allowance payments to children.
- *Time-Based Release*: Funds can only be claimed after the specified interval (daily, weekly, etc.).
- *Token Support*: Works with ERC-20 stablecoins (e.g., USDT, USDC, DAI).

---

## How It Works

1. *Create Plan*
   - Fund your plan using createPlan(beneficiary, totalAmount, allowancePerInterval, interval).
   - beneficiary can be yourself or a child.
   - interval is in seconds (1 day = 86400, 1 week = 604800).

2. *Claim Allowance*
   - Beneficiaries call claimAllowance() to withdraw the allowed amount.
   - The contract enforces the schedule automatically.

3. *View Plan Details*
   - Anyone can call getPlanDetails(address beneficiary) to see plan information:
     - Funder, total funded, allowance per interval, last claimed, remaining balance.

---

## Example Use Cases

- Self-discipline budgeting (daily spending limit)
- Automated children allowance
- Employee stipend automation
- Personal savings lock

---

## Workflow Diagram

AllowanceBudget smart contract flow:

Funder (Parent / Self) 💰

        │
        │ createPlan(totalAmount, allowancePerInterval, interval)
        ▼
Smart Contract ⛓

        │
        │ Stores allowance plan and enforces schedule
        ▼
Beneficiary (Child / Self) 👶 / 🧑

        │
        │ claimAllowance()
        ▼
Funds Released 💵 → Wallet


## How Funds Flow

1️⃣ *Funder deposits* funds into the contract  
2️⃣ *Contract locks* the funds and sets the schedule  
3️⃣ *Beneficiary waits* for the interval to pass  
4️⃣ *Beneficiary claims* allowance via claimAllowance()  
5️⃣ *Contract updates* remaining balance and last claimed time  
6️⃣ Repeat until funds are exhausted

---

## Getting Started

1. Open [Remix IDE](https://remix.ethereum.org)  
2. Create a new file AllowanceBudget.sol and paste the contract code.  
3. Compile using Solidity version 0.8.20.  
4. Deploy to:
   - *Remix VM (Local Testing)* or  
   - *Ethereum Testnet* (like Sepolia or Goerli using MetaMask).  
5. Use a test ERC-20 token (USDT/DAI) to fund and claim allowances.

---

## License

This project is licensed under the MIT License.
