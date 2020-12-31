module empirio.player.player;

import std.uuid;

/**
Describes a person who is participating in a match.
*/
interface Player
{
    /**
    Gets the UUID of the player.
    */
    UUID uuid() const pure;

    /**
    Gets the username of the player.
    */
    string name() const pure;

    /**
    Gets the colour of the player.
    */
    string colour() const pure;
}
