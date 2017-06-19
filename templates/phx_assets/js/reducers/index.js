import { combineReducers } from "redux";
import { routerReducer } from "react-router-redux";

import ws from "reducers/ws";


export default combineReducers({
  routing: routerReducer,
  ws
});
