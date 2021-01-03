export namespace LobbyUI
{
	let g_startButton: HTMLButtonElement;
	let g_username: HTMLInputElement;
	let g_colour: HTMLSelectElement;
	let g_room: HTMLInputElement;
	let g_errorMessage: HTMLDivElement;
	let g_handler: Handler;

	/**
	 * Describes the state of the lobby screen.
	 */
	export class State
	{
		username: string;
		colour: string;
		room: number | null;
	}

	/**
	 * Handles UI events.
	 */
	export interface Handler
	{
		/**
		 * Executed when the play button is clicked.
		 */
		onPlayClicked(state: State): void;
	}

	/**
	 * Initialiases the lobby ui.
	 */
	export function init(handler: Handler)
	{
		g_handler = handler;
		g_startButton = <HTMLButtonElement> document.getElementById('play-button')!;
		g_username = <HTMLInputElement> document.getElementById('playername')!;
		g_colour = <HTMLSelectElement> document.getElementById('colour');
		g_room = <HTMLInputElement> document.getElementById('room');
		g_errorMessage = <HTMLDivElement> document.getElementById('smallError');

		g_startButton.addEventListener("click", () =>
		{
			let state = getState();
			g_handler.onPlayClicked(state);
		});
	}

	/**
	 * Gets the current state of the UI.
	 */
	function getState(): State
	{
		let state = new State();
		state.username = g_username.value;
		state.colour = g_colour.value;
		if (g_room.value !== '')
			state.room = parseInt(g_room.value);
		return state;
	}

	/**
	 * Enables the play button.
	 */
	export function enablePlay()
	{
		g_startButton.disabled = false;
	}

	/**
	 * Disables the play button.
	 */
	export function disablePlay()
	{
		g_startButton.disabled = true;
	}

	/**
	 * Shows a small error message.
	 */
	export function showErrorMessage(message: string): void
	{
		g_errorMessage.textContent = message;
		g_errorMessage.style.visibility = 'visible';
	}

	/**
	 * Hides the small error message.
	 */
	export function hideErrorMessage(): void
	{
		g_errorMessage.style.visibility = 'auto';
	}
}
