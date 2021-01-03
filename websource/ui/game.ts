export namespace GameUI
{
	/**
	A handler which handles game events.
	*/
	export interface Handler
	{
		/**
		Executed when the UI should be updated.
		*/
		onUpdate(): void;
	}

	let g_container: HTMLDivElement;
	let g_power: HTMLDivElement;
	let g_room: HTMLDivElement;
	let g_handler: Handler;

	/**
	 * Initialises the game UI.
	 */
	export function init(handler: Handler): void
	{
		g_container = <HTMLDivElement> document.getElementById('table-container')!;
		g_power = <HTMLDivElement> document.getElementById('power')!;
		g_room = <HTMLDivElement> document.getElementById('roomId')!;
		g_handler = handler;

		window.setInterval(() =>
		{
			g_handler.onUpdate();
		}, 10);
	}

	/**
	 * Removes any content shown on the game screen..
	 */
	export function clearContent(): void
	{
		while (g_container.firstChild)
			g_container.removeChild(g_container.firstChild);
	}

	/**
	 * Sets the content of the game screen.
	 */
	export function setContent(content: HTMLElement): void
	{
		clearContent();
		g_container.appendChild(content);
	}

	/**
	 * Sets the power level of the user.
	 */
	export function setPower(power: number | string): void
	{
		g_power.innerText = power.toString();
	}

	/**
	 * Sets the room ID.
	 */
	export function setRoom(room: number): void
	{
		g_room.innerText = "Room #" + room.toString();
	}
}
