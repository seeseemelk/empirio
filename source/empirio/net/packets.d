module empirio.net.packets;

/**
A packet sent when a user wants to join a match.
*/
struct ClientPlayPacket
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
struct ClientClickPacket
{
    /// The X coordinate of the tile.
    int x;

    /// The Y coordinate of the tile.
    int y;
}

/**
A packet which is sent when a player starts a match.
*/
struct ServerStartPacket
{
	/// The type of the packet.
	string type = "start";

	/// The ID of the room.
	int room = 0;

	/// The width of the room.
	int width;

	/// The height of the room.
	int height;

	/// The id of the player.
	string playerId;
}
