module empirio.game;

import empirio.room;

import std.algorithm;
import std.range;
import std.random;
import std.array;

/**
Manages a set of rooms and players.
*/
class Game
{
    private Room[int] _rooms;

    /**
    Gets a room. If the room does not exist, it will be created.
    Params:
        id = The ID of the room.
        settings = The settings to use when creating a room.
    */
    Room getRoom(int id, RoomSettings settings = RoomSettings())
    {
        return _rooms.require(id, new Room(id, settings));
    }

	/**
	Gets a random room. If a room exists with the given settings, that room will
	be joined. If no room exists with the given settings, one will be created.
	Params:
		settings = The settings to use when creating a room.
	*/
	Room getRandomRoom(RoomSettings settings = RoomSettings())
	{
		foreach (room; _rooms.byValue)
		{
			if (room.settings == settings)
				return room;
		}
		return createRandomRoom(settings);
	}

	/**
	Creates a random room. The ID of the room will be one that is not yet used.
	Params:
		settings = The settings to use when creating a room.
	*/
	private Room createRandomRoom(RoomSettings settings)
	{
		auto ids = iota(1, 1001).filter!(id => id !in _rooms).array();
		const id = choice(ids);
		auto room = new Room(id, settings);
		_rooms[id] = room;
		return room;
	}
}

@("Game.getRoom() creates a room if one does not exist")
unittest
{
    auto game = new Game;
    const room = game.getRoom(5);
    assert(room.id == 5);
}

@("Game.getRoom() returns an existing room if one exists")
unittest
{
    auto game = new Game;
    const roomA = game.getRoom(5);
    const roomB = game.getRoom(5);
    assert(roomA is roomB);
}

@("Game.getRandomRoom() returns a room with the same settings")
unittest
{
	auto game = new Game;
	const roomA = game.getRoom(123);
	const roomB = game.getRandomRoom();
	assert(roomA is roomB);
}

@("Game.getRandomRoom() returns a new room with different settings")
unittest
{
	auto game = new Game;
	RoomSettings settingsA;
	RoomSettings settingsB;
	settingsA.width = 10;
	settingsB.width = 20;
	const roomA = game.getRoom(123, settingsA);
	const roomB = game.getRandomRoom(settingsB);
	const roomC = game.getRandomRoom(settingsB);
	assert(roomA !is roomB);
	assert(roomC is roomB);
}
