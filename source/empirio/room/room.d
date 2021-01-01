module empirio.room.room;

import empirio.player;
import empirio.room.controller;
import empirio.room.controller.classic;
import empirio.room.observer;
import empirio.room.tile;

import optional;
import std.algorithm;

/**
Contains the settings set at creation of a room.
*/
struct RoomSettings
{
    /// The width of the room.
    int width = 20;

    /// The height of the room.
    int height = 20;
}

/**
An empirio room.
*/
class Room
{
    private immutable int _id;
    private immutable RoomSettings _settings;
    private Player[] _players;
    private RoomController _controller;
    private RoomObserver[] _observers;
    private Tile[][] _tiles;

    /**
    Creates a new room.
    Params:
        id = The id of the room.
        settings = The settings to create the room with.
    */
    this(int id, RoomSettings settings = RoomSettings())
    {
        _id = id;
        _settings = settings;
        _tiles = new Tile[][](settings.height, settings.width);

		foreach (y, ref row; _tiles)
		{
			foreach (x, ref tile; row)
			{
				tile.x = cast(uint) x;
				tile.y = cast(uint) y;
				tile.type = TileType.unowned;
			}
		}

        _controller = new ClassicController;

		_controller.room = this;
    }

    /**
    Gets the ID of the room.
    */
    int id() const pure
    {
        return _id;
    }

    /**
    Gets the settings used when creating the room.
    */
    immutable(RoomSettings) settings() const pure
    {
        return _settings;
    }

    /**
    Gets the room controller.
    */
    RoomController controller()
    {
        return _controller;
    }

    /**
    Gets a tile.
    */
    Tile getTile(int x, int y)
    {
        Tile tile = _tiles[x][y];
        tile.x = x;
        tile.y = y;
        return tile;
    }

    /**
    Sets a tile.
    */
    void setTile(Tile tile)
    {
		Tile oldTile = _tiles[tile.x][tile.y];
		if (tile != oldTile)
			observers.each!(observer => observer.onTileChanged(oldTile, tile));
        _tiles[tile.x][tile.y] = tile;
    }

    /**
    Gets the players which are in the room.
    */
    Player[] players()
    {
        return _players;
    }

    /**
    Adds a player to the room.
    */
    void addPlayer(Player player)
    {
        _players ~= player;
        foreach (observer; _observers)
            observer.onPlayerJoined(player);
		_controller.onPlayerJoined(player);
    }

    /**
    Gets the observers which are observing the room.
    */
    RoomObserver[] observers()
    {
        return _observers;
    }

    /**
    Adds an observer to the room.
    Params:
        observer = The observer to add.
    */
    void addObserver(RoomObserver observer)
    {
        _observers ~= observer;
    }

	/**
	Finds a tile which satifies the predicate.
	Params:
		predicate = A predicate the tile must satisfy.
	*/
	Optional!Tile findTile(bool delegate(Tile) predicate)
	{
		foreach (row; _tiles)
		{
			foreach (tile; row)
			{
				if (predicate(tile))
					return some(tile);
			}
		}
		return no!Tile;
	}

	/**
	Finds an empty tile.
	*/
	Optional!Tile findEmptyTile()
	{
		return findTile(tile => tile.type == TileType.unowned);
	}

	/**
	Find all tiles which satisfy a predicate.
	Params:
		predicate = A predicate which a tile must satisfy.
	*/
	auto findAll(bool delegate(Tile) predicate)
	{
		return _tiles
			.joiner()
			.filter!predicate;
	}

	/**
	Finds all empty tiles.
	*/
	auto findEmptyTiles()
	{
		return findAll(tile => tile.type == TileType.unowned);
	}
}

@("Room.controller() returns the controller of the room")
unittest
{
    Room room = new Room(0);
    assert(room.controller !is null);
}

@("Room.id() returns the id of the room")
unittest
{
    Room room = new Room(1337);
    assert(room.id == 1337);
}

@("Room.players() returns the players in the room")
unittest
{
    import mocked : Mocker;
    Mocker mocker;
    Player player = mocker.mock!Player();
    Room room = new Room(0);
    room.addPlayer(player);
    assert(room.players == [player]);
}

@("Room.observers() returns all observers")
unittest
{
    import mocked : Mocker;
    Mocker mocker;
    RoomObserver observer = mocker.mock!RoomObserver();
    Room room = new Room(0);
    room.addObserver(observer);
    assert(room.observers.length == 2);
    assert(room.observers[1] == observer);
}


@("Observers are notified when a player joins")
unittest
{
    import mocked : Mocker;
    Mocker mocker;
    auto observer = mocker.mock!RoomObserver();
    auto player = mocker.mock!Player();
    Room room = new Room(0);
    observer.expect.onPlayerJoined(player);
    room.addObserver(observer);
    room.addPlayer(player);
}
