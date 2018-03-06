import React, { Component } from 'react';
import { Route, Switch, withRouter } from 'react-router-dom';
import Header from './components/common/Header';
import HomePage from './components/HomePage/HomePage';
import SubjectsPage from './components/Subjects/SubjectsPage';
import ApprovedSubjectsPage from './components/Subjects/ApprovedSubjectsPage';
import AddSubjectPage from './components/Subjects/AddSubjectPage';
import SubjectDetails from './components/Subjects/SubjectDetails';
import LockPage from './components/LockPage/LockPage';

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
                    <Route exact path="/subjects" component={SubjectsPage} />
                    <Route exact path="/approved-subject" component={ApprovedSubjectsPage} />
                    <Route exact path="/subject/:index" component={SubjectDetails} />
                    <Route exact path="/add-subject" component={AddSubjectPage} />
                    <Route exact path="/lock" component={LockPage} />
                </Switch>
            </div>
        );
    }
}

export default withRouter(App);