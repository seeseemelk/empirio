import { ServerStartPacket } from './net/packets';
import { Connection } from './net/connection';
import { Field, FieldCallback } from './field';
import { Player } from './player';
import { UI } from './ui/common';
import { GameUI } from './ui/game';
import {
	ClientClickPacket,
	ServerTileChangePacket, ServerPlayerJoinPacket, ServerPlayerLostPacket
} from './net/packets';
import { Tile } from './tile';

enum State
{
	playing,
	lost
}

export class Room implements UI.MouseDragListener, GameUI.Handler, FieldCallback
{
	private readonly _field: Field;
	private readonly _player: Player;
	private readonly _connection: Connection;
	private _state: State = State.playing;
	private _powerStartTime: number;
	private _players: Map<string, Player> = new Map<string, Player>();

	constructor(connection: Connection, packet: ServerStartPacket, player: Player)
	{
		this._field = new Field(packet.width, packet.height, this);

		this._player = player;
		this.addPlayer(this._player);

		this._connection = connection;

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
		tile.setOwner(owner);
		tile.setStrength(packet.strength);
		tile.setTileType(packet.tileType);
	}

    onUpdate(): void
	{
		switch (this._state)
		{
		case State.playing:
			const power = this.power();
			GameUI.setPower(power);
			break;
		case State.lost:
			break;
		}
    }

    onTileClicked(tile: Tile): void
	{
		this._powerStartTime = Date.now();
		let packet = new ClientClickPacket();
		packet.x = tile.x();
		packet.y = tile.y();
		this._connection.send(packet);
    }

	onPlayerLost(packet: ServerPlayerLostPacket): void
	{
		let player = this.getPlayer(packet.player);
		if (player == this._player)
		{
			this._state = State.lost;
			GameUI.setPower("You died");
		}
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
