module empirio.net.packets;

import empirio.room.tile : TileType;

import std.typecons;
import vibe.data.serialization;

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
    @optional Nullable!int room;
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

/**
A packet which is sent when a player has joined.
*/
struct ServerPlayerJoinPacket
{
	/// The type of the packet.
	string type = "playerJoin";

	/// The name of the player.
	string name;

	/// The ID of the player.
	string id;

	/// The colour of the player.
	string colour;
}

/**
A packet which is sent when a tile has changed.
*/
struct ServerTileChangePacket
{
	/// The type of the packet.
	string type = "tileChange";

	/// The X coordinate of the tile.
	int x;

	/// The Y coordinate of the tile.
	int y;

	/// The ID of the owner. Empty if the tile is not currently owned by anyone.
	@optional Nullable!string owner;

	/// The strength of the tile.
	uint strength;

	/// The type of the tile.
	TileType tileType;
}

/**
A packet which is sent when all tile change packets have been sent.
*/
struct ServerMapLoadedPacket
{
	/// The type of the packet.
	string type = "mapLoaded";
}
