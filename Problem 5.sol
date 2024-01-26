/* eslint-disable no-undef */
/* eslint-disable jest/valid-expect */
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const web3 = require('web3');

describe("loanservice", function() {

    describe("reqLoan Testing", function() {

        it ("Should check if loan request does not exist", async function() {
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed(); 
            let res = loanservice.reqLoan(17,81712750,3);
            
            await expect(loanservice.reqLoan(17,81712750,3)).to.be.revertedWith("This loan request already exists");
        });

        it ("Should emit event request event if loan request does not exist", async function() {
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed(); 
            
            await expect(loanservice.reqLoan(93,6,9)).to.emit(loanservice,"newLoanRequest").withArgs(1, 93, anyValue, 6, 9, anyValue);
        });

    });

    describe("guaranteeLoan Testing", function() {
        it ("Should check if loan request does exist", async function() {
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed(); 
        
            await expect(loanservice.guaranteeLoan(3,"0xc140BbC18FDc3D5147AB7c23D1301F5aBf1c499B")).to.be.revertedWith("This loan request does not exist");
        });
        

        it ("Should check authenticity of sender", async function() {
            const [owner, otherAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);

            await expect(loanservice.guaranteeLoan(3,owner.address)).to.be.revertedWith("Invalid Request - Borrower cannot access");
        });

        it ("Should check if ethers are not sent along", async function() {
            const [owner, otherAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);

            const val = 93;
            await expect(loanservice.connect(otherAccount).guaranteeLoan(3,owner.address)).to.be.revertedWith("Enter the exact loan amount");
        });

        it ("Should emit sucessfull event", async function() {
            const [owner, otherAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);

            const val = "93";
            await expect(loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")})).to.emit(loanservice,"guaranteeOfferEvent").withArgs(anyValue,3);
        })
    })

    describe("confirmGuarantee Testing", function() {   //Few basic tests repeat

        it ("Should update values if approved", async function(){
            const [owner, otherAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            
            let output_beforeChange = await loanservice.connect(owner).viewLoanRequest(owner.address); 
            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            let output_afterChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            expect(output_beforeChange).to.not.equal(output_afterChange);
        })

        it ("Should not update values if declined", async function() {
            const [owner, otherAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            
            let output_beforeChange = await loanservice.connect(owner).viewLoanRequest(owner.address);            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,false);
            let output_afterChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            expect(output_beforeChange).to.eqls(output_afterChange);
        })
    })

    describe("giveLoan Testing", function() {

        it ("Should check if the ethers are not sent along", async function(){
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            await expect(loanservice.connect(thirdAccount).giveLoan(owner.address)).to.be.revertedWith("Enter the exact loan amount");
        })

        it ("Should update values if lent successfully", async function() {
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";            

            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            let output_beforeChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            let output_afterChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            expect(output_beforeChange).to.not.equal(output_afterChange);
        })

        it ("Should check if the value has been transferred", async function(){
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            let output_beforeChange = ethers.provider.getBalance(owner.address);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            let output_afterChange = ethers.provider.getBalance(owner.address);
            expect(output_beforeChange).to.not.equal(output_afterChange);
        })

    })

    describe("payBackLoan Testing", function(){

        it ("Should delete loan request after complete repayment of loan", async function() {
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).payBackLoan({value: web3.utils.toWei(val, "finney") })
            let intr = "5";
            res = loanservice.connect(owner).payBackLoan({value: web3.utils.toWei(intr, "finney") })
            await expect(loanservice.connect(owner).payBackLoan({value: web3.utils.toWei(val, "finney") })).to.be.revertedWith("This loan request does not exist");
        })

        it ("Should update values if paid partly", async function(){
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            let output_beforeChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            let partialPayBack = "10"
            res = await loanservice.connect(owner).payBackLoan({value: web3.utils.toWei(partialPayBack, "finney") })
            let output_afterChange = await loanservice.connect(owner).viewLoanRequest(owner.address);
            expect(output_beforeChange).to.not.equal(output_afterChange);
        })


    })

    describe("claimGuarantee Testing", function(){

        it("Should check if the loan date has lapsed", async function(){
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.reqLoan(93,1,9);
            const val = "93";
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            
            await expect(loanservice.connect(thirdAccount).claimGuarantee(owner.address)).to.be.revertedWith("Loan Date has not lapsed yet!");
        })

        it("Should let lendor claim the guarantee amount if time lapsed and delete request", async function(){
            const [owner, otherAccount, thirdAccount] = await ethers.getSigners();
            const loanserviceContract = await hre.ethers.getContractFactory("loanservice");
            const loanserviceDeploy = await loanserviceContract.deploy();
            let loanservice = await loanserviceDeploy.deployed();
            let res = await loanservice.connect(owner).reqLoan(93,1,9);
            const val = "93";
            
            res = await loanservice.connect(otherAccount).guaranteeLoan(3,owner.address,{value: web3.utils.toWei(val, "finney")});
            res = await loanservice.connect(owner).confirmGuarantee(otherAccount.address,true);
            res = await loanservice.connect(thirdAccount).giveLoan(owner.address,{value: web3.utils.toWei(val, "finney")});
            const ONE_DAY = 86400;
            let lapseStamp = (await time.latest()) + ONE_DAY;
            
            await time.increaseTo(lapseStamp);
            res = loanservice.connect(thirdAccount).claimGuarantee(owner.address);
            await expect(loanservice.connect(owner).viewLoanRequest(owner.address)).to.be.revertedWith("This loan request does not exist");
        })
    })

});