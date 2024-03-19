# Housing Community DAO

Our project aims to establish a decentralized housing community organization using a Decentralized Autonomous Organization (DAO). This DAO encourages member participation by combining a sophisticated voting system with rewarding incentives. In our DAO, members can deposit Ether to receive voting tokens, which are linked to their contribution. These tokens, following the ERC20 standard, allow members to participate in important community decisions, with the impact of each vote depending on the number of tokens held. Our system is designed to foster continuous engagement among community members. Each time a member casts a vote, they earn a unique participation token, compliant with the ERC20 standard. This mechanism encourages sustained involvement in community governance. These participation tokens can then be used to redeem incentives for exclusive community amenities, including Gym Membership, Pool Access, and Parking Facilities. These privileges are represented by Non-Fungible Tokens (NFTs) adhering to the ERC721 standard. This innovative reward system is designed to enrich the overall
living experience within the community, nurturing a vibrant and interconnected environment.

## Architecture
![Architecture](https://github.com/arushi297/Blockchain-and-Crypto-DAO-impl/blob/main/images/DAO_Architecture.png)

## Instructions to Deploy the Smart Contracts

1. Open [Remix](https://remix.ethereum.org/). Deploy and verify `GymMembershipNFT`, `PoolAccessNFT`, `ParkingPassNFT`, `VoteToken`, `ParticipationToken` and `GameEmporium` solidity contract first. Solidity is a statically typed programming language and you must compile the code before deploying the smart contract.
2. Next deploy the `CommunityIncentives` solidity smart contract. Copy and paste the addresses of the `GymMembershipNFT`, `PoolAccessNFT` and `ParkingPassNFT` into the `CommunityIncentives` constructor to make sure that the deployment happens successfully.
   
   ![CommunityIncentivesDeployment](https://github.com/arushi297/Blockchain-and-Crypto-DAO-impl/blob/main/images/CommunityIncentivesDeployment.png)
   
4. To depoly the `HousingCommunityDAO`, copy and paste the addresses of `GameEmporium`, `CommunityIncentives`, `VoteToken` and `ParticipationToken` smart contract into the `HousingCommunityDAO` constructor.

   ![HousingCommunityDAODeployment](https://github.com/arushi297/Blockchain-and-Crypto-DAO-impl/blob/main/images/HousingCommunityDAODeployment.png)
   
6. Add in names of proposals: ["Pool Table", "Table Tennis Table", "Foosball Table"]
7. Transfer ownership of all the NFTs to `CommunityIncentives` and that of ERC20 Tokens to `HousingCommunityDAO`.

## Instructions to Run the HousingCommunityDAO 

1. Only DAO Owner can start the Voting Period
2. Voters should Deposit Ether to get Voting Rights. For every Participation they will receive a Participation Token
3. After depositing Ether, Voters should submit their Vote towards a Proposal choice
4. Voters can use the Participation Tokens accumulated to redeem incentives
5. Once they redeem an incentive, they will receive NFT corresponding to the incentive which they can import to their wallet by providing NFT contract address and tokenID (Can be checked in `CommunityIncentives`)
6. Once the voting period ends, DAO Owner can count votes to get the Majority Voted Decision
7. After counting votes, owner can End Vote to make the purchase. This will transfer Ether from HousingCommunityDAO to GameEmporium while the item ownership is transferred to the DAO.

For detailed execution, please refer to the video: [link](https://youtu.be/ThCUuC\_xw0s?feature=shared)

## Etherscan Links:

1. HousingCommunityDAO: [link](https://sepolia.etherscan.io/address/0x3903d4e7000687e2b43b7c73bba231f9e21aaace#code)
2. GameEmporium: [link](https://sepolia.etherscan.io/address/0xbf34dee1297c846541021f215a91d537f3f20822#code)
3. CommunityIncentives: [link](https://sepolia.etherscan.io/address/0xe17ee6d9fb7e5384ea1f9fa11f73c99ff4aa3f7c#code)
4. VoteToken: [link](https://sepolia.etherscan.io/address/0xfcf40be5d0b7c2b32cc572146c54d44df08aa0d1#code)
5. ParticipationToken: [link](https://sepolia.etherscan.io/address/0x150ea0948319ff7d4da77e028a6da03b5004288c#code)
6. GymMembershipNFT: [link](https://sepolia.etherscan.io/address/0x238604e0f6cff0d71805d3267cb92ce8724cf25b#code)
7. PoolAccessNFT: [link](https://sepolia.etherscan.io/address/0xd6f16369592d8b559505852cb6d1d7dda874f00f#code)
8. ParkingPassNFT: [link](https://sepolia.etherscan.io/address/0x6faff2831a447d4eb48c5e3adcda919609ce95fd#code)
