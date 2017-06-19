const initialState = {
  socket: null,
  channels: {}
};

export default function reducer(state = initialState, action = {}) {
  switch (action.type) {
    case "SOCKET_CONNECT":
      return {
        ...state,
        socket: action.socket
      };
    case "CHANNEL_JOIN":
      return {
        ...state,
        channels: {
          ...state.channels,
          [action.name]: action.channel
        }
      }
    case "CHANNEL_LEAVE":
      let { [action.name]: _channel, ...channels } = state.channels;
      return {
        ...state,
        channels: channels
      }
    default:
      return state;
  }
};

