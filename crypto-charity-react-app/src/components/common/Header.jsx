import React, { Component } from 'react';
import { NavLink } from 'react-router-dom';


export default class Header extends Component {
    render() {

        return (
            <header>
                <nav>
                    <NavLink exact to="/" activeClassName="active">Home</NavLink>
                    <NavLink to="/subject" activeClassName="active">Subject</NavLink>
                    <NavLink to="/add-subject" activeClassName="active">Add Subject</NavLink>
                    <NavLink to="/lock" activeClassName="active">Lock</NavLink>
                    <NavLink to="/donate" activeClassName="active">Donate</NavLink>
                </nav>
            </header>
        );
    }
}