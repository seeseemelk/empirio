module empirio.net.packets;

/**
A packet sent when a user wants to join a match.
*/
@("play")
struct PlayPacket
{
    /// The name of the user.
    string username;

    /// The color of the user.
    string colour;

    /// The room the player is joining.
    int room = 0;
}

/**
A packet which is sent when a player clicked a tile.
*/
@("click")
struct ClickPacket
{
    /// The X coordinate of the tile.
    int x;

    /// The Y coordinate of the tile.
    int y;
}
