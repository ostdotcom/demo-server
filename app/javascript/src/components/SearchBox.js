import React from 'react';

const SearchBox = (props) => (
  <React.Fragment>
    <div className="row justify-content-end px-4 pt-4">
      <div className="col-6 col-md-3 float-right">
        <input
          type="text"
          className="form-control form-control-sm"
          placeholder="Search..."
          onKeyUp={props.updateSearchCriteria}
        />
      </div>
    </div>
  </React.Fragment>
);

export default SearchBox;
