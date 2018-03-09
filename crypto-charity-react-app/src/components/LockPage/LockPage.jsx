import React, { Component } from 'react';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import { contractAddress } from '../../api/remote';
import toastr from 'toastr';

export default class ApprovedSubjectsPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            web3: null,
            coinbase: "",
            contractStage: 0,
            totalVotes: 0,
            totalVotesForLock: 0,
            personVotePower: 0,
            personVotesForLock: 0
        }

        this.getCoinbase = this.getCoinbase.bind(this);
        this.getInfo = this.getInfo.bind(this);
        this.voteForLock = this.voteForLock.bind(this);
        this.voteForUnlock = this.voteForUnlock.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.getCoinbase();
            this.getInfo();

        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }

    getInfo() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.getLockPageInfo.call({ from: accounts[0] }, (err, res) => {
                if (err) {
                    console.log(err);
                }
                else {
                    this.setState({
                        contractStage: res[0].toString(),
                        totalVotes: res[1].toString(),
                        totalVotesForLock: res[2].toString(),
                        personVotePower: res[3].toString(),
                        personVotesForLock: res[4].toString(),
                        hasVotedForLock: res[5].toString()
                    });
                }
            })
        })
    }

    async getCoinbase() {
        let coinbase = await this.state.web3.eth.coinbase;
        this.setState({ coinbase })
    }

    voteForLock(e) {
        e.preventDefault();
        let counter = 0;
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);

        cryotoCharityInstance.voteForLocking({ from: this.state.coinbase }, (err, res) => {
            if (err) {
                console.log(err);
            }
            else {
                console.log(res);
                var event = cryotoCharityInstance.LogVoteForLocking({ from: this.state.coinbase },function (error, result) {
                    if (error) {
                        console.log(error);
                    }
                    else {
                        if (counter === 0) {
                            toastr.warning("Pending..");
                            counter++;
                        }
                        else if (counter === 1) {
                            toastr.success("Success! Refresh the page.");
                            counter = 0;
                        }
                    }
                })
            }
        })
    }

    voteForUnlock(e) {
        e.preventDefault();

        let counter = 0;
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);

        cryotoCharityInstance.removeVoteForLocking({ from: this.state.coinbase }, (err, res) => {
            if (err) {
                console.log(err);
            }
            else {
                console.log(res);
                var event = cryotoCharityInstance.LogRemoveVoteForLocking({ from: this.state.coinbase  },function (error, result) {
                    if (error) {
                        console.log(error);
                    }
                    else {
                        if (counter === 0) {
                            toastr.warning("Pending..");
                            counter++;
                        }
                        else if (counter === 1) {
                            toastr.success("Success! Refresh the page.");
                            counter = 0;
                        }
                    }
                })
            }
        })
    }

    render() {
        console.log(this.state);
        let contractIsLock = <h1>Contract is currently locked right now.</h1>;
        if (this.state.coinbase === "") {
            return (
                <div className="subject-details">
                    <h2>Your matamask is locked please unlocked it or download it <a href="https://metamask.io/">here</a></h2>
                    <img src="http://pngimg.com/uploads/padlock/padlock_PNG9422.png" alt="locked" />
                </div>
            )
        }
        else if (this.state.personVotePower === "0") {
            return (
                <div className="subject-details">
                    <h1>Your vote power is zero is you want to vote in locking. you must donate to the contract first</h1>
                </div>
            );
        }
        else {
            return (
                <div className="subject-details">
                    {this.state.contractStage === "2" ? contractIsLock : ""}
                    <h2>Locking Contract</h2>
                    <p>Total votes for lock {this.state.totalVotesForLock} of {(this.state.totalVotes / 2) + 1}</p>
                    <p>Your vote power is {this.state.personVotePower}</p>
                    <p>You are currently not voted for locking the contract</p>
                    {this.state.personVotesForLock === "0" ? <button onClick={this.voteForLock}>Vote for locking the contract</button> : <button onClick={this.voteForUnlock}>Remove your vote for locking the contract</button>}
                </div>
            );
        }
    }
}