module empirio.room.observer;

import empirio.player.player;

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
}
