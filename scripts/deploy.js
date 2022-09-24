
const hre = require("hardhat");

async function main() {

  const url = 'https://bafybeid4fexmtcvo2nunf5xhrrdkozpc55tvjnfmscjlhsclyzaxue5hne.ipfs.nftstorage.link/';

  const Gen = await hre.ethers.getContractFactory("Gen");
  const gen = await Gen.deploy(url);

  await gen.deployed();

  console.log("Gen deployed to:", gen.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
