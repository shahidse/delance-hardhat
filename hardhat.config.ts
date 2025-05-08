import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const { vars } = require("hardhat/config");
const TEST_API_KEY = vars.get("TEST_API_KEY");
const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545", // Ganache default
    },
    hardhat: {
      chainId: 1337,
      accounts: {
        count: 10,
        accountsBalance: "10000000000000000000000",
      },
    },
    // ganache: {
    //   url: "http://127.0.0.1:7545", // Ganache default
    //   accounts: [TEST_API_KEY], // Use a Ganache test account private key
    // },
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v6",
  },
  
};

export default config;
