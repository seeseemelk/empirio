module empirio.net.clientsocket;

version(unittest) {}
else
{
	import empirio.room;
	import empirio.game;
	import empirio.net.packets;
	import empirio.net.socket;
	import empirio.player.human;

	import core.time;
	import vibe.core.log;
	import vibe.data.json;
	import vibe.http.websockets;
	import optional;
	import std.algorithm;
	import std.container;
	import vibe.core.sync;

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
						handle(deserializeJson!ClientPlayPacket(json));
						break;
					case "click":
						handle(deserializeJson!ClientClickPacket(json));
						break;
					default:
						logInfo("Received invalid packet from user");
				}
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

		private void handle(ClientPlayPacket packet)
		{
			if (!isValidColour(packet.colour))
				return;
			if (!isValidUsername(packet.username))
				return;
			Room room;
			if (packet.room.isNull)
				room = _game.getRandomRoom();
			else
				room = _game.getRoom(packet.room.get());
			auto player = new HumanPlayer(this, room, packet.username, packet.colour);
			_player = some(player);
			player.sendStart();
			room.addPlayer(player);
			player.sendMap();
		}

		private void handle(ClientClickPacket packet)
		{
			_player.each!(player => player.handle(packet));
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
