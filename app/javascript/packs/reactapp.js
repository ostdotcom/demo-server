/*
 * Run this example by adding <%= javascript_pack_tag 'reactapp' %> to the head of your layout file,
 * like app/views/layouts/application.html.erb. The layout also needs a <div id="root"></div> element
 * in it's body for the React App to initiate
 */

import React from 'react'
import ReactDOM from 'react-dom'
import App from '../src/App';

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />, document.getElementById('root'),
  )
});
