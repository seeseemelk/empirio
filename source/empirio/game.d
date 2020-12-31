module empirio.game;

import empirio.room;

/**
Manages a set of rooms and players.
*/
class Game
{
    private Room[int] _rooms;

    /**
    Gets a room. If the room does not exist, it will be created.
    Params:
        id = The ID of the room.
        settings = The settings to use when creating a room.
    */
    Room getRoom(int id, RoomSettings settings = RoomSettings())
    {
        return _rooms.require(id, new Room(id, settings));
    }
}

@("Game.getRoom() creates a room if one does not exist")
unittest
{
    auto game = new Game;
    const room = game.getRoom(5);
    assert(room.id == 5);
}

@("Game.getRoom() returns an existing room if one exists")
unittest
{
    auto game = new Game;
    const roomA = game.getRoom(5);
    const roomB = game.getRoom(5);
    assert(roomA is roomB);
}
