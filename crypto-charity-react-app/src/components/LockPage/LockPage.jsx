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
            coinbase: "",
            contractStage: ""
        }

        this.getCoinbase = this.getCoinbase.bind(this);
        this.getInfo = this.getInfo.bind(this);
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

        cryotoCharityInstance.getlockPageInfo.call((err, res) => {
            if(err) {
                console.log(err);
            }
            else {
                this.setState({contractStage: res.toString()});
            }
        })
    }

    async getCoinbase() {
        let coinbase = await this.state.web3.eth.coinbase;
        this.setState({coinbase})
    }




    render() {
        if (this.state.coinbase.length === 0) {
            return (
                <div className="subject-details">
                    <h2>Your matamask is locked please unlocked it or download it <a href="https://metamask.io/">here</a></h2>
                    <img src="http://pngimg.com/uploads/padlock/padlock_PNG9422.png" alt="locked" />
                </div>
            )
        }
        else if(this.state.contractStage === "2") {
            return (
                <div className="subjects">
                    <h1>Contract is currently locked right now.</h1>
                    <h2>Locking Contract</h2>
                    <p>You are currently not voted for locking the contract</p>
                    <button>Vote now</button>
                </div>
            );
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