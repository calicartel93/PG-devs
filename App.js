import React, {useEffect, useState} from 'react';
import './styles/App.css';
import {ethers} from "ethers";
import contractAbi from "./utils/contractABI.json";
import polygonLogo from "./assets/polygonlogo.png";
import ethLogo from "./assets/ethlogo.png";
import {networks} from "./utils/networks";


const loanserviceContractAddress = '0xCD759aEE5e60A14F41576e3891C4924ED8472015';
const abi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "guarantor",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "confirm",
				"type": "bool"
			}
		],
		"name": "confirmGuarenteeEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "interestLimit",
				"type": "uint256"
			}
		],
		"name": "guaranteeOfferEvent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanNum",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "loanAmt",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "reqDate",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "lapseDate",
				"type": "uint256"
			}
		],
		"name": "newLoanReq",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "borrowers",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "borrowerAddress",
				"type": "address"
			}
		],
		"name": "claimGuarantee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "guarantor",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "confirm",
				"type": "bool"
			}
		],
		"name": "confirmGuarantee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "borrowerAddress",
				"type": "address"
			}
		],
		"name": "giveLoan",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "interestLimit",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			}
		],
		"name": "guaranteeLoan",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "guaranteeOffers",
		"outputs": [
			{
				"internalType": "address payable",
				"name": "guarantor",
				"type": "address"
			},
			{
				"internalType": "address payable",
				"name": "borrower",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "loanAmt",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interestLimit",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "loanNum",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "loanRequests",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "loanID",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "loanAmt",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"internalType": "address payable",
				"name": "lendor",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "lendorInterest",
				"type": "uint256"
			},
			{
				"internalType": "address payable",
				"name": "borrower",
				"type": "address"
			},
			{
				"internalType": "address payable",
				"name": "guarantor",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "guaranteed",
				"type": "bool"
			},
			{
				"internalType": "uint256",
				"name": "interestPaid",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "reqDate",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "lapseDate",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "receiveLoan",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "loanAmt",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "lapseDate",
				"type": "uint256"
			}
		],
		"name": "reqLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "borrowerAddress",
				"type": "address"
			}
		],
		"name": "viewLoanRequest",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "loanID",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "loanAmt",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "interest",
						"type": "uint256"
					},
					{
						"internalType": "address payable",
						"name": "lendor",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "lendorInterest",
						"type": "uint256"
					},
					{
						"internalType": "address payable",
						"name": "borrower",
						"type": "address"
					},
					{
						"internalType": "address payable",
						"name": "guarantor",
						"type": "address"
					},
					{
						"internalType": "bool",
						"name": "guaranteed",
						"type": "bool"
					},
					{
						"internalType": "uint256",
						"name": "interestPaid",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "reqDate",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "lapseDate",
						"type": "uint256"
					}
				],
				"internalType": "struct loanservice.requestLoan",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
const App = () => {		//Set values for variables
	const [loanAmount, setLoanAmount] = useState('');
	const [lapseDate, setLapseDate] = useState('');
	const [interest, setInterest] = useState('');
	const [guarantorInterest, setGuarantorInterest] = useState('');
	const [guarantorAddress, setGuarantorAddress] = useState('');
	const [approve, setApprove] = useState(false);
	const [borrower, setBorrower] = useState('');
	const [payBackValue, setPayBackValue] = useState('');
	const [borrowerAddress, setBorrowerAddress] = useState('');
 	const [currentAccount, setCurrentAccount] = useState('');
	const [network, setNetwork] = useState('');
	const [loanRequests, setLoanRequests] = useState([]);
	
	//Pre Requisites - Wallet connection and check 
	const connectWallet = async() => {
		try{
			const{ethereum} = window;
			if(!ethereum) {
				alert("Install MetaMask -- https://metamask.io/");
				return;
			}
			const accounts = await ethereum.request({method: 'eth_requestAccounts'});
			console.log("Connected to - ",accounts[0]);
			setCurrentAccount(accounts[0]);
		}catch(err){
			console.log("!Error!-",err);
		}
	}

	const checkWalletConnected = async ()=> {
		const{ethereum} = window;

		if(!ethereum) {
			console.log ("Install metamask first!");
			return;
		}
		else{
			console.log ("Available ethereum object - ", ethereum);
		}

		const accounts = await ethereum.request({method: 'eth_accounts'});
		if (accounts.length !== 0) {
			const account = accounts[0];
			console.log('Authorized account found - ', account);
			setCurrentAccount (account);
		} else {
			console.log('No authorized account found');
		}

		const chainId = await ethereum.request({method: 'eth_chainId'});
		setNetwork(networks[chainId]);
		ethereum.on('Chain Changed', handleChainChanged);
		function handleChainChanged(_chainId) {
			window.location.reload();
		}
	}
	
	const renderNotConnected = () => (
		<div className="connect-wallet-container">
				<button onClick = {connectWallet} className = "cta-button connect-wallet-button" >
					Connect Wallet
				</button>
    	</div>
	);

	// Utility function to Parse loanRequest Mapping to Readable format
	const parseRequest = (request, param) => {
		return String(request[param]);
	}
	
	// Smart Contract Functions 
	const reqLoan = async () => {
		try {
			const {ethereum} = window;
			console.log();
			if(ethereum) {
				const provider = new ethers.providers.Web3Provider(ethereum);
				const signer = provider.getSigner();
				console.log('Signer', signer);
				const contract = new ethers.Contract(loanserviceContractAddress, abi, signer);
				console.log('Address',contract.address);
				let tx = await contract.reqLoan(0.25*1000, 1, 0.01*1000);
				console.log('dfbdkjfnk');
				const receipt = await tx.wait();
				
				if(receipt.status === 1){
					console.log("Loan Request registered! https://mumbai.polygonscan.com/tx/"+tx.hash);	
				}
				else{
					alert("Transaction failed!");
				}
			}
		} catch (error) {
			console.log("ERROR!"+error);
		}
	}

	const guaranteeLoan = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
			console.log('Address',contract.address);
			let tx = await contract.guaranteeLoan(guarantorInterest*1000, borrower, {value: ethers.utils.parseEther(loanAmount)});
			const receipt = await tx.wait();
			if(receipt.status === 1){
				console.log("Loan request guaranteed! https://mumbai.polygonscan.com/tx/"+tx.hash);
			}
			else{
				alert("Transaction failed!");
			}
		  }
		} catch (error) {
		  console.log (error);
		}
	}

	const confirmGuarantee = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
			
			let tx = await contract.confirmGuarantee(guarantorAddress, approve);
			const receipt = await tx.wait();
			if (receipt.status === 1){
				console.log("Guarantee status updated! https://mumbai.polygonscan.com/tx/"+tx.hash);
			}
			else {
				alert("Transaction failed!");
			}
		  }
		} catch (error) {
		  console.log (error);
		}
	}

	const giveLoan = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
			
			let tx = await contract.giveLoan(borrowerAddress,{value: ethers.utils.parseEther(loanAmount)});
			const receipt = await tx.wait();
			if(receipt.status === 1){
				console.log("Loan transferred! https://mumbai.polygonscan.com/tx/"+tx.hash);
			}
			else{
				alert("Transaction failed!");
			}
		  }
		} catch (error){
		  console.log (error);
		}
	}

	const receiveLoan = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
			
			let tx = await contract.receiveLoan({value: ethers.utils.parseEther(payBackValue)});
			const receipt = await tx.wait();
			if (receipt.status === 1){
				console.log("Loan Payment Successful! https://mumbai.polygonscan.com/tx/"+tx.hash);
			}
			else {
				alert("Transaction failed!");
			}
		  }
		} catch(error){
		  console.log(error);
		}
	}

	const claimGuarantee = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
			
			let tx = await contract.claimGuarantee(borrowerAddress);
			const receipt = await tx.wait();
			if(receipt.status === 1){
				console.log("Successful Guarantee! https://mumbai.polygonscan.com/tx/"+tx.hash);
			}
			else{
				alert("Guarantee failed!");
			}
		  }
		} catch(error){
		  console.log(error);
		}
	}
	
	//Fetch the loan requests from chain
	const fetchLoanRequests = async () => {
		try {
		  const { ethereum } = window;
		  if (ethereum) {
			// You know all this
			const provider = new ethers.providers.Web3Provider(ethereum);
			const signer = provider.getSigner();
			const contract = new ethers.Contract(loanserviceContractAddress, contractAbi.abi, signer);
	
			const reqs = await contract.viewAllLoanRequests();
			setLoanRequests(reqs);			
		  }
		} catch(error){
		  console.log(error);
		}
	}

	//Input form for params
	const renderInputForm = () => {
		if (network !== 'Polygon Mumbai Testnet') {
			return (
			<div className="connect-wallet-container">
				<p>Please switch to the Polygon Mumbai Testnet</p>
				<button className='cta-button mint-button' onClick={switchNetwork}>Click here to switch</button>
			</div>
			);
		}
		return(
			<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={loanAmount}
						placeholder='Enter Loan Amount (Will be calculated as finney) '
						onChange={e => setLoanAmount(e.target.value)}
					/>
					<input
						type="text"
						value={interest}
						placeholder='Enter Interest'
						onChange={e => setInterest(e.target.value)}
					/>
					<input
						type="text"
						value={lapseDate}
						placeholder='Enter loan repayment date in no of days format'
						onChange={e => setLapseDate(e.target.value)}
					/>
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={reqLoan}>
					reqLoan
					</button>  
				</div>
				
				<div>
					<button className='cta-button mint-button' onClick={fetchLoanRequests}>
					viewLoanRequests
					</button>  
				</div>
				{/* <div>
				<h2>Loan Requests</h2>
					<table className="card">
					<thead>
						<tr>
						<th>Address</th>
						<th>Loan Amount (finney)</th>
						<th>Interest</th>
						<th>Is guaranteed</th>
						<th>Lendor Interest</th>
						</tr>
					</thead>
					<tbody>
						{loanRequests.map((req) => {
						return(
							<tr key={parseRequest(req, 5)}>
							<td>{parseRequest(req, 5)}</td>
							<td>{parseRequest(req, 0)}</td>
							<td>{parseRequest(req, 3)}</td>
							<td>{parseRequest(req, 8)}</td>
							<td>{parseRequest(req, 7)}</td>
							</tr>
						);
						})}
					</tbody>
					</table>
				</div> */}

				<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={guarantorInterest}
						placeholder='Enter Guarantor Interest Cut off'
						onChange={e => setGuarantorInterest(e.target.value)}
					/>
					<input
						type="text"
						value={borrower}
						placeholder='Enter borrowerAddress'
						onChange={e => setBorrower(e.target.value)}
					/>
					
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={guaranteeLoan}>
					guaranteeLoan
					</button>  
				</div>

				<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={guarantorAddress}
						placeholder='Enter Guarantor Address of guarantee'
						onChange={e => setGuarantorAddress(e.target.value)}
					/>
					<input
						type="text"
						value={approve}
						placeholder='Enter approval true or false'
						onChange={e => setApprove(e.target.value)}
					/>
					
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={confirmGuarantee}>
					confirmGuarantee
					</button>  
				</div>
					
				<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={borrowerAddress}
						placeholder='Enter borrower address'
						onChange={e => setBorrowerAddress(e.target.value)}
					/>
					
					
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={giveLoan}>
					giveLoan
					</button>  
				</div>
				</div>
				<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={payBackValue}
						placeholder='Enter Pay Back amount '
						onChange={e => setPayBackValue(e.target.value)}
					/>
					
					
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={receiveLoan}>
					receiveLoan
					</button>  
				</div>
				</div>

				<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={borrowerAddress}
						placeholder='Enter borrower address'
						onChange={e => setBorrowerAddress(e.target.value)}
					/>
					
					
					
				</div>
				<div>
					<button className='cta-button mint-button'  onClick={claimGuarantee}>
					claimGuarantee
					</button>  
				</div>
				</div>
				

			</div>
				

			</div>
			</div>

		);
	}

	//Switch to polygon mumbai network
	const switchNetwork = async () => {
		if (window.ethereum) {
		  try {
			// Try to switch to the Mumbai testnet
			await window.ethereum.request({
			  method: 'wallet_switchEthereumChain',
			  params: [{ chainId: '0x13881' }], // Check networks.js for hexadecimal network ids
			});
		  } catch (error) {
			// This error code refers to the chain not being added to MetaMask
			// In this case we ask the user to add it to their MetaMask
			if (error.code === 4902) {
			  try {
				await window.ethereum.request({
				  method: 'wallet_addEthereumChain',
				  params: [
					{	
					  chainId: '0x13881',
					  chainName: 'Polygon Mumbai Testnet',
					  rpcUrls: ['https://rpc-mumbai.maticvigil.com/'],
					  nativeCurrency: {
						  name: "Mumbai Matic",
						  symbol: "MATIC",
						  decimals: 18
					  },
					  blockExplorerUrls: ["https://mumbai.polygonscan.com/"]
					},
				  ],
				});
			  } catch (error) {
				console.log(error);
			  }
			}
			console.log(error);
		  }
		} else {
		  // If window.ethereum is not found then MetaMask is not installed
		  alert('MetaMask is not installed. Please install it to use this app: https://metamask.io/download.html');
		} 
	}

	useEffect(()=> {
		checkWalletConnected();
	},[]);

	return(
		<div className="App">
				<div className="container">

					<div className="header-container">
						<header>
							<div className="left">
								<p className="title">peer-to-peer Loan Service</p>
								<p className="subtitle">DLT5401 Assignment</p>

							</div>
							<div className="right">
      							<img alt="Network logo" className="logo" src={ network.includes("Polygon") ? polygonLogo : ethLogo} />
      							{ currentAccount ? <p> Wallet: {currentAccount.slice(0, 6)}...{currentAccount.slice(-4)} </p> : <p> Not connected </p> }
    						</div>
						</header>
					</div>

					{!currentAccount && renderNotConnected()}
					{currentAccount && renderInputForm()}
				</div>
			</div>
	)
}
export default App;