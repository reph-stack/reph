import React from "react";

import Header from "components/Header";


export default class AppContainer extends React.Component {
  render() {
    return <div>
      <Header />
      <div className="container">
        {this.props.children}
      </div>
    </div>;
  }
};
