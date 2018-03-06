import React, { Component } from 'react';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';

export default class HomePage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            storageValue: 0,
            web3: null
        }
    }

    componentWillMount() {
        // Get network provider and web3 instance.
        // See utils/getWeb3 for more info.

        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })


            // Instantiate contract once web3 provided.
            this.getSubjects();
        })
            .catch((err) => {
                console.log(err);
                console.log('Error finding web3.')
            })


    }

    async getSubjects() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at("0xb16212d4e2fe4784575afb4269942d18644b3432");

        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.getAllSubjects((err, res) => {
                console.log(res);
                console.log(this.state.web3.version.api);
            })
        })
    }


    render() {
        return (
            <div className="home">
                <h1>Crypto Charity</h1>
                <h2>Make charity great again</h2>
                <section>
                    <article>
                        <p>This is a non profit project.</p>
                    </article>
                    <article>
                        <p>DAO - Decentralized autonomous organization, witch mean that this organization has no leater or owner</p>
                    </article>
                    <article>
                        <p>100% of the money you donate goes to charity.</p>
                    </article>
                </section>
            </div>
        );
    }
}