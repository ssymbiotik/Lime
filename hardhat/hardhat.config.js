require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.28",
  networks: {
    devnet: {
      url: "http://localhost:8545",
      accounts: [
        "0x4d5db4107d237df6a3d58ee5f70ae63d73d7658d4026f2eefd2f204c81682cb7", // Default Hardhat account
      ],
    },
  },
};
