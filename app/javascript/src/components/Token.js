import React, { Component } from 'react';
import PriceOracle from '.././utils/PriceOracle';
import axios from 'axios/index';
import { apiRoot } from '../constants';
import { Loader, Error } from './Loader';

export default class Token extends Component {
  constructor(props) {
    super(props);
    this.ost_to_fiat_conversion_ratio = 0;
    this.ost_to_bt_conversion_ratio = 0;
    this.priceOracle = null;
    this.state = {
      error: null,
      isLoaded: false,
      BT_val: '',
      OST_val: '',
      FIAT_val: '',
      tokenDetails: {}
    };
  }

  componentDidMount() {
    axios
      .get(`${window.apiRoot || apiRoot}api/token`)
      .then((res) => {
        this.ost_to_fiat_conversion_ratio = res.data && res.data['price_points']['price_point']['OST']['USD'];
        this.ost_to_bt_conversion_ratio = res.data && res.data['token']['conversion_factor'];
        this.decimals = res.data && res.data['token']['decimals'];
        this.priceOracle = new PriceOracle({
          ost_to_fiat: this.ost_to_fiat_conversion_ratio,
          ost_to_bt: this.ost_to_bt_conversion_ratio,
          decimals: this.decimals
        });
        this.priceOracle.fromWei.bind(this.priceOracle);
        this.setState({
          tokenDetails: res.data && res.data['token'],
          isLoaded: true
        });
      })
      .catch((err) => {
        this.setState({
          error: err,
          isLoaded: true
        });
      });
  }

  handleOSTChange = (event) => {
    let value = event.target.value;
    this.setState({
      BT_val: this.priceOracle.ostToBt(value),
      OST_val: value,
      FIAT_val: this.priceOracle.ostToFiat(value)
    });
  };

  handleBTChange = (event) => {
    let value = event.target.value;
    this.setState({
      BT_val: value,
      OST_val: this.priceOracle.btToOst(value),
      FIAT_val: this.priceOracle.btToFiat(value)
    });
  };

  render() {
    if (this.state.error) return <Error class="alert-danger" message={this.state.error.message} />;
    if (!this.state.isLoaded)
      return (
        <React.Fragment>
          <div className="p-5">
            <Loader />
          </div>
        </React.Fragment>
      );
    return (
      <React.Fragment>
        <div className="row my-4">
          <div className="col-12">
            <h6>Token Details</h6>
            <table className="table mt-4">
              <tbody>
                <tr>
                  <th scope="row">Token ID</th>
                  <td>{this.state.tokenDetails.id}</td>
                </tr>
                <tr>
                  <th scope="row">Name, Symbol</th>
                  <td>
                    {this.state.tokenDetails.name} ({this.state.tokenDetails.symbol})
                  </td>
                </tr>
                <tr>
                  <th scope="row">Total supply</th>
                  <td>{this.priceOracle.fromWei(this.state.tokenDetails.total_supply)}</td>
                </tr>
                <tr>
                  <th scope="row">Utility branded token contract</th>
                  <td>
                    {this.state.tokenDetails.auxiliary_chains &&
                      this.state.tokenDetails.auxiliary_chains[0].utility_branded_token}
                  </td>
                </tr>
                <tr>
                  <th scope="row">Value branded token contract</th>
                  <td>
                    <a
                      target="_blank"
                      rel="noopener noreferrer"
                      href={`https://ropsten.etherscan.io/address/${this.state.tokenDetails.origin_chain &&
                        this.state.tokenDetails.origin_chain.branded_token}`}
                    >
                      {this.state.tokenDetails.origin_chain && this.state.tokenDetails.origin_chain.branded_token}
                    </a>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <h6>Token conversion calculator</h6>
        <div className="row mt-4">
          <div className="col-4">
            <label htmlFor="OST_input" className="mr-2">
              Value in OST
            </label>
            <input
              type="text"
              className="form-control form-control-sm"
              value={this.state.OST_val}
              id="OST_input"
              onChange={this.handleOSTChange}
            />
          </div>
          <div className="col-4">
            <label htmlFor="BT_input" className="mr-2">
              Value in BT
            </label>
            <input
              type="text"
              className="form-control form-control-sm"
              value={this.state.BT_val}
              id="BT_input"
              onChange={this.handleBTChange}
            />
          </div>
          <div className="col-4">
            <label htmlFor="USD_input" className="mr-2">
              Value in USD
            </label>
            <input
              disabled
              className="form-control form-control-sm"
              type="text"
              value={this.state.FIAT_val}
              id="USD_input"
            />
          </div>
        </div>
      </React.Fragment>
    );
  }
}
