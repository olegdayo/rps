const { anyValue } = "@nomicfoundation/hardhat-chai-matchers/withArgs";
const { expect } = require("chai")
const { ethers } = require("hardhat")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")

describe(
    "Other",
    function () {
        let acc;
        let rps;
        let ext;

        beforeEach(
            async function () {
                [acc] = await ethers.getSigners();

                const RPS = await ethers.getContractFactory("rps", acc);
                const Ext = await ethers.getContractFactory("ext", acc);

                rps = await RPS.deploy();
                ext = await Ext.deploy();

                await rps.deployed();
                await ext.deployed();
            }
        )

        it(
            "Checks that stage is received right",
            async function () {
                await ext.connect(acc).eGetStage(rps.address);

                expect(
                    await ext.ans(),
                ).to.eq(
                    await rps.currentPhase(),
                );
            }
        )
    }
)
