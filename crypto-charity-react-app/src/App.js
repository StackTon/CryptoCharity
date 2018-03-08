import React, { Component } from 'react';
import { Route, Switch, withRouter } from 'react-router-dom';
import Header from './components/common/Header';
import HomePage from './components/HomePage/HomePage';
import SubjectPage from './components/Subjects/SubjectPage';
import AddSubjectPage from './components/Subjects/AddSubjectPage';
import LockPage from './components/LockPage/LockPage';
import DonatePage from './components/DonatePage/DonatePage';

class App extends Component {
    constructor(props) {
        super(props);

        this.onLogout = this.onLogout.bind(this);
    }

    onLogout() {
        localStorage.clear();
        this.props.history.push('/');
    }

    render() {
        return (
            <div className="App">
                <Header loggedIn={localStorage.getItem('authToken') != null} onLogout={this.onLogout} />
                <Switch>
                    <Route exact path="/" component={HomePage} />
                    <Route exact path="/subject" component={SubjectPage} />
                    <Route exact path="/add-subject" component={AddSubjectPage} />
                    <Route exact path="/lock" component={LockPage} />
                    <Route exact path="/donate" component={DonatePage} />
                </Switch>
            </div>
        );
    }
}

export default withRouter(App);