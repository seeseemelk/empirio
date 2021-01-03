module empirio.net.socket;

import std.json;

/**
Describes a communication link to a client.
*/
interface Socket
{
    /**
    Send a json string to the client.
    */
    void send(string str) @safe;

	/**
	Sends a recoverable error to the client.
	*/
	void sendError(string message) @safe;

	/**
	Sends an irrecoverable error to the client.
	*/
	void sendFatal(string message) @safe;

	/**
	Sends a packet to the client.
	Params:
		packet = The packet to send.
	*/
	void send(Packet)(Packet packet) @safe
	if (is(Packet == struct))
	{
		import vibe.data.json : serializeToJson;
		import std.exception : assumeWontThrow;
		send(serializeToJson(packet).toString());
	}
}
