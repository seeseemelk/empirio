import { ServerStartPacket } from './net/packets';
import { Field } from './field';
import { Player } from './player';
import { UI } from './ui/common';
import { GameUI } from './ui/game';
import { ServerTileChangePacket, ServerPlayerJoinPacket } from './net/packets';

export class Room implements UI.MouseDragListener, GameUI.Handler
{
	private _field: Field;
	private _player: Player;
	private _powerStartTime: number;
	private _players: Map<string, Player> = new Map<string, Player>();

	constructor(packet: ServerStartPacket, player: Player)
	{
		this._field = new Field(packet.width, packet.height);

		this._player = player;
		this.addPlayer(this._player);

		this._field.show();
		this._powerStartTime = Date.now();
	}

	/**
	Gets the available power.
	*/
	power(): number
	{
		const diff = Date.now() - this._powerStartTime;
		return Math.min(Math.floor(Math.pow(diff / 1000, 2)), 999);
	}

	onDrag(event: UI.MouseDragEvent): void
	{
		this._field.onDrag(event);
	}

	onPlayerJoined(packet: ServerPlayerJoinPacket)
	{
		let player = new Player(packet.id, packet.name, packet.colour);
		this.addPlayer(player);
	}

	onTileChange(packet: ServerTileChangePacket)
	{
		let owner = this.getPlayer(packet.owner);
		if (!owner)
		{
			console.log("Got bad player id");
			return;
		}

		let tile = this._field.get(packet.x, packet.y);
		console.log("Tile at " + packet.x + "," + packet.y + " changed");
		tile.setOwner(owner);
		tile.setStrength(packet.strength);
	}

    onUpdate(): void
	{
		const power = this.power();
		GameUI.setPower(power);
    }

	/**
	 * Adds a player to the list of players in the room.
	 * @param player The player to add.
	 */
	private addPlayer(player: Player): void
	{
		this._players.set(player.id, player);
	}

	/**
	 * Gets a player.
	 * @param id The id of the player.
	 */
	private getPlayer(id: string): Player | undefined
	{
		return this._players.get(id);
	}
}
