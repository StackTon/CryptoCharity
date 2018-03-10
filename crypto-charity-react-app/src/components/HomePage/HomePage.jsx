import React, { Component } from 'react';


export default class HomePage extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div className="home">
                <h1>Crypto Charity</h1>
                <h2>Make charity great again</h2>
                <section>
                    <article>
                        <p>This is a non profit project.</p>
                    </article>
                    <article>
                        <p>Don't have owenrs or backdoors</p>
                    </article>
                    <article>
                        <p>100% of the money you donate goes to charity.</p>
                    </article>
                </section>
            </div>
        );
    }
}