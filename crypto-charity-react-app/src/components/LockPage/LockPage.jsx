import React, { Component } from 'react';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import { contractAddress } from '../../api/remote';

export default class ApprovedSubjectsPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            web3: null,
            subject: {},
            accounts: []
        }

        this.setAccounts = this.setAccounts.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.setAccounts();

        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }

    setAccounts() {
        this.state.web3.eth.getAccounts((error, accounts) => {
            this.setState({ accounts })
        })
    }




    render() {
        if (this.state.accounts.length === 0) {
            return (
                <div className="subject-details">
                    <h2>Your matamask is locked please unlocked it or download it <a href="https://metamask.io/">here</a></h2>
                    <img src="http://pngimg.com/uploads/padlock/padlock_PNG9422.png" alt="locked" />
                </div>
            )
        }
        else {
            return (
                <div className="subjects">
                    <h2>Locking Contract</h2>
                    <p>You are currently not voted for locking the contract</p>
                    <button>Vote now</button>
                </div>
            );
        }
    }
}