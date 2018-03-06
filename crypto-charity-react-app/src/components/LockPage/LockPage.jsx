import React, { Component } from 'react';

export default class ApprovedSubjectsPage extends Component {
    constructor(props) {
        super(props)
    }


    render() {
        return (
            <div className="subjects">
                <h2>Locking Contract</h2>
                <p>You are currently not voted for locking the contract</p>
                <button>Vote now</button>
            </div>
        );
    }
}