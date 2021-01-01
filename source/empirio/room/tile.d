module empirio.room.tile;

import empirio.player;

import optional;

/**
Describes a tile in the room.
*/
struct Tile
{
    /// The X-coordinate of the tile.
    uint x;

    /// The Y-coordinate of the tile.
    uint y;

	/// The owner of the tile.
	Optional!Player owner;

	/// The strength of the tile.
	int strength;

	/// The type of tile.
	TileType type = TileType.unowned;
}

/**
Describes the type of a tile.
*/
enum TileType
{
	unowned,
	owned,
	capital,
}
