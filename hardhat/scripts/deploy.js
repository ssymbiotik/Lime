const hre = require("hardhat");

async function main() {
  // Define the unlock time (e.g., 1 hour from now)
  const unlockTime = Math.floor(Date.now() / 1000) + 3600; // Current time + 1 hour

  // Deploy the Lock contract
  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: hre.ethers.parseEther("0.01") });

  // Wait for the deployment transaction to be confirmed
  await lock.waitForDeployment();

  // Get the contract address
  const contractAddress = await lock.getAddress();

  console.log("Lock contract deployed to:", contractAddress);
  console.log("Unlock time:", unlockTime);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
