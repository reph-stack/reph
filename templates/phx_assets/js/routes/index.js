import React from "react";
import { Route, Switch, IndexRoute } from "react-router";

import AppContainer from "containers/App";
import Main from "components/Main";


export default (<AppContainer>
  <Switch>
    <Route exact path="/" component={Main} />
  </Switch>
</AppContainer>);
