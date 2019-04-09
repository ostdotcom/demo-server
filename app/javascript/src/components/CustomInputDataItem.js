import React from 'react';

export default class CustomInputDataItem extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      address: '',
      amount: ''
    };
  }

  onAddressChange = (event) => {
    let address = event.target.value;
    this.props.handleAddressChange(address, this.props.id);
    this.setState({
      address
    });
  };

  onAmountChange = (event) => {
    let amount = event.target.value;
    this.props.handleAmountChange(amount, this.props.id);
    this.setState({
      amount
    });
  };

  render() {
    return (
      <React.Fragment>
        <div style={{ clear: 'right' }}>Custom Address</div>
        <div className="row">
          <div className="col-12 col-md-9">
            <input
              type="text"
              className="form-control form-control-sm"
              value={this.state.address}
              id={`address${this.props.id}`}
              onChange={this.onAddressChange}
            />
          </div>
          <div className="col-12 col-md-3">
            <input
              type="number"
              className="form-control form-control-sm"
              value={this.state.amount}
              id={`amount${this.props.id}`}
              onChange={this.onAmountChange}
            />
          </div>
        </div>
      </React.Fragment>
    );
  }
}
