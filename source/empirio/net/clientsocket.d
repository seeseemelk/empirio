module empirio.net.clientsocket;

version(unittest) {}
else
{
    import empirio.game;
    import empirio.net.packets;
    import empirio.net.socket;
    import empirio.player.human;

    import optional;
    import std.algorithm;
    import std.container;
    import vibe.vibe;

    /**
    A class which handles the communication to and from a player.
    */
    final class ClientSocket : Socket
    {
        private Game _game;
        private DList!string _packets;
    	private LocalManualEvent _event;
        private Optional!HumanPlayer _player;

        /**
        Creates a new socket class.
        Params:
            game = The instance of the game to play on.
        */
    	this(Game game)
    	{
    		_game = game;
            _packets = make!(DList!string);
    		_event = createManualEvent();
    	}

        /**
        Enters a read loop, reading and processing data from a socket.
        Params:
            socket = The socket to read from.
        */
    	void readLoop(scope WebSocket socket)
    	{
    		while (socket.waitForData)
    		{
    			auto json = socket.receiveText().parseJsonString();
    			const packetType = json["type"].to!string;

                switch (packetType)
                {
                    case "play":
                        handle(deserializeJson!PlayPacket(json));
                        break;
                    case "click":
                        handle(deserializeJson!ClickPacket(json));
                        break;
                    default:
                        logInfo("Received invalid packet from user");
                }

                /*
                if (packetType == "play" && state == State.MENU)
    			{
    				if (json["room"].type == Json.Type.undefined)
    				{
    					playGame(json["username"].to!string,
    							json["colour"].to!string, Nullable!int.init);
    				}
    				else
    					playGame(json["username"].to!string,
    							json["colour"].to!string, json["room"].to!int.nullable);
    			}
    			else if (packetType == "click" && state == State.GAME)
    			{
    				click(json["x"].to!int, json["y"].to!int);
    			}
    			else
    			{
    				logInfo("Received invalid packet from user");
    			}
                */
    		}
    	}

        /**
        Enters a write loop, writing data to the client.
        Params:
            socket = The socket to write to.
        */
    	void writeLoop(scope WebSocket socket)
    	{
    		while (socket.connected)
    		{
    			while (!_packets.empty)
    			{
    				auto packet = _packets.front;
    				_packets.removeFront();
    				socket.send(packet);
    			}
    			_event.wait(dur!"seconds"(10), _event.emitCount);
    		}
    	}

        /**
        Sends some JSON data to a socket.
        Params:
            str = The data to send.
        */
    	void send(string str)
    	{
    		_packets.insertBack(str);
    		_event.emit;
    	}

        private void handle(PlayPacket packet)
        {
            if (!isValidColour(packet.colour))
                return;
            if (!isValidUsername(packet.username))
                return;
            _player = some(new HumanPlayer(this, packet.username, packet.colour));
        }

        private void handle(ClickPacket packet)
        {
            _player.each!(player =>
            {

            });
        }

        private bool isValidColour(string colour)
        {
            if (colour.length != 3)
                return false;
            return isHexadecimal(colour[0])
                && isHexadecimal(colour[1])
                && isHexadecimal(colour[2]);
        }

        private bool isHexadecimal(char chr)
        {
            return (chr >= 'A' && chr <= 'F')
                || (chr >= 'a' && chr <= 'f')
                || (chr >= '0' && chr <= '9');
        }

        private bool isValidUsername(string username)
        {
            if (username.length < 3 || username.length > 30)
                return false;
            return username.all!(chr =>
                   (chr >= 'a' && chr <= 'z')
                || (chr >= 'A' && chr <= 'Z')
                || (chr >= '0' && chr <= '9')
                || (chr == '_')
                || (chr == '-')
            );
        }
    }
}
