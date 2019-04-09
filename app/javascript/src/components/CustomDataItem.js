import React from 'react';

export default class CustomDataItem extends React.Component {
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
      <div className="row mb-2">
        <div className="col-12 col-md-9">
          <select
            value={this.state.address}
            className="form-control form-control-sm"
            id={`addressSelect${this.props.id}`}
            onChange={this.onAddressChange}
          >
            <option />
            {this.props.filteredUsers.map((user) => (
              <option key={user._id} value={user.token_holder_address}>
                {user.user_display_name} ({user.token_holder_address})
              </option>
            ))}
          </select>
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
    );
  }
}
