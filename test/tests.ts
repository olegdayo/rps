const { anyValue } = "@nomicfoundation/hardhat-chai-matchers/withArgs";
const { expect } = require("chai")
const { ethers } = require("hardhat")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")

describe(
    "Other",
    function () {
        let firstPlayer;
        let secondPlayer;
        let rps;
        let ext;

        beforeEach(
            async function () {
                [firstPlayer, secondPlayer] = await ethers.getSigners();

                const RPS = await ethers.getContractFactory("rps", firstPlayer);
                const Ext = await ethers.getContractFactory("ext", firstPlayer);

                rps = await RPS.deploy();
                ext = await Ext.deploy();

                await rps.deployed();
                await ext.deployed();
            }
        )

        it(
            "Start stage check",
            async function () {
                await rps.connect(firstPlayer).newGame();
                await ext.connect(firstPlayer).eGetStage(rps.address);

                console.log(`Current stage: ${await rps.currentPhase()}`);

                expect(
                    await ext.ans(),
                ).to.eq(
                    await rps.currentPhase(),
                );
            }
        )

        it(
            "Next stage check",
            async function () {
                await rps.connect(firstPlayer).newGame();
                await rps.connect(firstPlayer).registration();
                await rps.connect(secondPlayer).registration();
                await ext.connect(firstPlayer).eGetStage(rps.address);

                console.log(`Current stage: ${await rps.currentPhase()}`);

                expect(
                    await ext.ans(),
                ).to.eq(
                    await rps.currentPhase(),
                );
            }
        )
    }
)
