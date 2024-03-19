# Housing Community DAO

## Architecture
![Architecture](https://github.com/arushi297/Blockchain-and-Crypto-DAO-impl/blob/main/DAO_Architecture.png)

## Instructions to Deploy the Smart Contracts

1. Open [Remix](https://remix.ethereum.org/). Deploy and verify `GymMembershipNFT`, `PoolAccessNFT`, `ParkingPassNFT`, `VoteToken`, `ParticipationToken` and `GameEmporium` solidity contract first. Solidity is a statically typed programming language and you must compile the code before deploying the smart contract.
2. Next deploy the `CommunityIncentives` solidity smart contract. Copy and paste the addresses of the `GymMembershipNFT`, `PoolAccessNFT` and `ParkingPassNFT` into the `CommunityIncentives` constructor to make sure that the deployment happens successfully.
3. To depoly the `HousingCommunityDAO`, copy and paste the addresses of `GameEmporium`, `CommunityIncentives`, `VoteToken` and `ParticipationToken` smart contract into the `HousingCommunityDAO` constructor.
4. Add in names of proposals: ["Pool Table", "Table Tennis Table", "Foosball Table"]
5. Transfer ownership of all the NFTs to `CommunityIncentives` and that of ERC20 Tokens to `HousingCommunityDAO`.

## Instructions to Run the HousingCommunityDAO 

1. Only DAO Owner can start the Voting Period
2. Voters should Deposit Ether to get Voting Rights. For every Participation they will receive a Participation Token
3. After depositing Ether, Voters should submit their Vote towards a Proposal choice
4. Voters can use the Participation Tokens accumulated to redeem incentives
5. Once they redeem an incentive, they will receive NFT corresponding to the incentive which they can import to their wallet by providing NFT contract address and tokenID (Can be checked in `CommunityIncentives`)
6. Once the voting period ends, DAO Owner can count votes to get the Majority Voted Decision
7. After counting votes, owner can End Vote to make the purchase. This will transfer Ether from HousingCommunityDAO to GameEmporium while the item ownership is transferred to the DAO.

For detailed execution, please refer to the video: [link](https://youtu.be/ThCUuC\_xw0s?feature=shared)
