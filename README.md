# Token Stacking Dapp

This is a contract that gives rewards to anyone who stakes their token after a certain time.

Technologies: HardHat • Solidity • Github •

The contract has
Staking and Rewards: Users can stake tokens, earn rewards over time, and claim these rewards. The rewards are calculated based on the Annual Percentage Yield (APY) rate and the duration of the stake.

Initialization and Configuration: The contract is initialized with parameters like the token address, APY rate, stake amount limits, and stake period. Only the owner can update these settings.

Early Unstake Fee: An early unstake fee is applied if users unstake before the staking period ends. This fee is a percentage of the unstaked amount.

Security and Reentrancy Protection: The contract includes reentrancy guards to prevent reentrancy attacks and ensure secure fund handling.

Pause and Resume Staking: The owner can pause and resume staking activities, providing control over the staking process during maintenance or updates.

Event Logging and User Tracking: Events like staking, unstaking, reward claiming, and early unstake fees are logged. The contract tracks user details, including stake amounts, reward amounts, and staking times.
