import React, { Component } from 'react';
import CustomDataItem from './CustomDataItem';
import axios from 'axios/index';
import { apiRoot, dataMap } from '../constants';
import QRCode from 'qrcode.react';
import { Loader, Error } from './Loader';
import CustomInputDataItem from './CustomInputDataItem';

const MAX_COUNT = 10,
  COUNT = 5;

class CustomData extends Component {
  constructor(props) {
    super(props);
    this.state = {
      filteredUsers: [],
      amounts: [],
      addresses: [],
      currentTokenId: null,
      currentUserId: '',
      QRSeed: null,
      actionId: 0,
      actionLabel: dataMap[0]._label,
      count: COUNT,
      isLoaded: false,
      error: null
    };
  }

  getQRCodeData = () => {
    if (
      this.state.addresses.length !== this.state.amounts.length ||
      this.state.amounts.length === 0 ||
      !this.state.currentTokenId
    ) {
      return '';
    }
    let id = this.state.actionId,
      QRSeed = JSON.parse(JSON.stringify(dataMap[id]));

    QRSeed.d['ads'] = this.sanitizeArray(this.state.addresses);
    QRSeed.d['tid'] = this.state.currentTokenId;
    QRSeed.d['ams'] = this.sanitizeArray(this.state.amounts);
    delete QRSeed['_label'];
    return QRSeed;
  };

  sanitizeArray = (array) => {
    return array.filter((el) => {
      return el !== null;
    });
  };

  setAction = (event) => {
    let id = event.target.id,
      actionLabel = event.target.dataset.label;
    this.setState(
      {
        actionId: id,
        actionLabel: actionLabel
      },
      () => {
        this.setState({
          QRSeed: this.getQRCodeData()
        });
      }
    );
  };

  getData = () => {
    this.setState({ isLoaded: false });
    let filteredUsers = [];
    axios
      .get(`${window.apiRoot || apiRoot}api/users`)
      .then((res) => {
        const users = res.data['users'];
        if (users.length > 0) {
          users.forEach(function(user, userIndex) {
            if (user.token_holder_address) {
              filteredUsers.push(user);
            }
          });
        }
        this.setState({
          filteredUsers,
          isLoaded: true
        });
      })
      .catch((err) => {
        console.error(err);
        this.setState({
          isLoaded: true,
          error: err
        });
      });
  };

  componentDidMount = () => {
    this.getData();
  };

  handleUserChange = (event) => {
    let userId = event.target.value;
    axios
      .get(`${window.apiRoot || apiRoot}api/users/${userId}/ost-users`)
      .then((res) => {
        this.setState({
          currentTokenId: res.data && res.data.token_id,
          currentUserId: userId,
          QRSeed: this.getQRCodeData()
        });
      })
      .catch((err) => {});
  };

  handleAddressChange = (address, index) => {
    let addresses = this.state.addresses;
    addresses[index] = address;
    this.setState({
      addresses,
      QRSeed: this.getQRCodeData()
    });
  };

  handleAmountChange = (amount, index) => {
    let amounts = this.state.amounts;
    amounts[index] = amount;
    this.setState({
      amounts,
      QRSeed: this.getQRCodeData()
    });
  };

  ListItemCollection = () => {
    const items = [];
    for (var i = 0; i < this.state.count; i++) {
      items.push(
        <CustomDataItem
          filteredUsers={this.state.filteredUsers}
          key={i}
          id={i}
          handleAddressChange={this.handleAddressChange}
          handleAmountChange={this.handleAmountChange}
        />
      );
    }
    return items;
  };

  addItem = () => {
    this.setState({
      count: this.state.count + 1
    });
  };

  render() {
    if (this.state.error) return <Error class="alert-danger" message={this.state.error.message} />;
    if (!this.state.isLoaded)
      return (
        <div className="p-5">
          <Loader />
        </div>
      );
    if (this.state.isLoaded && this.state.filteredUsers.length === 0)
      return <Error class="alert-light" message="No users found!" />;

    return (
      <div>
        <div className="row bg-light py-3 my-4">
          <div className="col-12 col-md-4">
            <div className="form-group">
              <label htmlFor="userSelect">Select User</label>
              <select
                className="form-control"
                id="userSelect"
                value={this.state.currentUserId}
                onChange={this.handleUserChange}
              >
                <option />
                {this.state.filteredUsers.map((user) => (
                  <option value={user._id} key={user._id}>
                    {user.username}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="col-12 col-md-4">
            <label>Token Id</label>
            <div>{this.state.currentTokenId}</div>
          </div>
        </div>
        <div className="row">
          <div className="col-6">
            <div className="row">
              <div className="col-12 col-md-9">
                <label>Select Address</label>
              </div>
              <div className="col-12 col-md-3">
                <label>Amount</label>
              </div>
            </div>
            {this.ListItemCollection()}
            {this.state.count < MAX_COUNT ? (
              <button className="btn btn-light mb-2 float-right" onClick={this.addItem}>
                [+]
              </button>
            ) : (
              ''
            )}
            <CustomInputDataItem
              key={MAX_COUNT}
              id={MAX_COUNT}
              handleAddressChange={this.handleAddressChange}
              handleAmountChange={this.handleAmountChange}
            />
          </div>
          <div className="col-6">
            <div className="row">
              <div className="col-12 text-center">
                <h3>{this.state.actionLabel}</h3>
              </div>
              <div className="col-12 text-center w-100 mt-3" style={{ height: '350px' }}>
                {this.state.QRSeed && console.log('QRSeed:', this.state.QRSeed)}
                {this.state.QRSeed ? (
                  <QRCode className="p-4" size={350} value={JSON.stringify(this.state.QRSeed)} />
                ) : (
                  <span className="text-muted">Incomplete / incorrect address / amount combination</span>
                )}
              </div>
            </div>
          </div>
        </div>
        <div className="row text-center my-3">
          <div className="text-center w-100">
            {dataMap.map((action, index) => (
              <button
                key={`k-${index}`}
                className="btn btn-primary mx-2"
                id={index}
                data-label={action._label}
                onClick={this.setAction}
              >
                {action._label}
              </button>
            ))}
          </div>
        </div>
      </div>
    );
  }
}

export default CustomData;
