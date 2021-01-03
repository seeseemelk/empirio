import { Player } from './player';

/**
 * Describes the type of a tile.
 */
export enum TileType
{
	unowned,
	owned,
	capital
}

/**
 * A single tile on a field.
 */
export class Tile
{
	private readonly _element: HTMLTableDataCellElement;
	private readonly _x: number;
	private readonly _y: number;
	private _strength: number = 0;
	private _type: TileType;

	/**
	 * Creates a new tile.
	 * @param element The element controlling the tile.
	 */
	constructor(element: HTMLTableDataCellElement, x: number, y: number)
	{
		this._element = element;
		this._x = x;
		this._y = y;

		this.setTileType(TileType.unowned);
	}

	/**
	 * Gets the X coordinate of the tile.
	 */
	x(): number
	{
		return this._x;
	}

	/**
	 * Gets the Y coordinate of the tile.
	 */
	y(): number
	{
		return this._y;
	}

	/**
	 * Gets the type of tile.
	 */
	tileType(): TileType
	{
		return this._type;
	}

	/**
	 * Sets the type of tile.
	 */
	setTileType(type: TileType): void
	{
		this._type = type;
		switch (type)
		{
		case TileType.unowned:
			this._element.className = 'tileUnowned';
			break;
		case TileType.owned:
			this._element.className = 'tileOwned';
			break;
		case TileType.capital:
			this._element.className = 'tileCapital';
			break;
		}
	}

	/**
	 * Sets the colour of the tile.
	 * @param colour The colour of the tile.
	 */
	setColour(colour: string): void
	{
		this._element.style.backgroundColor = "#" + colour;
	}

	/**
	 * Sets the owner the tile.
	 */
	setOwner(player: Player): void
	{
		this.setColour(player.colour);
	}

	/**
	 * Sets the strength of the tile.
	 */
	setStrength(strength: number): void
	{
		this._strength = strength;
		if (strength == 0)
			this._element.innerText = '';
		else
			this._element.innerText = strength.toString();
	}

	/**
	 * Gets the strength of the tile.
	 */
	strength(): number
	{
		return this._strength;
	}

	/**
	 * Gets the TD element.
	 */
	element(): HTMLTableDataCellElement
	{
		return this._element;
	}
}
