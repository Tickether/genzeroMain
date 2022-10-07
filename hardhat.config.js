require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")
const dotenv = require("dotenv")

dotenv.config();

module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    mainnet: {
      url: process.env.REACT_APP_MAINNET_RPC_URL,
      accounts: [process.env.REACT_APP_PROD_PRIVATE_KEY],
      blockGasLimit: 2400000
    },
    goerli: {
      url: process.env.REACT_APP_GOERLI_RPC_URL,
      accounts: [process.env.REACT_APP_PRIVATE_KEY],
      blockGasLimit: 2400000
    },
  },
  etherscan: {
    apiKey: process.env.REACT_APP_ETHERSCAN_KEY
  }
};