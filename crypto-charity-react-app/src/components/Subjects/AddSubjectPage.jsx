import React, { Component } from 'react';
import Input from '../common/Input';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';

export default class AddSubjectPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            recitientAddres: '',
            reqiredEth: 0,
            title: '',
            decription: ''

        };

        this.onChangeHandler = this.onChangeHandler.bind(this);
        this.onSubmitHandler = this.onSubmitHandler.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })

        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }

    onChangeHandler(e) {
        this.setState({ [e.target.name]: e.target.value });
    }

    onSubmitHandler(e) {
        e.preventDefault();
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at("0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f");
        this.state.web3.eth.getAccounts((error, accounts) => {
            cryotoCharityInstance.addSubject(this.state.recitientAddres, this.state.reqiredEth, this.state.title, this.state.decription, { from: accounts[0]}, (err, res) => {
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
                    <input type="submit" value="Add subject"/>
                </form>
            </div>
        );
    }
}