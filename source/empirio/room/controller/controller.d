module empirio.room.controller.controller;

import empirio.player;
import empirio.room;
import empirio.room.observer;
import empirio.room.tile;

/**
A class which controls a room.
*/
interface RoomController : RoomObserver
{
	/**
	Sets the room to manage.
	Params:
		room = The room to manage.
	*/
	void room(Room room);

    /**
    Executed when a tile is clicked.
    */
    void onTileClicked(Player player, Tile tile);
}
