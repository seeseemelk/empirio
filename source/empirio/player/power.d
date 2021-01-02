module empirio.player.power;

import core.time;
import std.algorithm;
import std.math;

/**
Counts the power a player has at any given time.
*/
@safe struct PowerCounter
{
    private MonoTime start;

    /**
    Gets the current power value.
    Returns:
        The current power value.
    */
	long get() const @safe
	{
		return get(time);
	}

	/**
	Gets the time since the last click.
	Returns:
		The time since the last click in milliseconds.
	*/
    long time() const @safe
    {
		immutable now = MonoTime.currTime;
		immutable duration = now - start;
		immutable milliseconds = duration.total!"msecs";
		return milliseconds;
    }

    /**
    Resets the current power value.
    Returns:
        The power value at the time of the reset.
    */
    long reset() @safe
    {
        immutable now = MonoTime.currTime;
		immutable duration = now - start;
		immutable milliseconds = duration.total!"msecs";
        start = now;
		return get(milliseconds);
    }

	/**
	Get the power for a given number of milliseconds.
	*/
	private static uint get(long milliseconds) @safe
	{
		return cast(uint) min(floor(pow(milliseconds / 1000f, 2)), 999);
	}
}

@("PowerCounter.get() returns correct values")
unittest
{
	assert(PowerCounter.get(0) == 0);
	assert(PowerCounter.get(1_000) == 1);
	assert(PowerCounter.get(10_000) == 100);
	assert(PowerCounter.get(40_000) == 999);
}
