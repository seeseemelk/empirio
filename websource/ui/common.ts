export namespace UI
{
	let g_screen: Screen;
	let g_lobby: HTMLElement;
	let g_game: HTMLElement;
	let g_mouseDrag: MouseDragEvent;
	let g_mouseDragListener: MouseDragListener;

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

	/**
	 * Initialises the UI.
	 */
	export function init(listener: MouseDragListener): void
	{
		g_mouseDrag = new MouseDragEvent();
		g_mouseDragListener = listener;
		g_lobby = document.getElementById('menu')!;
		g_game = document.getElementById('game')!;

		show(Screen.lobby);

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
			g_mouseDrag.dragging = false;
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
}
