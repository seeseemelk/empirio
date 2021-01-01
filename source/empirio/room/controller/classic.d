module empirio.room.controller.classic;

import empirio.player;
import empirio.room;
import empirio.room.controller;
import empirio.room.observer;
import empirio.room.tile;

/**
A room controller which implements the classic style of gameplay.
*/
final class ClassicController : RoomController, RoomObserver
{
	private PlayerData[Player] _data;
	private Room _room;

	override void room(Room room)
	{
		_room = room;
	}

    override void onTileClicked(Player player, Tile tile)
    {
    }

    override void onPlayerJoined(Player player)
    {
		auto data = new PlayerData;
		_data[player] = data;

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
