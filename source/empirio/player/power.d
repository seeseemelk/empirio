module empirio.player.power;

import core.time;

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
		return milliseconds;
    }
}
