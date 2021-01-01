import { GameUI } from './ui/game';
import { UI } from './ui/common';
import { Tile } from './tile';

/**
 * A field of many tiles.
 */
export class Field implements UI.MouseDragListener
{
	private readonly _width: number;
	private readonly _height: number;
	private readonly _table: HTMLTableElement;
	private readonly _tiles: Tile[][];
	private _x: number = 0;
	private _y: number = 0;

	constructor(width: number, height: number)
	{
		this._width = width;
		this._height = height;
		this._tiles = this.createTiles();
		this._table = this.createTable();
	}

	/**
	 * Gets the width of the field.
	 */
	width(): number
	{
		return this._width;
	}

	/**
	 * Gets the height of the field.
	 */
	height(): number
	{
		return this._height;
	}

	/**
	 * Shows the HTML table.
	 */
	show(): void
	{
		GameUI.setContent(this._table);
	}

	/**
	 * Updates the table.
	 */
	update(): void
	{
		this._table.style.left = this._x + 'px';
		this._table.style.top = this._y + 'px';
	}

	onDrag(event: UI.MouseDragEvent): void
	{
		this._x += event.dx();
		this._y += event.dy();
		this.update();
	}

	/**
	 * Creates a 2D array of tiles.
	 */
	private createTiles(): Tile[][]
	{
		let tiles: Tile[][] = [];
		for (let y = 0; y < this._height; y++)
		{
			let row: Tile[] = [];
			for (let x = 0; x < this._width; x++)
			{
				let element = document.createElement("td");
				row[x] = new Tile(element);
			}
			tiles[y] = row;
		}
		return tiles;
	}

	/**
	 * Creates a HTML table for the field.
	 */
	private createTable(): HTMLTableElement
	{
		let table = document.createElement("table");
		table.style.position = "absolute";
		for (let x = 0; x < this._width; x++)
		{
			let row = document.createElement("tr");
			for (let y = 0; y < this._height; y++)
			{
				let tile = this._tiles[y][x].element();
				tile.innerText = "";
				tile.onclick = () => this.clickedTile(x, y);
				row.appendChild(tile);
			}
			table.appendChild(row);
		}
		return table;
	}

	/**
	 * Executed when a tile is clicked.
	 */
	private clickedTile(_1: number, _2: number): void
	{

	}
}
