import React from "react";
import { createStore, combineReducers, applyMiddleware, compose } from "redux";
import { ConnectedRouter, routerReducer, routerMiddleware, push } from "react-router-redux";
import { Route, StaticRouter } from "react-router";
import createBrowserHistory from "history/createBrowserHistory";
import createMemoryHistory from "history/createMemoryHistory";
import thunkMW from "redux-thunk";

import routes from "routes";
import reducers from "reducers";
import WSActions from "actions/ws";


export default function createStoreAndRouter(props) {
  return (typeof window !== "undefined" && typeof window === "object")
    ? createForBrowser()
    : createForServer(props);
}

const createForBrowser = () => {
  const devToolsExt = typeof window.devToolsExtension !== "undefined"
    ? window.devToolsExtension()
    : f => f;
  const history = createBrowserHistory();
  const store = createStore(
    reducers,
    window.__INITIAL_STATE__,
    compose(
      applyMiddleware(thunkMW),
      applyMiddleware(routerMiddleware(history)),
      devToolsExt
    )
  );
  store.dispatch(WSActions.init());
  const router = <ConnectedRouter
    history={history}
  >
    {routes}
  </ConnectedRouter>;
  return { store, router };
}

const createForServer = (props) => {
  const history = createMemoryHistory();
  const store = createStore(
    reducers,
    props.initial_state,
    compose(
      applyMiddleware(thunkMW),
      applyMiddleware(routerMiddleware(history))
    )
  );
  const router = <StaticRouter
    context={{}}
    location={props.location}
    history={history}
  >
    {routes}
  </StaticRouter>;
  return { store, router };
}
