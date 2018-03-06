import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import './styles/home-page.css';
import './styles/header.css';
import './styles/all-subjects.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';
import { BrowserRouter as Router } from 'react-router-dom';

ReactDOM.render((
    <Router>
        <App />
    </Router>), document.getElementById('root'));
registerServiceWorker();
