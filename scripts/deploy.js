const hre =  require("hardhat");

async function main() {
    const stakingcontract = await hre.ethers.getContractFactory("StakingContract");
    const StakingContract = await stakingcontract.deploy();
    await StakingContract.deployed();

    console.log("Contract deployed to:", StakingContract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});