import React, { Component } from 'react';
import Input from '../common/Input';

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

    onChangeHandler(e) {
        this.setState({ [e.target.name]: e.target.value });
    }

    onSubmitHandler(e) {
        e.preventDefault();
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
                </form>
            </div>
        );
    }
}