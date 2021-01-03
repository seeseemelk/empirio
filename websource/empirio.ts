import {
	ClientPlayPacket, ServerErrorPacket, ServerStartPacket,
	ServerPlayerJoinPacket, ServerTileChangePacket, ServerMapLoadedPacket,
	ServerPlayerLostPacket
} from './net/packets';
import { Connection, ConnectionHandler } from './net/connection';
import { Player } from './player';
import { UI } from './ui/common';
import { LobbyUI } from './ui/lobby';
import { GameUI } from './ui/game';
import { Room } from './room';

class Empirio implements ConnectionHandler, LobbyUI.Handler,
	UI.MouseDragListener, GameUI.Handler
{
	private readonly _connection: Connection;
	private _room: Room | null;
	private _playerName: string;
	private _playerColour: string;

	constructor()
	{
		this._connection = new Connection(this);
	}

	start()
	{
		console.log("Starting...");
		UI.init(this);
		LobbyUI.init(this);
		GameUI.init(this);
		LobbyUI.disablePlay();
		UI.show(UI.Screen.lobby);
		this._connection.connect();
		UI.hideSpinner();
		console.log("Started!");
	}

	onSocketError(reason: string)
	{
		console.log("Socket error: " + reason);
		UI.showErrorPopup("Connection to the server was lost");
	}

	onSocketClosed()
	{
		console.log("Socket closed");
		UI.showErrorPopup("Connection to the server was lost");
	}

	onOpen()
	{
		LobbyUI.enablePlay();
	}

	onPlayClicked(state: LobbyUI.State)
	{
		LobbyUI.hideErrorMessage();
		UI.showSpinner();
		let packet: ClientPlayPacket = new ClientPlayPacket();
		packet.colour = state.colour;
		packet.username = state.username;
		packet.room = state.room;
		this._playerColour = state.colour;
		this._playerName = state.username;
		this._connection.send(packet);
	}

	onDrag(event: UI.MouseDragEvent)
	{
		if (this._room)
			this._room.onDrag(event);
	}

	onError(packet: ServerErrorPacket)
	{
		console.log("Received the error: " + packet.message);
		UI.hideSpinner();
		if (!packet.recoverable || UI.screen() == UI.Screen.game)
			UI.showErrorPopup(packet.message);
		else
			LobbyUI.showErrorMessage(packet.message);
	}

	onStart(packet: ServerStartPacket)
	{
		GameUI.setRoom(packet.room);
		let player = new Player(packet.playerId, this._playerName,
		                        this._playerColour);
		this._room = new Room(this._connection, packet, player);
		UI.show(UI.Screen.game);
	}

	onPlayerJoined(packet: ServerPlayerJoinPacket)
	{
		if (this._room)
			this._room.onPlayerJoined(packet);
	}

	onTileChange(packet: ServerTileChangePacket)
	{
		if (this._room)
			this._room.onTileChange(packet);
	}

	onMapLoaded(_: ServerMapLoadedPacket)
	{
		UI.hideSpinner();
	}

	onPlayerLost(packet: ServerPlayerLostPacket)
	{
		if (this._room)
			this._room.onPlayerLost(packet);
	}

    onUpdate(): void
	{
		if (this._room)
			this._room.onUpdate();
    }
}

window.onload = () =>
{
	let game = new Empirio();
	game.start();
}
