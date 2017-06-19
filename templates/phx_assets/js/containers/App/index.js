import React from "react";

import Header from "components/Header";


export default class AppContainer extends React.Component {
  render() {
    return <div className="container">
      <Header />
      <main role="main">
        {this.props.children}
      </main>
    </div>;
  }
};
