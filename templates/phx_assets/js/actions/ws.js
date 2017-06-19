import { Socket } from "phoenix";


const setupHandlers = (name, channel, dispatch, getState) => {
  switch (name) {
    default:
      break;
  }
};

const actions = {
  init: () => {
    return (dispatch, getState) => {
      dispatch(actions.socket_connect());
    }
  },
  socket_connect: () => {
    return (dispatch, getState) => {
      const { ws } = getState();
      if (ws.socket !== null) {
        ws.socket.disconnect();
      }
      const params = {};
      const logger = (kind, msg, data) => { console.log(`${kind}: ${msg}`, data); };
      const socket = new Socket('/socket', {params, logger});
      socket.connect();
      dispatch({
        type: "SOCKET_CONNECT",
        socket: socket
      });
    }
  },
  channel_join: (name, alias = false, params = {}) => {
    return (dispatch, getState) => {
      if ( ! alias) {
        alias = name;
      }
      const { ws } = getState();
      if (ws.socket !== null) {
        const channel = ws.socket.channel(name, params);
        channel
          .join()
          .receive("ok", () => {
            setupHandlers(alias, channel, dispatch, getState);
            dispatch({
              type: "CHANNEL_JOIN",
              name: alias,
              channel: channel
            });
          });
      }
    }
  },
  channel_leave: (name) => {
    return (dispatch, getState) => {
      if ( ! inBrowser) return;
      const { ws } = getState();
      ws.channels[name].leave();
      dispatch({
        type: "CHANNEL_LEAVE",
        name
      })
    };
  }
};

export default actions;
