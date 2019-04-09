import React from 'react';

const Loader = (props) => <div>Loading...</div>;
const Error = (props) => <div className={`alert ${props.class} mt-3`}>Error: {props.message}</div>;

export { Loader, Error };
