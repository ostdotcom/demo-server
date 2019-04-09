/*
 * External dependencies
 */
import React, { Component } from 'react';
import QRCode from 'qrcode.react';
import axios from 'axios';

/*
 * Internal dependencies
 */
import { dataMap, apiRoot } from '../constants';
import { Loader, Error } from './Loader';

class TxDetails extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentListId: null,
      user: null,
      error: null,
      isLoaded: false
    };
    const params = new URL(document.location).searchParams;
    this.ams = params.getAll('ams');
  }

  componentDidMount() {
    this.setState({
      isLoaded: false
    });
    axios
      .get(`${window.apiRoot || apiRoot}api/users/${this.props.match.params.userId}/ost-users`)
      .then((res) => {
        this.setState({
          user: res.data,
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

  onActionChange = (event) => {
    let id = event.target.id,
      QRSeed = JSON.parse(JSON.stringify(dataMap[id]));
    QRSeed.d['ads'] = [this.state.user.token_holder_address];
    QRSeed.d['tid'] = this.state.user.token_id;
    if (this.ams.length > 0) {
      QRSeed.d['ams'] = this.ams;
    }
    delete QRSeed['_label'];
    this.setState({
      currentListId: id,
      QRSeed
    });
  };

  render() {
    if (this.state.error) return <Error class="alert-danger" message={this.state.error.message} />;
    if (!this.state.isLoaded)
      return (
        <div className="p-4">
          <Loader />
        </div>
      );
    this.state.QRSeed && console.log('QRSeed data:', this.state.QRSeed);
    return (
      <React.Fragment>
        <div className="row">
          <div className="text-center w-100" style={{ height: '350px' }}>
            {this.state.QRSeed ? (
              <QRCode className="p-4" size={350} value={JSON.stringify(this.state.QRSeed)} />
            ) : (
              <p className="p-4 display-4 text-muted" style={{ height: '350px' }}>
                Select an action to get QR code
              </p>
            )}
          </div>
        </div>
        <div className="row text-center">
          <div className="text-center w-100">
            {dataMap.map((action, index) => (
              <button key={`k-${index}`} className="btn btn-primary mx-2" id={index} onClick={this.onActionChange}>
                {action._label}
              </button>
            ))}
          </div>
        </div>
      </React.Fragment>
    );
  }
}

export default TxDetails;
