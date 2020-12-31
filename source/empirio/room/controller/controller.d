module empirio.room.controller.controller;

import empirio.player;
import empirio.room.observer;
import empirio.room.tile;

/**
A class which controls a room.
*/
interface RoomController : RoomObserver
{
    /**
    Executed when a tile is clicked.
    */
    void onTileClicked(Player player, Tile tile);
}
