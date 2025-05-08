const hre = require("hardhat");

async function main() {
    const signers = await hre.ethers.getSigners();

    const deployer = signers[0];
    const freelancer = signers[1]; // fallback to same account

    console.log("Deploying contract with:", deployer.address);
    console.log("Freelancer address:", freelancer.address);

    const Delance = await hre.ethers.getContractFactory("Delance");
    const delance = await Delance.deploy(freelancer.address, {
        value: hre.ethers.parseEther("1"),
    });

    await delance.waitForDeployment();

    console.log("Delance deployed to:", await delance.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});