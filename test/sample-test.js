const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("GalaxChatProtocol");
    const greeter = await Greeter.deploy();
    await greeter.deployed();
    const accounts = await ethers.getSigners();

    const registerTx = await greeter.register(123);

    // wait until the transaction is mined
    await registerTx.wait();
    const result = await greeter.dhKey(accounts[0].address);
    console.log(result);
  });
});
