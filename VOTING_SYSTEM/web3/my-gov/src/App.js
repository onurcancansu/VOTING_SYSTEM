
import './App.css';
import { ethers } from 'ethers';
import contractABI from './MyGovABI.json';

// Define the contract address
const contractAddress = '0x9dAEdDC2B475015717145E824dE277bfd05f82c7';

// Create a new Web3Provider object and connect to the ethereum object in the browser window
let provider = new ethers.providers.Web3Provider(window.ethereum);

// Create a new contract object using the contract address, the contract ABI, and the provider
let contract = new ethers.Contract(contractAddress, contractABI, provider);

// Declare a signer variable that will be used later on
let signer;

// Define the connect function
const connect = async () => {
  // Send a request to the ethereum object in the browser window to access the user's accounts
  await provider.send("eth_requestAccounts", []);

  // Set the signer variable to the signer object returned by the provider
  signer = provider.getSigner();

  // Create a new contract object using the signer object and the same contract address and ABI as before
  contract = new ethers.Contract(contractAddress, contractABI, signer);

  // Get the address of the user and store it in the userAddress variable
  const userAddress = await signer.getAddress();
}

// Define the donate function
const donate = async () => {
  // Get the user input for the donation amount
  let userAmount = document.getElementById('donate').value;

  // Convert the user input amount to wei
  const weiAmount = ethers.utils.parseEther(userAmount);

  // Send a transaction to the contract to call the donate function and include the wei amount as the value
  const tx = await contract.donate({ value: weiAmount });

  // Wait for the receipt of the transaction to confirm that it was mined
  const receipt = await tx.wait();
}

// Define the DonateMyGov function
const DonateMyGov = async () => {
  // Get the user input for the donation amount
  let userAmount = document.getElementById('donateMGV').value;

  // Convert the user input amount to wei
  const weiAmount = ethers.utils.parseEther(userAmount);

  // Send a transaction to the contract to call the DonateMyGov function and include the wei amount as the value
  const tx = await contract.DonateMyGov({ value: weiAmount });

  // Wait for the receipt of the transaction to confirm that it was mined
  const receipt = await tx.wait();
}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1><span className='blue'>My</span>Gov</h1>
        {/* MyGov header */}
        <p>
          Blockchain Voting
        </p>
        <div className='App-body'>
          {/* container for buttons */}
          <div className='App-button'>
            <button onClick={connect}>CONNECT</button>
          </div>
          {/* Donate Ether button */}
          <div className='App-button'>
            <input type="text" id="donate" placeholder="ETH"/>
            <button id="donate">DonateEther</button>
          </div>
          {/* Donate MyGov Token button */}
          <div className='App-button'>
            <input type="text" id="donateMGV" placeholder="MGV"/>
            <button id="donate">DonateMyGov</button>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App;

