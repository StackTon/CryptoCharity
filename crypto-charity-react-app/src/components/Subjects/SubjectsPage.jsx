import React, { Component } from 'react';
import getWeb3 from '../../utils/getWeb3';
import CryotoCharity from '../../utils/contractABI.json';
import Subject from './Subject';

export default class SubjectsPage extends Component {
    constructor(props) {
        super(props)

        this.state = {
            web3: null,
            subjects: []
        }

        this.getSubjects = this.getSubjects.bind(this);
    }

    componentDidMount() {
        getWeb3.then(results => {
            this.setState({
                web3: results.web3
            })
            this.getSubjects();

        }).catch((err) => {
            console.log(err);
            console.log('Error finding web3.')
        })
    }



    getSubjects() {
        const cryotoCharityInstance = this.state.web3.eth.contract(CryotoCharity).at("0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f");
        cryotoCharityInstance.getAllSubjects.call((err, res) => {
            if (err) {
                console.log(err);
            }
            else {
                for (let i = 0; i < res[0].length; i++) {
                    const subject = {
                        votes: res[0][i].toString(),
                        requiredEther: res[1][i].toString(),
                        dateCreated: res[2][i].toString(),
                        title: this.state.web3.toAscii(res[3][i]),
                        description: this.state.web3.toAscii(res[4][i])

                    }
                    this.state.subjects.push(subject)
                }
            }
        })

    }




    render() {


        return (
            <div className="subjects">
                <h2>All subjects for approvel</h2>
                <section>
                    {this.state.subjects.map((subject, index) => {
                        console.log(subject);
                        console.log(index);
                        return <Subject key={index} index={index} title={subject.title} description={subject.description} />
                    })}
                </section>
            </div>
        );
    }
}