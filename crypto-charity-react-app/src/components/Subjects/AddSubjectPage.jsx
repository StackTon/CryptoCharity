import React, { Component } from 'react';
import Input from '../common/Input';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import { contractAddress } from '../../api/remote';

export default class AddSubjectPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            recitientAddres: '',
            reqiredEth: 0,
            title: '',
            decription: '',
            accounts: []
        };

        this.onChangeHandler = this.onChangeHandler.bind(this);
        this.onSubmitHandler = this.onSubmitHandler.bind(this);
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

    onChangeHandler(e) {
        this.setState({ [e.target.name]: e.target.value });
    }

    onSubmitHandler(e) {
        e.preventDefault();
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at(contractAddress);
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.addSubject(this.state.recitientAddres, this.state.reqiredEth, this.state.title, this.state.decription, { from: accounts[0] }, (err, res) => {
                if (err) {
                    console.log(err)
                }
                else {
                    console.log(res);
                }
            })


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
                <div className="subject-details">
                    <h2>Add Subject</h2>
                    <form onSubmit={this.onSubmitHandler}>
                        <Input
                            name="title"
                            value={this.state.title}
                            onChange={this.onChangeHandler}
                            label="Title"
                        />
                        <Input
                            name="decription"
                            value={this.state.decription}
                            onChange={this.onChangeHandler}
                            label="Decription"
                        />


                        <Input
                            name="recitientAddres"
                            value={this.state.recitientAddres}
                            onChange={this.onChangeHandler}
                            label="RecitientAddres"
                        />
                        <Input
                            name="reqiredEth"
                            value={this.state.reqiredEth}
                            onChange={this.onChangeHandler}
                            label="ReqiredEth"
                            type="number"
                        />
                        <input type="submit" value="Add subject" />
                    </form>
                </div>
            );
        }
    }
}