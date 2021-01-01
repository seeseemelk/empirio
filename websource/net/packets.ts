
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
}

export class ServerStartPacket
{
	room: number;
	width: number;
	height: number;
	playerId: string;
}
