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

    void onTileClicked(Player player, Tile tile)
    {
    }

    void onPlayerJoined(Player player)
    {
		auto data = new PlayerData;
		_data[player] = data;

		auto capital = _room.findEmptyTiles().array().choice();
		capital.owner = some(player);
		capital.type = TileType.capital;
		capital.strength = 100;
		data.capital = capital;
		_room.setTile(capital);
    }

	/**
	Gets the game data of a specific player.
	*/
	private PlayerData data(Player player)
	{
		return _data[player];
	}
}

/**
Stores data relevant to a specific player.
*/
private class PlayerData
{
	Tile capital;
}
