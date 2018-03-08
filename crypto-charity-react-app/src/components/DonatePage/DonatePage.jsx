import React, { Component } from 'react';
import Input from '../common/Input';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';


export default class DonatePage extends Component {
    constructor(props) {
        super(props);

        this.state = {
            web3: null,
            contractBalance: 0,
            personVotePower: 0,
            lastTimeVote: 0,
            lastTimeAddSubject: 0,
            amount: 0,
        }

        this.onChangeHandler = this.onChangeHandler.bind(this);
        this.onSubmitHandler = this.onSubmitHandler.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.loadData();

        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }
    //0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f

    loadData() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at("0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f");
        cryotoCharityInstance.getDonatePageInfo.call((err, res) => {
            if (err) {
                console.log(err);
            }
            else {
                this.setState({
                    contractBalance: res[0].toString(),
                    personVotePower: res[1].toString(),
                    lastTimeVote: res[2].toString(),
                    lastTimeAddSubject: res[3].toString(),
                })
            }
        })
    }

    onChangeHandler(e) {
        this.setState({ [e.target.name]: e.target.value });
    }

    onSubmitHandler(e) {
        e.preventDefault();
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at("0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f");
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.donateToCharity({from: accounts[0], value: this.state.web3.toWei(this.state.amount, 'ether')}, (err, res) => {
                if(err){
                    console.log(err)
                }
                else {
                    console.log(res);
                }
            })
        })
    }

    render() {
        return (
            <div className="donate">
                <p>Currently the contract balance is: {this.state.contractBalance}</p>
                <p>You currently are donated: {this.state.personVotePower}</p>
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