import React, { Component } from 'react';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import { contractAddress } from '../../api/remote';

export default class SubjectPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            web3: null,
            subject: {},
            coinbase: ""
        }

        this.getSubject = this.getSubject.bind(this);
        this.vote = this.vote.bind(this);
        this.getCoinbase = this.getCoinbase.bind(this);


    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.getCoinbase();
            this.getSubject();
        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }

    getSubject() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);

        cryotoCharityInstance.getSubject.call((err, res) => {
            if (err) {
                console.log(err)
            }
            else {
                let subject = {
                    recipientAddres: res[0],
                    votes: res[1].toString(),
                    requiredEther: res[2].toString(),
                    dateCreated: res[3].toString(),
                    title: this.state.web3.toAscii(res[4]),
                    description: this.state.web3.toAscii(res[5]),
                    totalVotes: res[6].toString(),
                    paid: res[7]
                }
                this.setState({ subject })
            }
        })

    }


    async getCoinbase() {
        let coinbase = await this.state.web3.eth.coinbase;
        this.setState({coinbase})
        
    }


    vote(e) {
        e.preventDefault();
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);

        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.voteForSubject({ "from": accounts[0] }, (err, res) => {
                if (err) {
                    console.log(err)
                }
                else {
                    this.getSubject();
                }
            })
        })
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
        else {
            if (this.state.subject.recipientAddres === "0x0000000000000000000000000000000000000000" || this.state.subject.paid === true) {

                return (
                    <div className="subject-details">
                        <h2>There is no subject right now. You can add now <a href="./add-subject">Add now.</a></h2>
                    </div>
                );
            }
            else {
                return (
                    <div className="subject-details">
                        <h2>{this.state.subject.title}</h2>
                        <section>
                            <p>{this.state.subject.description}</p>
                            <p>Required Ether: {this.state.subject.requiredEther}</p>
                            <p>Votes: {this.state.subject.votes} of total {this.state.subject.totalVotes}</p>
                            <button onClick={this.vote}>Vote Now</button>
                            <p>date Created: {this.state.subject.dateCreated}</p>
                            <p>{this.state.subject.feedback}</p>

                        </section>
                    </div>
                );
            }
        }
    }
}