module empirio.room.controller.controller;

import empirio.player;
import empirio.room;
import empirio.room.observer;
import empirio.room.tile;

/**
A class which controls a room.
*/
interface RoomController
{
	/**
	Sets the room to manage.
	Params:
		room = The room to manage.
	*/
	void room(Room room);

	/**
	Releases any allocated releases owned by the controller.
	*/
	void close();

    /**
    Executed when a tile is clicked.
	Params:
		player = The player who joined.
		tile = The tile that was clicked.
		power = The power the tile was attacked with.
    */
    bool onTileClicked(Player player, Tile tile, int power);

	/**
	Executed when a player joined.
	Params:
		player = The player who joined.
	*/
	void onPlayerJoined(Player player);
}
