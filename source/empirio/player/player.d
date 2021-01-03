module empirio.player.player;

import std.uuid;

/**
Describes a person who is participating in a match.
*/
interface Player
{
    /**
    Gets the ID of the player.
    */
    UUID id() const pure nothrow @safe;

    /**
    Gets the username of the player.
    */
    string name() const pure;

    /**
    Gets the colour of the player.
    */
    string colour() const pure;
}
