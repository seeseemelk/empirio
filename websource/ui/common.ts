export namespace UI
{
	export class MouseDragEvent
	{
		down: boolean = false;
		dragging: boolean = false;
		startX: number;
		startY: number;
		x: number;
		y: number;

		/**
		 * Sets the start X and Y coordinates so that the deltas are zero.
		 */
		zero(): void
		{
			this.startX = this.x;
			this.startY = this.y;
		}

		/**
		 * Gets the amount the mouse moved over the X-axis since the beginning
		 * of the drag operation.
		 */
		dx(): number
		{
			return this.x - this.startX;
		}

		/**
		 * Gets the amount the mouse moved over the Y-axis since the beginning
		 * of the drag operation.
		 */
		dy(): number
		{
			return this.y - this.startY;
		}

		/**
		 * Gets the total distance the mouse cursor has moved since the
		 * beginning of the drag operation..
		 */
		distance(): number
		{
			const dx = this.dx();
			const dy = this.dy();
			return Math.sqrt(dx*dx + dy*dy);
		}
	}

	/**
	 * Listens to mouse drag events.
	 */
	export interface MouseDragListener
	{
		/**
		 * Executed when the mouse is dragging.
		 * @param event The dragging event.
		 */
		onDrag(event: MouseDragEvent): void;
	}

	/**
	 * Describes all possible screens.
	 */
	export enum Screen
	{
		lobby,
		game
	}

	let g_screen: Screen;
	let g_lobby: HTMLElement;
	let g_game: HTMLElement;
	let g_spinner: HTMLDivElement;
	let g_spinnerImage: HTMLImageElement;
	let g_mouseDrag: MouseDragEvent = new MouseDragEvent();
	let g_mouseDragListener: MouseDragListener;
	let g_errorPopup: HTMLDivElement;
	let g_errorPopupReason: HTMLSpanElement;

	/**
	 * Initialises the UI.
	 */
	export function init(listener: MouseDragListener): void
	{
		g_mouseDragListener = listener;
		g_lobby = document.getElementById('menu')!;
		g_game = document.getElementById('game')!;
		g_errorPopup = <HTMLDivElement> document.getElementById('errorPopup')!;
		g_errorPopupReason = <HTMLSpanElement> document.getElementById('errorPopupReason')!;
		g_spinner = <HTMLDivElement> document.getElementById('spinner')!;
		g_spinnerImage = <HTMLImageElement> document.getElementById('spinnerImage')!;

		show(Screen.lobby);

		let rotation = 0;
		window.setInterval(() =>
		{
			g_spinnerImage.style.rotate = rotation + 'deg';
			rotation += 45;
		}, 100);

		window.onselectstart = (event: Event) =>
		{
			if (g_screen != Screen.game)
				return true;
			g_mouseDrag.down = true;
			event.stopPropagation();
			return false;
		}

		window.onmousedown = (event: MouseEvent) =>
		{
			if (g_screen != Screen.game)
				return true;
			g_mouseDrag.down = true;
			g_mouseDrag.startX = event.clientX;
			g_mouseDrag.startY = event.clientY;
			return false;
		};

		window.onmouseup = (event: MouseEvent) =>
		{
			if (g_screen != Screen.game)
				return true;
			g_mouseDrag.down = false;
			event.stopPropagation();
			return false;
		};

		window.onmousemove = (event: MouseEvent) =>
		{
			if (g_screen != Screen.game)
				return true;

			if (g_mouseDrag.down)
			{
				g_mouseDrag.x = event.clientX;
				g_mouseDrag.y = event.clientY;
				if (g_mouseDrag.dragging || g_mouseDrag.distance() >= 8)
				{
					g_mouseDrag.dragging = true;
					g_mouseDragListener.onDrag(g_mouseDrag);
					g_mouseDrag.zero();
					event.stopPropagation();
				}
			}
			return false;
		};

		window.onclick = (_: MouseEvent) =>
		{
			if (g_screen != Screen.game)
				return true;
			if (!g_mouseDrag.down && g_mouseDrag.dragging)
				g_mouseDrag.dragging = false;
			return false;
		};
	}

	/**
	 * Gets whether the mouse is currently being dragged or not.
	 */
	export function isDragging(): boolean
	{
		return g_mouseDrag.dragging;
	}

	/**
	 * Gets the currently shown screen.
	 */
	export function screen(): Screen
	{
		return g_screen;
	}

	/**
	 * Shows a specific screen.
	 * @param screen The screen to show.
	 */
	export function show(screen: Screen): void
	{
		g_screen = screen;
		g_lobby.style.display = (screen === Screen.lobby) ? 'auto' : 'none';
		g_game.style.display = (screen === Screen.game) ? 'block': 'none';
	}

	/**
	 * Shows the loading spinner.
	 */
	export function showSpinner(): void
	{
		g_spinner.style.display = 'flex';
	}

	/**
	 * Hides the loading spinner.
	 */
	export function hideSpinner(): void
	{
		g_spinner.style.display = 'none';
	}

	/**
	 * Shows an error popup.
	 */
	export function showErrorPopup(reason: string): void
	{
		g_errorPopup.style.display = 'flex';
		g_errorPopupReason.textContent = reason;
	}
}
