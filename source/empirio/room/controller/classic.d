module empirio.room.controller.classic;

import empirio.player;
import empirio.room;
import empirio.room.controller;
import empirio.room.observer;
import empirio.room.tile;

import optional;
import std.algorithm;
import std.random;
import std.array;

/**
A room controller which implements the classic style of gameplay.
*/
final class ClassicController : RoomController
{
	private PlayerData[Player] _data;
	private Room _room;

	override void room(Room room)
	{
		_room = room;
	}

    override bool onTileClicked(Player player, Tile tile, int power)
    {
		power *= powerMultiplier(player, tile);
		if (power == 0)
			return false;

		tile.owner.match!(
			(owner) => attackOwnedTile(player, owner, tile, power),
			() => attackUnownedTile(player, tile, power)
		);
		return true;
    }

    override void onPlayerJoined(Player player)
    {
		auto data = new PlayerData;
		_data[player] = data;

		auto capital = findCapital();
		capital.owner = some(player);
		capital.type = TileType.capital;
		capital.strength = 100;
		data.capital = capital;
		_room.saveTile(capital);
    }

	version(unittest)
	{
		private int capitalCount = 0;
		/**
		Finds a tile to use as a capital in a deterministic way. Used during
		unit testing.
		*/
		private Tile findCapital()
		{
			return _room.getTile(++capitalCount, 1);
		}
	}
	else
	{
		/**
		Finds a tile to use as a capital.
		*/
		private Tile findCapital()
		{
			return _room.findEmptyTiles().array().choice();
		}
	}

	/**
	Gets the game data of a specific player.
	*/
	private PlayerData data(Player player)
	{
		return _data[player];
	}

	/**
	Calculates the multiplier for an attack on a given tile.
	Params:
		player = The player who will attack.
		tile = The tile to test.
	*/
	private int powerMultiplier(Player player, Tile tile)
	{
		int bonus = 0;
		bonus += isOwnedBy(player, tile.x, tile.y) ? 1 : 0;
		bonus += isOwnedBy(player, tile.x - 1, tile.y) ? 1 : 0;
		bonus += isOwnedBy(player, tile.x + 1, tile.y) ? 1 : 0;
		bonus += isOwnedBy(player, tile.x, tile.y + 1) ? 1 : 0;
		bonus += isOwnedBy(player, tile.x, tile.y - 1) ? 1 : 0;
		return bonus;
	}

	/**
	Checks if a tile is owned by a given player.
	Params:
		player = The player to test for.
		x = The X coordinate of the tile.
		y = The Y coordinate of the tile.
	*/
	private bool isOwnedBy(Player player, int x, int y)
	{
		if (!_room.tileExists(x, y))
			return false;
		auto tile = _room.getTile(x, y);
		return tile.owner.any!(owner => owner == player);
	}

	/**
	Attacks a tile currently owned by another player.
	Params:
		attacker = The player who attacks the tile.
		owner = The player who currently owns the tile.
		tile = The tile to attack.
		power = The power to attack with.
	*/
	private void attackOwnedTile(Player attacker, Player owner, Tile tile, int power)
	{
		if (attacker is owner)
		{
			tile.strength += power;
		}
		else if (tile.strength > power)
		{
			tile.strength -= power;
		}
		else if (tile.strength == power)
		{
			if (tile.type == TileType.capital)
				tile.strength = 1;
			else
			{
				tile.strength = 0;
				tile.owner = no!Player;
				tile.type = TileType.unowned;
			}
		}
		else
		{
			tile.strength = -(tile.strength - power);
			tile.owner = some(attacker);
			if (tile.type == TileType.capital)
				captureCapital(attacker, owner);
			tile.type = TileType.owned;
		}
		_room.saveTile(tile);
	}

	/**
	Attacks a tile currently not owned by anyone.
	Params:
		player = The player to attack as.
		tile = The tile to attack.
		power = The power to attack with.
	*/
	private void attackUnownedTile(Player player, Tile tile, int power)
	{
		tile.owner = some(player);
		tile.strength += power;
		tile.type = TileType.owned;
		_room.saveTile(tile);
	}

	/**
	Captures the capital of one player by another. All tiles of the owner of the
	capital will be given to the attacker.
	Params:
		attacker = The person who attacked the capital.
		owner = The person who owns the capital.
	*/
	private void captureCapital(Player attacker, Player owner)
	{
		_room.findNonEmptyTiles()
			.filter!(tile => tile.owner == owner)
			.each!((tile)
			{
				tile.owner = some(attacker);
				_room.saveTile(tile);
			});
	}
}

/**
Stores data relevant to a specific player.
*/
private class PlayerData
{
	Tile capital;
}

version(unittest)
{
	import mocked;

	struct Test
	{
		Mocker mocker;
		Room room;
		Player player;
		ClassicController controller;

		alias player1 = player;

		auto click(int x, int y, int strength)
		{
			return controller.onTileClicked(player, room.getTile(x, y), strength);
		}
	}

	static Test test()
	{
		Test test;
		test.room = new Room(1);
		test.player = test.mocker.stub!Player();
		test.controller = new ClassicController();
		test.controller.room = test.room;
		test.room.addPlayer(test.player);
		return test;
	}

	@("Cannot click tile diagonally from owned tile")
	unittest
	{
		with (test()) assert(click(0, 0, 10) == false);
	}

	@("Cannot click tile with power 0")
	unittest
	{
		with (test()) assert(click(1, 1, 0) == false);
	}

	@("Clicking on unowned tile close to other tile works.")
	unittest
	{
		with (test())
		{
			assert(click(0, 1, 10) == true);
			assert(room.getTile(0, 1).owner == player);
			assert(room.getTile(0, 1).strength == 10);
			assert(room.getTile(0, 1).type == TileType.owned);
		}
	}

	@("Clicking on capital tile improves strength")
	unittest
	{
		with (test())
		{
			const baseStrength = room.getTile(1, 1).strength;
			assert(click(1, 1, 5) == true);
			assert(room.getTile(1, 1).strength == baseStrength+5);
			assert(room.getTile(1, 1).type == TileType.capital);
		}
	}

	@("Clicking on tile near other owned tiles gives a bonus")
	unittest
	{
		with (test())
		{
			click(1, 0, 10);
			const baseStrength = room.getTile(1, 1).strength;
			assert(click(1, 1, 5) == true);
			assert(room.getTile(1, 1).strength == baseStrength+5*2);
			assert(room.getTile(1, 1).type == TileType.capital);
		}
	}

	@("Attacking a capital with the same power as the capital leaves the capital at 1 strength")
	unittest
	{
		with(test())
		{
			Player player2 = mocker.stub!Player();
			room.addPlayer(player2);
			assert(room.getTile(2, 1).type == TileType.capital);
			assert(room.getTile(2, 1).strength == 100);
			assert(room.getTile(2, 1).owner == player2);
			assert(click(2, 1, 100) == true);
			assert(room.getTile(2, 1).type == TileType.capital);
			assert(room.getTile(2, 1).strength == 1);
			assert(room.getTile(2, 1).owner == player2);
		}
	}

	@("Capturing a capital gives all tiles to the other player")
	unittest
	{
		with(test())
		{
			Player player2 = mocker.stub!Player();
			Player player3 = mocker.stub!Player();
			room.addPlayer(player2);
			room.addPlayer(player3);

			controller.onTileClicked(player2, room.getTile(2, 0), 100);
			controller.onTileClicked(player3, room.getTile(3, 0), 100);
			assert(room.getTile(2, 0).type == TileType.owned);
			assert(room.getTile(2, 0).strength == 100);
			assert(room.getTile(2, 0).owner == player2);

			assert(room.getTile(3, 0).type == TileType.owned);
			assert(room.getTile(3, 0).strength == 100);
			assert(room.getTile(3, 0).owner == player3);

			assert(click(2, 1, 105) == true);

			assert(room.getTile(2, 1).type == TileType.owned);
			assert(room.getTile(2, 1).strength == 5);
			assert(room.getTile(2, 1).owner == player1);

			assert(room.getTile(2, 0).type == TileType.owned);
			assert(room.getTile(2, 0).strength == 100);
			assert(room.getTile(2, 0).owner == player1);

			assert(room.getTile(3, 0).type == TileType.owned);
			assert(room.getTile(3, 0).strength == 100);
			assert(room.getTile(3, 0).owner == player3);
		}
	}
}
