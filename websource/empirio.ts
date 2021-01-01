import { ClientPlayPacket, ServerErrorPacket, ServerStartPacket } from './net/packets';
import { Connection, ConnectionHandler } from './net/connection';
import { Player } from './player';
import { UI } from './ui/common';
import { LobbyUI } from './ui/lobby';
import { GameUI } from './ui/game';
import { Field } from './field';

class Game implements ConnectionHandler, LobbyUI.Handler, UI.MouseDragListener
{
	private readonly _connection: Connection;
	private readonly _player: Player = new Player();
	private _field: Field | null;

	constructor()
	{
		this._connection = new Connection(this);
	}

	start()
	{
		console.log("Starting...");
		UI.init(this);
		LobbyUI.init(this);
		GameUI.init();
		LobbyUI.disablePlay();
		UI.show(UI.Screen.lobby);
		this._connection.connect();
		console.log("Started!");
	}

	onSocketError(reason: string)
	{
		console.log("Socket error: " + reason);
	}

	onError(packet: ServerErrorPacket)
	{
		console.log("Got error: " + packet.message);
	}

	onStart(packet: ServerStartPacket)
	{
		this._player.id = packet.playerId;
		GameUI.setRoom(packet.room);
		this._field = new Field(packet.width, packet.height);
		this._field.show();
		UI.show(UI.Screen.game);
	}

	onOpen()
	{
		LobbyUI.enablePlay();
	}

	onPlayClicked(state: LobbyUI.State)
	{
		let packet: ClientPlayPacket = new ClientPlayPacket();
		packet.colour = state.colour;
		packet.username = state.username;
		packet.room = state.room;
		this._player.colour = state.colour;
		this._connection.send(packet);
	}

	onDrag(event: UI.MouseDragEvent)
	{
		if (this._field)
			this._field.onDrag(event);
	}
}

window.onload = () =>
{
	let game = new Game();
	game.start();
}
