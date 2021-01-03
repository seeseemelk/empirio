import { TileType } from '../tile';

export class ClientPlayPacket
{
	type: string = 'play';
	username: string;
	colour: string;
	room: number | null;
}

export class ClientClickPacket
{
	type: string = 'click';
	x: number;
	y: number;
}

export class ServerErrorPacket
{
	message: string;
	recoverable: boolean;
}

export class ServerStartPacket
{
	room: number;
	width: number;
	height: number;
	playerId: string;
}

/**
 * A packet which is sent when a player has joined.
 */
export class ServerPlayerJoinPacket
{
	name: string;
	id: string;
	colour: string;
}

/**
 * A packet which is sent when a tile has changed.
 */
export class ServerTileChangePacket
{
	x: number;
	y: number;
	owner: string;
	strength: number;
	tileType: TileType;
}

/**
 *A packet which is sent when all tile change packets have been sent.
 */
export class ServerMapLoadedPacket
{
}

/**
 * A packet which is sent when a player lost.
 */
export class ServerPlayerLostPacket
{
	player: string;
}
