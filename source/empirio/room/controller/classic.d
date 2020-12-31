module empirio.room.controller.classic;

import empirio.player;
import empirio.room.controller;
import empirio.room.observer;
import empirio.room.tile;

/**
A room controller which implements the classic style of gameplay.
*/
final class ClassicController : RoomController, RoomObserver
{
    override void onTileClicked(Player player, Tile tile)
    {
    }


    override void onPlayerJoined(Player player)
    {
    }
}
