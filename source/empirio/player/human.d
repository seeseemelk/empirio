module empirio.player.human;

import empirio.net.socket;
import empirio.player;
import empirio.room;

import std.uuid;

/**
Describes a Player who is controlled by a human.
*/
final class HumanPlayer : Player, RoomObserver
{
    private Room _room;
    private Socket _socket;
    private string _colour;
    private string _name;
    private UUID _uuid;

    /**
    Creates a new human player.
    Params:
        socket = The socket to communicate over.
        room = The room in which the player will play.
        name = The name of the human player.
        colour = The colour of the player.
    */
    this(Socket socket, Room room, string name, string colour)
    {
        _colour = colour;
        _name = name;
        _room = room;
        _socket = socket;
        _uuid = randomUUID();

        _room.addPlayer(this);
        _room.addObserver(this);
    }

    override UUID uuid() const
    {
        return _uuid;
    }

    override string name() const
    {
        return _name;
    }

    override string colour() const
    {
        return _colour;
    }
}

@("HumanPlayer.name() returns the name")
unittest
{
    import mocked : Mocker;
    Mocker mocker;
    auto socket = mocker.mock!Socket();
    const player = new HumanPlayer(socket, "hello", "F00");
    assert(player.name() == "hello");
}

@("HumanPlayer.colour() returns the colour")
unittest
{
    import mocked : Mocker;
    Mocker mocker;
    auto socket = mocker.mock!Socket();
    const player = new HumanPlayer(socket, "hello", "F00");
    assert(player.colour() == "F00");
}
