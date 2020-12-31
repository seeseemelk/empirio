version(unittest) {}
else
{
	import empirio.game;
	import empirio.net.clientsocket;

	import clid;
	import clid.validate;
	import etc.linux.memoryerror;
	import std.conv;
	import std.uuid;
	import vibe.vibe;

	private:
	final class Empirio
	{
		private Game game = new Game;

		void getSocket(scope WebSocket socket)
		{
			auto socketHandler = new ClientSocket(game);
			auto writer = runTask({ socketHandler.writeLoop(socket); });
			socketHandler.readLoop(socket);
			writer.join();
		}
	}

	struct Config
	{
		@Parameter("port", 'p')
		@Description("The port to use")
		@Validate!isPortNumber int port = 8080;
	}

	void main()
	{

		static if (is(typeof(registerMemoryErrorHandler)))
			registerMemoryErrorHandler();

		auto config = parseArguments!Config;

		auto router = new URLRouter;
		router.registerWebInterface(new Empirio);
		router.get("*", serveStaticFiles("public/"));

		auto settings = new HTTPServerSettings;
		settings.port = cast(ushort) config.port;
		settings.bindAddresses = ["::1", "0.0.0.0"];
		listenHTTP(settings, router);

		string[] args = [];
		runApplication(&args);
	}
}
