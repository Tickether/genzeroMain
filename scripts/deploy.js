
const hre = require("hardhat");

async function main() {

  //const url = 'https://bafybeid4fexmtcvo2nunf5xhrrdkozpc55tvjnfmscjlhsclyzaxue5hne.ipfs.nftstorage.link/';

  const GenZero = await hre.ethers.getContractFactory("GenZero");
  const genzero = await GenZero.deploy();

  await genzero.deployed();

  console.log("GenZero deployed to:", genzero.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
