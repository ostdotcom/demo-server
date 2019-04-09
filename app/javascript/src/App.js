import React from 'react';
import { BrowserRouter, Route } from 'react-router-dom';
import List from './components/List';
import Header from './components/Header';
import TxDetails from './components/TxDetails';
import CustomData from './components/CustomData';
import Devices from './components/Devices';
import Token from './components/Token';

const App = () => (
  <BrowserRouter>
    <React.Fragment>
      <Header />
      <div className="container">
        <div className="row">
          <div className="col-12">
            <Route exact path="/" component={List} />
            <Route path="/user/:userId/ost-users" component={TxDetails} />
            <Route path="/user/:userId/devices" component={Devices} />
            <Route path="/custom-transactions" component={CustomData} />
            <Route path="/token" component={Token} />
          </div>
        </div>
      </div>
    </React.Fragment>
  </BrowserRouter>
);

export default App;
