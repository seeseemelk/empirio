module empirio.net.clientsocket;

import std.exception;

private class EmpirioFatalException : Exception
{
	mixin basicExceptionCtors;
}

private class EmpirioException : Exception
{
	mixin basicExceptionCtors;
}

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

				try
				{
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
				catch (EmpirioException e)
				{
					sendError(e.message);
				}
				catch (Exception e)
				{
					sendFatal("An internal error occured");
					logException(e, "Exception occured in read loop");
				}
			}
		}

		/**
		Sends an error message to the client.
		Params:
			message = The message to send to the client.
		*/
		private void sendError(const(char[]) message, bool recoverable) @safe
		{
			ServerErrorPacket packet;
			packet.message = message;
			packet.recoverable = recoverable;
			send(serializeToJson(packet).toString());
		}

		override void sendError(const(char[]) message)
		{
			sendError(message, true);
		}

		override void sendFatal(const(char[]) message)
		{
			sendError(message, false);
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
		void send(string str) @safe nothrow
		{
			_packets.insertBack(str);
			_event.emit;
		}

		private void handle(ClientPlayPacket packet)
		{
			if (!isValidColour(packet.colour))
				throw new EmpirioException("Invalid colour");
			if (!isValidUsername(packet.username))
				throw new EmpirioException("Invalid username");
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
