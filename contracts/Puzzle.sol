// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@nomiclabs/buidler/console.sol";

interface SolutionInterface {
    function run() external;
    function getPlayer() external view returns (address);
}

contract Puzzle {

    enum Command { LEFT, RIGHT, UP, DOWN }
    enum Cell { EMPTY, WALL, FINISH, FIRE }
    enum State { ALIVE, DEAD, DONE }

    struct Position {
        uint8 x;
        uint8 y;
    }

    // Grids of all levels
    uint8 constant levelsNum = 3;
    Cell[16][16][levelsNum] private grid;
    Position[levelsNum] private startPosition;

    // Puzzle state
    Position private position;
    State private state;

    SolutionInterface private currentSolution;
    address private currentPlayer;
    uint8 private currentLevel;
    uint8 private currentNumberOfMoves;

    struct Progress {
      uint8[levelsNum] numberOfMoves;
    }

    // Progress
    mapping (address => uint8) levelsCompleted;
    mapping (address => Progress) progressOf;

    // Highscores (top-5)
    struct Score {
      address player;
      uint32 score;
    }
    Score[6] topScores;

    constructor() public {
      // Initialize level 0
      grid[0][15][0] = Cell.FIRE;
      grid[0][0][15] = Cell.WALL;
      grid[0][15][15] = Cell.FINISH;
      startPosition[0] = Position(0, 0);

      // Initialize level 1
      grid[1][2][1] = Cell.FINISH;
      grid[1][1][10] = Cell.WALL;
      grid[1][15][9] = Cell.WALL;
      startPosition[1] = Position(15, 3);

      // Initialize level 2
      grid[2][0][0] = Cell.FIRE;
      grid[2][0][1] = Cell.FIRE;
      grid[2][0][5] = Cell.WALL;
      grid[2][1][5] = Cell.FIRE;
      grid[2][0][11] = Cell.WALL;
      grid[2][1][11] = Cell.FIRE;
      grid[2][0][12] = Cell.FIRE;
      grid[2][12][0] = Cell.WALL;
      grid[2][15][4] = Cell.WALL;
      grid[2][13][12] = Cell.WALL;
      grid[2][13][15] = Cell.WALL;
      grid[2][15][15] = Cell.FINISH;
      grid[2][15][14] = Cell.FIRE;
      startPosition[2] = Position(15, 13);
    }

    function getLevelsCompleted(address addr) external view returns (uint8) {
      return levelsCompleted[addr];
    }

    function getLevelsNum() external pure returns (uint8) {
      return levelsNum;
    }

    function getStartPosition(uint8 level) external view returns (uint8) {
      require(0 <= level && level < levelsNum, "Level doesn't exist");
      return startPosition[level].x * 16 + startPosition[level].y;
    }

    function getGrid(uint8 level) external view returns (uint8[256] memory) {
      require(0 <= level && level < levelsNum, "Level doesn't exist");

      uint8[256] memory gr;
      for (uint8 i = 0; i < 16; i++)
        for (uint8 j = 0; j < 16; j++)
          gr[i * 16 + j] = uint8(grid[level][i][j]);

      return gr;
    }

    function init() private {
        uint8 levelId = currentLevel;
        position = startPosition[levelId];
        state = State.ALIVE;
    }

    function registerSolution(address solutionAddress, uint8 lvl) private {
        SolutionInterface sol = SolutionInterface(solutionAddress);
        address player = sol.getPlayer();

        require(msg.sender == player, "Only solution's player can run it");
        require(0 <= lvl && lvl <= levelsCompleted[player] && lvl < levelsNum, "Level not valid");

        currentSolution = sol;
        currentPlayer = player;
        currentLevel = lvl;
        currentNumberOfMoves = 0;

        init();
    }

    function up() external {
        require(msg.sender == address(currentSolution), "Not registered solution");

        currentNumberOfMoves++;
        while (position.x > 0 && state == State.ALIVE) {
            position.x -= 1;

            Cell cell = grid[currentLevel][position.x][position.y];
            if (cell == Cell.WALL) {
                position.x += 1;
                break;
            } else if (cell == Cell.FINISH) {
                state = State.DONE;
                break;
            } else if (cell == Cell.FIRE) {
                state = State.DEAD;
                break;
            }
        }

        emit Up(state, position.x, position.y);
    }

    function down() external {
        require(msg.sender == address(currentSolution), "Not registered solution");

        currentNumberOfMoves++;
        while (position.x < 15 && state == State.ALIVE) {
            position.x += 1;

            Cell cell = grid[currentLevel][position.x][position.y];
            if (cell == Cell.WALL) {
                position.x -= 1;
                break;
            } else if (cell == Cell.FINISH) {
                state = State.DONE;
                break;
            } else if (cell == Cell.FIRE) {
                state = State.DEAD;
                break;
            }
        }

        emit Down(state, position.x, position.y);
    }

    function left() external {
        require(msg.sender == address(currentSolution), "Not registered solution");

        currentNumberOfMoves++;
        while (position.y > 0 && state == State.ALIVE) {
            position.y -= 1;

            Cell cell = grid[currentLevel][position.x][position.y];
            if (cell == Cell.WALL) {
                position.y += 1;
                break;
            } else if (cell == Cell.FINISH) {
                state = State.DONE;
                break;
            } else if (cell == Cell.FIRE) {
                state = State.DEAD;
                break;
            }
        }

        emit Left(state, position.x, position.y);
    }

    function right() external {
        require(msg.sender == address(currentSolution), "Not registered solution");

        currentNumberOfMoves++;
        while (position.y < 15 && state == State.ALIVE) {
            position.y += 1;

            Cell cell = grid[currentLevel][position.x][position.y];
            if (cell == Cell.WALL) {
                position.y -= 1;
                break;
            } else if (cell == Cell.FINISH) {
                state = State.DONE;
                break;
            } else if (cell == Cell.FIRE) {
                state = State.DEAD;
                break;
            }
        }

        emit Right(state, position.x, position.y);
    }

    function solve(address solutionAddress, uint8 level) external {
        registerSolution(solutionAddress, level);
        currentSolution.run();

        if (state == State.DONE) {
            emit Success();
            if (levelsCompleted[currentPlayer] == level) {
              levelsCompleted[currentPlayer]++;
              progressOf[currentPlayer].numberOfMoves[level] = currentNumberOfMoves;
              //updateHighscores();
            } else {
              if (currentNumberOfMoves < progressOf[currentPlayer].numberOfMoves[level]) {
                progressOf[currentPlayer].numberOfMoves[level] = currentNumberOfMoves;
                //updateHighscores();
              }
            }
        } else
            emit Failure();
    }

    function getNumberOfMovesOf(address player) public view returns (uint32) {
      if (player == address(0)) return 0;
      uint32 score = 0;
      for (uint8 i = 0; i < levelsNum; i++) {
        score += progressOf[player].numberOfMoves[i];
      }
      return score;
    }

    function getTopScores() external view returns (Score[6] memory) {
      return topScores;
    }

    function updateHighscores() private {
      topScores[5] = Score(currentPlayer, getNumberOfMovesOf(currentPlayer));
      for (uint8 i = 0; i < 6; i++) {
        for (uint8 j = i + 1; j < 6; j++) {
          if (topScores[j].score < topScores[i].score && topScores[j].score > 0) {
            Score memory saved = topScores[i];
            topScores[i] = topScores[j];
            topScores[j] = saved;
          }
        }
      }
    }

    event Success();
    event Failure();

    event Up(State state, uint8 x, uint8 y);
    event Down(State state, uint8 x, uint8 y);
    event Right(State state, uint8 x, uint8 y);
    event Left(State state, uint8 x, uint8 y);
}
