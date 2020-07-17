// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const PUZZLE_ADDRESS = "0x7c2C195CD6D34B8F845992d380aADB2730bB9C6F";
const AUTHOR_ADDRESS = "0xd724F56547F65D82D8026A695c2e341E2c864Cc0";

async function main() {
  // This is just a convenience check
  if (network.name === "buidlerevm") {
    console.warn(
      "You are trying to deploy a contract to the Buidler EVM network, which" +
        "gets automatically created and destroyed every time. Use the Buidler" +
        " option '--network localhost'"
    );
  }

  // ethers is avaialble in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const fs = require("fs");
  const contractsDir = __dirname + "/../frontend/src/contracts";

  const Solution = await ethers.getContractFactory("Solution");
  const solution = await Solution.deploy(PUZZLE_ADDRESS, AUTHOR_ADDRESS);
  await solution.deployed();

  console.log("Solution address:", solution.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(solution);
}

function saveFrontendFiles(solution) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../frontend/src/contracts";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  const addresses = JSON.parse(fs.readFileSync(contractsDir + "/contract-address.json"));
  addresses["Solution"] = solution.address;
  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify(addresses, undefined, 2)
  );

  fs.copyFileSync(
    __dirname + "/../artifacts/Solution.json",
    contractsDir + "/Solution.json"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
