module empirio.room.observer;

import empirio.player.player;
import empirio.room.tile;

/**
A class which observes changes in a room.
*/
interface RoomObserver
{
    /**
    Executed when a player joins a room.
    Params:
        player = The player who joined the room.
    */
    void onPlayerJoined(Player player);

	/**
	Executed when a tile was changed.
	Params:
		oldTile = The old tile.
		newTile = The new tile.
	*/
	void onTileChanged(Tile oldTile, Tile newTile) @safe;

	/**
	Executed when a player lost.
	Params:
		player = The player who lost.
	*/
	void onPlayerLost(Player player);
}
