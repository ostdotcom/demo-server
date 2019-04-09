import React from 'react';
import { Link } from 'react-router-dom';
import { apiRoot } from '../constants';

const Header = () => (
  <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
    <Link className="navbar-brand" to="/">
      OST Mappy Client
    </Link>
    <button
      className="navbar-toggler"
      type="button"
      data-toggle="collapse"
      data-target="#menu"
      aria-controls="menu"
      aria-expanded="false"
      aria-label="Toggle navigation"
    >
      <span className="navbar-toggler-icon" />
    </button>

    <div className="collapse navbar-collapse" id="menu">
      <ul className="navbar-nav mr-auto">
        <li className="nav-item">
          <Link className="nav-link" to="/">
            Users
          </Link>
        </li>
        <li className="nav-item">
          <Link className="nav-link" to="/custom-transactions">
            Custom Transactions
          </Link>
        </li>
        <li className="nav-item">
          <Link className="nav-link" to="/token">
            Token
          </Link>
        </li>
      </ul>
      <div className="my-2">
        <span
          className="badge badge-primary font-weight-light text-monospace"
          onClick={() => {
            window.apiRoot = prompt('Enter API root URL:') || window.apiRoot || apiRoot;
          }}
        >
          {window.apiRoot || apiRoot}
        </span>
      </div>
    </div>
  </nav>
);

export default Header;
