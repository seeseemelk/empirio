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
	let g_spinner: HTMLImageElement;

	/**
	 * Initialises the game UI.
	 */
	export function init(handler: Handler): void
	{
		g_container = <HTMLDivElement> document.getElementById('table-container')!;
		g_power = <HTMLDivElement> document.getElementById('power')!;
		g_room = <HTMLDivElement> document.getElementById('roomId')!;
		g_spinner = <HTMLImageElement> document.getElementById('smallSpinnerImage')!;
		g_handler = handler;

		window.setInterval(() =>
		{
			g_handler.onUpdate();
		}, 10);

		let rotation = 0;
		window.setInterval(() =>
		{
			g_spinner.style.rotate = rotation + 'deg';
			rotation += 45;
		}, 100);
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
		g_power.textContent = power.toString();
	}

	/**
	 * Sets the room ID.
	 */
	export function setRoom(room: number): void
	{
		g_room.textContent = "Room #" + room.toString();
	}

	/**
	 * Shows the small spinner and hides the power indiciator.
	 */
	export function showSpinner(): void
	{
		g_power.style.display = 'none';
		g_spinner.style.display = 'inline';
	}

	/**
	 * Hides the small spinner and shows the power indicator.
	 */
	export function hideSpinner(): void
	{
		g_power.style.display = 'block';
		g_spinner.style.display = 'none';
	}
}
