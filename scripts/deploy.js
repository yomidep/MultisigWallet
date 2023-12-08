// scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
  const MultiSig = await ethers.getContractFactory("multiSig");
  const multiSig = await MultiSig.deploy(
    // Add the initial parameters for the constructor here
    // For example, [owner1, owner2], confirmationsRequired
    ["0xe9b34E87386b5fA5E611c947730D88E773d2DBb0", "0x7cF219bDb0717a6caEfe7c4975870c3389012507"],
    2  // Confirmations required
  );

  await multiSig.waitForDeployment();



  console.log("multiSig contract deployed to:", await multiSig.getAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
