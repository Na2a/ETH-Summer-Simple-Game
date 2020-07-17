// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.6.0;

import "@nomiclabs/buidler/console.sol";
import "./Puzzle.sol";

contract Solution {
    Puzzle private puzzle;
    address private player;

    constructor(address puzzleAddress, address playerAddress) public {
        puzzle = Puzzle(puzzleAddress);
        player = playerAddress;
    }

    function run() external  {

        puzzle.right();
        puzzle.up();
        puzzle.right();
        puzzle.down();
        puzzle.left();
        puzzle.up();
        puzzle.left();
    }

    function getPlayer() external  view returns (address) {
        return player;
    }
}
