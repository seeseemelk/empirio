import { ServerErrorPacket, ServerStartPacket, ServerPlayerJoinPacket,
         ServerTileChangePacket, ServerMapLoadedPacket } from './packets';

/**
 * Acts on events from a connection.
 */
export interface ConnectionHandler
{
	/**
	 * Executed when a connection has been established.
	 */
	onOpen(): void;

	/**
	 * Executed when a socket error occurred.
	 */
	onSocketError(reason: string): void;

	/**
	 * Executes when an error packet is received.
	 */
	onError(packet: ServerErrorPacket): void;

	/**
	 * Executed when a start packet is received.
	 */
	onStart(packet: ServerStartPacket): void;

	/**
	 * Executed when a player joined.
	 */
	onPlayerJoined(packet: ServerPlayerJoinPacket): void;

	/**
	 * Executed when a player joined.
	 */
	onTileChangePacket(packet: ServerTileChangePacket): void;

	/**
	 * Executed when the map has been loaded completely.
	 */
	onMapLoadedPacket(packet: ServerMapLoadedPacket): void;
}

/**
 * Manages the web socket connection to the backend.
 */
export class Connection
{
	private _socket: WebSocket;
	private readonly _handler: ConnectionHandler;

	/**
	 * Creates a new connection object.
	 * @param handler The handler which will handle connection events.
	 */
	constructor(handler: ConnectionHandler)
	{
		this._handler = handler;
	}

	/**
	 * Connects to the websocket endpoint.
	 */
	connect()
	{
		this._socket = new WebSocket('ws://' + location.host + "/socket");

		this._socket.onopen = () => this.onOpen();
		this._socket.onerror = (event) => this.onError(event);
		this._socket.onmessage = (event) => this.onMessage(event);
	}

	send(packet: any)
	{
		let json = JSON.stringify(packet);
		this._socket.send(json);
	}

	private onOpen()
	{
		console.log("Socket Connected");
		this._handler.onOpen();
	}

	private onError(event: Event)
	{
		console.log("Socket error");
		this._handler.onSocketError(event.toString());
	}

	private onMessage(event: MessageEvent)
	{
		let data = JSON.parse(event.data);
		if (!data || !data.type)
		{
			this._handler.onSocketError("Bad packet received");
			return;
		}
		switch (data.type)
		{
		case "error":
			this._handler.onError(<ServerErrorPacket> data);
			break;
		case "start":
			this._handler.onStart(<ServerStartPacket> data);
			break;
		case "playerJoin":
			this._handler.onPlayerJoined(<ServerPlayerJoinPacket> data);
			break;
		case "tileChange":
			this._handler.onTileChangePacket(<ServerTileChangePacket> data);
			break;
		case "mapLoaded":
			this._handler.onMapLoadedPacket(<ServerMapLoadedPacket> data);
			break;
		}
	}
}
