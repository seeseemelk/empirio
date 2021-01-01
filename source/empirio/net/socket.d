module empirio.net.socket;

import std.json;

/**
Describes a communication link to a client.
*/
interface Socket
{
    /**
    Send a json string to a client.
    */
    void send(string str);

	/**
	Sends a packet to a client.
	Params:
		packet = The packet to send.
	*/
	void send(Packet)(Packet packet)
	if (is(Packet == struct))
	{
		import vibe.data.json : serializeToJson;
		send(serializeToJson(packet).toString());
	}
}
