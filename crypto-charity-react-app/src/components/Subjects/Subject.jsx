import React from 'react';

export default (props) => {
    let index = '';
    let title = '';
    let description = '';
    index = props.index;
    title = props.title.trim();
    description = props.description.trim();

    return (
        <article>
            <p>Hiii</p>
            <h3>{title}</h3>
            <p>{description}</p>
            <a href="/subject/{index}">View More</a>
        </article>
    )
}