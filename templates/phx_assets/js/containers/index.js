import React from "react";
import { Provider } from "react-redux";

import createStoreAndRouter from "store";


export default class Index extends React.Component {
  render() {
    const { store, router } = createStoreAndRouter(this.props);
    return <Provider store={store}>
      {router}
    </Provider>;
  }
}
