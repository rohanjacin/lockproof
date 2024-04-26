//require("@nomicfoundation/hardhat-toolbox");
//require("@nomicfoundation/hardhat-ignition-ethers");
require("hardhat-circom");

/** @type import('hardhat/config').HardhatUserConfig */


module.exports = {
  solidity: "0.8.24",

  circom: {
    inputBasePath: "./circuits",
    ptau: "https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau",
    circuits: [
      {
        name: "lockproof",
        // No protocol, so it defaults to groth16
      },
    ],
  },

};
