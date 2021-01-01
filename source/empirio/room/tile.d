module empirio.room.tile;

import empirio.player;

import optional;

/**
Describes a tile in the room.
*/
struct Tile
{
    /// The X-coordinate of the tile.
    int x;

    /// The Y-coordinate of the tile.
    int y;

	/// The owner of the tile.
	Optional!Player owner;

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
