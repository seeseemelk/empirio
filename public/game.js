let game = {};

(function()
{
	let table;
	let tableOffset = {x: 0, y: 0};
	let tiles = [];
	let lastClicked = 0;
	let mouse = {
		dragging: false,
		down: false
	};
	let playerId;
	let powerCounter;
	const tileWidth = 32;
	const tileHeight = 32;

	game.start = function(room, startPosition, _playerId)
	{
		playerId = _playerId;
		console.log("Player id: " + playerId);
		game.room = room;
		console.log("Room size is " + room.width + " by " + room.height);
		setupTable();
		centerOnTile(getTile(startPosition.x, startPosition.y));
		setLastClickToNow();

		powerCounter = window.setInterval(updatePower, 10);
		document.getElementById("roomId").innerText = "Room #" + room.id;
	}

	function setupTable()
	{
		table = document.createElement("table");

		for (let iy = 0; iy < game.room.height; iy++)
		{
			const y = iy;
			let row = document.createElement("tr");
			tiles[y] = [];
			for (let ix = 0; ix < game.room.width; ix++)
			{
				const x = ix;
				let tile = document.createElement("td");
				tile.innerText = "";
				tile.onclick = function()
				{
					clickedTile(x, y);
				}
				row.appendChild(tile);
				tiles[y][x] = tile;
			}
			table.appendChild(row);
		}

		table.style.position = "absolute";
		positionTable();

		document.getElementById("table-container").appendChild(table);
	}

	window.onmousedown = function(event)
	{
		if (common.state != "game")
			return true;
		mouse.down = true;
		mouse.lastX = event.clientX;
		mouse.lastY = event.clientY;
	}

	window.onmousemove = function(event)
	{
		if (common.state != "game")
			return true;
		if (mouse.down)
		{
			const deltaX = event.clientX - mouse.lastX;
			const deltaY = event.clientY - mouse.lastY;

			if (mouse.dragging == true || Math.sqrt(deltaX * deltaX + deltaY * deltaY) >= 8)
			{
				mouse.dragging = true;
				tableOffset.x += deltaX;
				tableOffset.y += deltaY;
				mouse.lastX = event.clientX;
				mouse.lastY = event.clientY;
				positionTable();
				event.stopPropagation();
				return false;
			}
		}
	}

	window.onselectstart = function(event)
	{
		if (common.state != "game")
			return true;
		return false;
	}

	window.onmouseup = function(event)
	{
		if (common.state != "game")
			return true;
		mouse.down = false;
		event.stopPropagation();
	}

	window.onclick = function(event)
	{
		if (common.state != "game")
			return true;
		if (!mouse.down && mouse.dragging)
		{
			mouse.dragging = false;
		}
	}

	function positionTable()
	{
		table.style.left = tableOffset.x + "px";
		table.style.top = tableOffset.y + "px";
	}

	function getTile(x, y)
	{
		return tiles[y][x];
	}

	function centerOnTile(tile)
	{
		let rect = tile.getBoundingClientRect();
		centerOn((rect.left + rect.right) * 0.5, (rect.top + rect.bottom) * 0.5);
	}

	function centerOn(x, y)
	{
		tableOffset.x = window.innerWidth * 0.5 + (tableOffset.x - x);
		tableOffset.y = window.innerHeight * 0.5 + (tableOffset.y - y);
		positionTable();
	}

	function clickedTile(x, y)
	{
		if (!mouse.dragging && canAttack(x, y))
		{
			console.log("Clicked tile " + x + ", " + y);
			common.socket.send(JSON.stringify({
				type: "click",
				x: x,
				y: y
			}));
			setLastClickToNow();
		}
	}

	game.updateTile = function(message)
	{
		let x = message.x;
		let y = message.y;
		let strength = message.strength;
		let tile = getTile(x, y);

		if (strength > 0)
		{
			tile.innerText = strength;
			tile.style.backgroundColor = "#" + message.ownerColour;
			tile.setAttribute("playerId", message.ownerId);

			if (message.isCapital)
			{
				tile.title = "Capital of " + message.ownerName;
				markAsCapital(tile);
			}
			else
			{
				tile.title = message.ownerName;
				unmarkAsCapital(tile);
			}
		}
		else
		{
			tile.innerText = "";
			tile.removeAttribute("playerId");
			tile.title = "";
			tile.style.backgroundColor = null;
		}
	}

	game.died = function(message)
	{
		clearInterval(powerCounter);
		document.getElementById("power").innerText = "You Died";
		document.getElementById("roomId").innerText = "Killed by " + message.killerName;
	}

	function markAsCapital(tile)
	{
		tile.style.textDecoration = "underline";
	}

	function unmarkAsCapital(tile)
	{
		tile.style.textDecoration = null;
	}

	function isCapital(tile)
	{
		return tile.style.textDecoration == "underline";
	}

	function getCurrentPower()
	{
		const timeDifference = getCurrentTime() - lastClicked;
		return Math.min(Math.floor(Math.pow(timeDifference / 1000, 2)), 999);
	}

	function getCurrentTime()
	{
		return Date.now();
	}

	function setLastClickToNow()
	{
		lastClicked = getCurrentTime();
	}

	function updatePower()
	{
		document.getElementById("power").innerText = getCurrentPower();
	}

	function canAttack(x, y)
	{
		return (getCurrentPower() > 0) && (isOwnedBySelf(x, y)
			|| isOwnedBySelf(x+1, y) || isOwnedBySelf(x-1, y)
			|| isOwnedBySelf(x, y+1) || isOwnedBySelf(x, y-1));
	}

	function isOwnedBySelf(x, y)
	{
		if (x < 0 || y < 0 || x >= game.room.width || y >= game.room.height)
			return false;
		else
			return getTile(x, y).getAttribute("playerId") == getOwnPlayerId();
	}

	function getOwnPlayerId()
	{
		return playerId;
	}
})();
