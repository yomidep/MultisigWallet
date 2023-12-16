const { expect } = require("chai");
const { ethers } = require("hardhat");

describe('multisig Contract', function() {
    let multisig;
    let deployeradd;
    let account1;
    let account2;

    

    beforeEach(async () => {
        const [deployer, acc1, acc2] = await ethers.getSigners();

        deployeradd = deployer.address;
        account1 = acc1.address;
        account2 = acc2.address;

        Multisig = await ethers.getContractFactory('multiSig'); // Update contract name
        multisig = await Multisig.deploy([account1, account2], 2);
        await multisig.waitForDeployment();
    });

    it('should deploy to an address', async () => {
        expect(await multisig.getAddress()).to.not.be.null;
        expect(await multisig.getAddress()).to.be.a('string');
    });

    it("set account1 and account2 as owners, confirmations should also be 2", async () => {
        expect(await multisig.getOwners()).to.deep.equal([account1, account2]);
        expect(await multisig.confirmationsRequired()).to.be.equal(2);
    });
});
