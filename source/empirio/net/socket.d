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
}
