import React, { Component } from 'react';
import { NavLink } from 'react-router-dom';


export default class Header extends Component {
    render() {

        return (
            <header>
                <nav>
                    <ul>
                        <li><NavLink exact to="/" activeClassName="active">Home</NavLink></li>
                        <li><NavLink to="/subjects" activeClassName="active">Subject</NavLink></li>
                        <li><NavLink to="/approved-subject" activeClassName="active">Approved Subjects</NavLink></li>
                        <li><NavLink to="/add-subject" activeClassName="active">Add Subject</NavLink></li>
                        <li><NavLink to="/lock" activeClassName="active">Lock</NavLink></li>
                    </ul>
                </nav>
            </header>
        );
    }
}