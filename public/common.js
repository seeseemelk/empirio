"use strict";
let common = {
	state: "menu",
	socket: null,
	lastClicked: 0,
	errorHandler: () => {},
	responseHandler: () => {},
	onError: null,
	onResponse: null,

	onError: function(callback)
	{
		common.errorHandler = callback;
	}
};

(function()
{
	window.onload = function()
	{
		console.log("JavaScript loaded");
		addClickHandlers();
		startWebsocket();
	}

	function getCell(x, y)
	{
		return document.getElementById(x + ":" + y);
	}

	function addClickHandlers()
	{
		document.getElementById("play-button").onclick = function()
		{
			const playername = document.getElementById("playername").value;
			const colour = document.getElementById("colour").value;
			const room = document.getElementById("room").value;
			play(playername, colour, room);
		}
	}

	function setPlayButtonEnabled(state)
	{
		const button = document.getElementById("play-button");
		button.disabled = !state;
	}

	function error(code, message)
	{
		common.errorHandler(code, message);
	}

	function showError(message)
	{
		const element = document.getElementById("errors");
		element.innerText = message;
		element.style.visibility = "visible";
	}

	function hideError()
	{
		const element = document.getElementById("errors");
		element.innerText = "Errors";
		element.style.visibility = "hidden";
	}

	function play(username, colour, room)
	{
		setPlayButtonEnabled(false);
		hideError();
		console.log("Playing as " + username);

		const playRequest = {
			type: "play",
			username: username,
			colour: colour
		};

		if (room)
		{
			playRequest.room = parseInt(room);
			console.log("Joining room " + room);
		}
		else
			console.log("Joining random room");

		common.onError((code, message) => {
			setPlayButtonEnabled(true);
			showError(message);
		});

		common.socket.send(JSON.stringify(playRequest));
	}

	function startGame(message)
	{
		const room = {
			id: message.room,
			width: message.width,
			height: message.height
		};
		common.state = "game";

		let menuElement = document.getElementById("menu");
		menu.style.display = "none";

		let gameElement = document.getElementById("game");
		gameElement.style.display = "block";
		game.start(room, {x: message.startX, y: message.startY}, message.playerId);
	}

	function startWebsocket()
	{
		let roomId = encodeURIComponent(document.getElementById("room").value);
		let playerId = encodeURIComponent(document.getElementById("playername").value);
		var websocket = new WebSocket('ws://' + location.host + "/socket");

		websocket.onopen = function()
		{
			console.log("Socket connected");
			common.socket = websocket;
			setPlayButtonEnabled(true);
		}

		websocket.onerror = function(error)
		{
			console.log("WebSocket error: " + error);
		}

		websocket.onmessage = function(event)
		{
			var message = JSON.parse(event.data);
			if (message.type == "err")
			{
				error(message.code, message.message);
			}
			else if (message.type == "start")
			{
				startGame(message);
			}
			else if (message.type == "update")
			{
				game.updateTile(message);
			}
			else if (message.type == "died")
			{
				game.died(message)
			}
			else
			{
				console.log("Received unknown packet of type " + message.type);
				console.log(message);
			}
		}
	}
})();

//
// OLD CODE
//
/*
function clicked(x, y)
{
	if (canAttack(x, y) && socket && getCurrentPower() > 0)
	{
		socket.send(JSON.stringify({
			x: x,
			y: y,
			power: getCurrentPower()
		}));
		setLastClickToNow();
	}
}

function canAttack(x, y)
{
	return isOwnedBySelf(x, y) || isOwnedBySelf(x+1, y) || isOwnedBySelf(x-1, y)
		|| isOwnedBySelf(x, y+1) || isOwnedBySelf(x, y-1);
}

function isOwnedBySelf(x, y)
{
	if (x < 0 || y < 0 || x >= roomWidth || y >= roomHeight)
		return false;
	else
	return getCell(x, y).getAttribute("playerId") == getOwnPlayerId();
}

function getOwnPlayerId()
{
	return document.getElementById("playerId").value;
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
*/
