import { Player } from './player';

/**
 * A single tile on a field.
 */
export class Tile
{
	private readonly _element: HTMLTableDataCellElement;
	private _strength: number = 0;

	/**
	 * Creates a new tile.
	 * @param element The element controlling the tile.
	 */
	constructor(element: HTMLTableDataCellElement)
	{
		this._element = element;
	}

	/**
	 * Sets the colour of the tile.
	 * @param colour The colour of the tile.
	 */
	setColour(colour: string): void
	{
		console.log("Colour of " + this._element.id + ": " + colour);
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
