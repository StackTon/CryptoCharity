import React, { Component } from 'react';
import Input from '../common/Input';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import { contractAddress } from '../../api/remote';



export default class DonatePage extends Component {
    constructor(props) {
        super(props);

        this.state = {
            web3: null,
            contractBalance: 0,
            personVotePower: 0,
            lastTimeVote: 0,
            amount: 0,
            coinbase: "",
            canIAddSubject: "",
            contractStage: ""
        }

        this.onChangeHandler = this.onChangeHandler.bind(this);
        this.onSubmitHandler = this.onSubmitHandler.bind(this);
        this.getCoinbase = this.getCoinbase.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.getCoinbase();
            this.loadData();


        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }

    async getCoinbase() {
        let coinbase = await this.state.web3.eth.coinbase;
        this.setState({ coinbase })

    }

    loadData() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.getDonatePageInfo.call({ from: accounts[0] }, (err, res) => {
                if (err) {
                    console.log(err);
                }
                else {
                    console.log(res);
                    
                    this.setState({
                        contractBalance: res[0].toString(),
                        totalVotes: res[1].toString(),
                        personVotePower: res[2].toString(),
                        lastTimeVote: res[3].toString(),
                        canIAddSubject: res[4],
                        contractStage: res[5].toString(),
                    })
                    
                }
            })
        })
    }

    onChangeHandler(e) {
        this.setState({ [e.target.name]: e.target.value });
    }

    onSubmitHandler(e) {
        e.preventDefault();
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.donateToCharity({ from: accounts[0], value: this.state.web3.toWei(this.state.amount, 'ether') }, (err, res) => {
                if (err) {
                    console.log('here');
                    console.log(err)
                }
                else {
                    this.loadData();
                }
            })
        })
    }

    render() {
        if (this.state.coinbase == "") {
            return (
                <div className="subject-details">
                    <h2>Your matamask is locked please unlocked it or download it <a href="https://metamask.io/">here</a></h2>
                    <img src="http://pngimg.com/uploads/padlock/padlock_PNG9422.png" alt="locked" />
                </div>
            )
        }
        else if (this.state.contractStage === "2") {
            return (
            <div className="subject-details">
                <h2>The contract is currently locked right now.</h2>
            </div>
            );
        }
        else {
            return (
                <div className="donate">
                    <p>Currently the contract balance is: {this.state.contractBalance}</p>
                    <p>You currently are donated: {this.state.personVotePower / 10} ether</p>
                    <p>You vote power is: {this.state.personVotePower}</p>
                    <p>Last time vote for subject: {this.state.lastTimeVote}</p>
                    <p>Last time added subject: {this.state.lastTimeAddSubject}</p>
                    <p>Donate now</p>
                    <form onSubmit={this.onSubmitHandler}>
                        <Input
                            name="amount"
                            value={this.state.amount}
                            onChange={this.onChangeHandler}
                            label="Amount"
                            type="number" />
                        <input type="submit" value="Donate now" />
                    </form>
                </div>
            );
        }
    }
}