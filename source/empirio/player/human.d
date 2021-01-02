module empirio.player.human;

import empirio.net.packets;
import empirio.net.socket;
import empirio.player;
import empirio.room;

import optional;
import std.algorithm;
import std.uuid;

/**
Describes a Player who is controlled by a human.
*/
final class HumanPlayer : Player, RoomObserver
{
	private Room _room;
	private Socket _socket;
	private string _colour;
	private string _name;
	private UUID _uuid;

	/**
	Creates a new human player.
	Params:
		socket = The socket to communicate over.
		room = The room in which the player will play.
		name = The name of the human player.
		colour = The colour of the player.
	*/
	this(Socket socket, Room room, string name, string colour)
	{
		_colour = colour;
		_name = name;
		_room = room;
		_socket = socket;
		_uuid = randomUUID();

		_room.addObserver(this);
	}

	/**
	Sends the entire map to the player.
	*/
	void sendMap()
	{
		_room.players()
			.each!(player => onPlayerJoined(player));
		_room.findNonEmptyTiles().each!(tile => sendTile(tile));
		_socket.send(ServerMapLoadedPacket());
	}

	override UUID id() const
	{
		return _uuid;
	}

	override string name() const
	{
		return _name;
	}

	override string colour() const
	{
		return _colour;
	}

	override void onPlayerJoined(Player player)
	{
		if (player !is this)
		{
			ServerPlayerJoinPacket packet;
			packet.colour = player.colour;
			packet.id = player.id.toString();
			packet.name = player.name;
			_socket.send(packet);
		}
	}

	override void onTileChanged(Tile _, Tile newTile)
	{
		sendTile(newTile);
	}

	/**
	Sends the play packet.
	*/
	void sendStart()
	{
		ServerStartPacket packet;
		packet.room = _room.id;
		packet.width = _room.settings.width;
		packet.height = _room.settings.height;
		packet.playerId = _uuid.toString();
		_socket.send(packet);
	}

	private void sendTile(Tile tile)
	{
		ServerTileChangePacket packet;
		tile.owner.each!((Player owner)
		{
			packet.owner = owner.id.toString();
		});
		packet.x = tile.x;
		packet.y = tile.y;
		packet.strength = tile.strength;
		_socket.send(packet);
	}
}

@("HumanPlayer.name() returns the name")
unittest
{
	import mocked : Mocker;
	Mocker mocker;
	auto socket = mocker.mock!Socket();
	const player = new HumanPlayer(socket, new Room(1), "hello", "F00");
	assert(player.name() == "hello");
}

@("HumanPlayer.colour() returns the colour")
unittest
{
	import mocked : Mocker;
	Mocker mocker;
	auto socket = mocker.mock!Socket();
	const player = new HumanPlayer(socket, new Room(1), "hello", "F00");
	assert(player.colour() == "F00");
}
