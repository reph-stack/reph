import React from "react";


export default class Header extends React.Component {
  render() {
    return <header className="header">
      <nav role="navigation">
        <ul className="nav nav-pills pull-right">
          <li><a href="http://www.phoenixframework.org/docs">Get Started</a></li>
        </ul>
      </nav>
      <span className="logo"></span>
    </header>;
  }
};
