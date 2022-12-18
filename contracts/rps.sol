// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract rps {
    event GameInitiated(address);
    event GameFinished(address);
    event PhaseChanged(Stage);

    enum Weapon {
        None,
        Rock,
        Paper,
        Scissors
    }

    enum Stage {
        Registration,
        Commit,
        Reveal
    }

    Stage public currentPhase;

    address public player1;
    address public player2;

    address public winner;

    bytes32 private player1e;
    bytes32 private player2e;

    Weapon public player1Move;
    Weapon public player2Move;

    constructor() {
        player1 = address(0x0);
        player2 = address(0x0);

        changePhaseTo(Stage.Registration);
    }

    function getStatus() external view returns(Stage) {
        return currentPhase;
    }

    function changePhaseTo(Stage phase) private {
        currentPhase = phase;
        emit PhaseChanged(currentPhase);
    }

    modifier isRegistrationCorrect() {
        require(
            msg.sender != player1 &&
                msg.sender != player2
        );
        _;
    }

    modifier isPlayerActive() {
        require(
            msg.sender == player1 ||
                msg.sender == player2
        );
        _;
    }

    modifier areThereAnyPlayers() {
        require(
            player1e != 0x0 &&
                player2e != 0x0
        );
        _;
    }

    function newGame() public {
        winner = address(0x0);
        player1 = address(0x0);
        player2 = address(0x0);

        player1e = 0x0;
        player2e = 0x0;

        player1Move = Weapon.None;
        player2Move = Weapon.None;

        currentPhase = Stage.Registration;
        emit PhaseChanged(Stage.Registration);
    }

    function registration() public isRegistrationCorrect returns (uint256) {
        require(currentPhase == Stage.Registration);
        
        if (player1 == address(0x0)) {
            emit GameInitiated(msg.sender);
            player1 = address(msg.sender);
            return 1;
        }

        if (player2 == address(0x0)) {
            player2 = address(msg.sender);
            currentPhase = Stage.Commit;
            emit PhaseChanged(Stage.Commit);
            return 2;
        }

        return 0;
    }

    function makeMove(bytes32 move) public isPlayerActive returns (bool) {
        require(currentPhase == Stage.Commit);

        if (msg.sender == player1
                        && player1e == 0x0) {
            player1e = move;
        } else if (msg.sender == player2
                        && player2e == 0x0) {
            player2e = move;
        }

        if (player1e != 0x0
                        && player2e != 0x0) {
            changePhaseTo(Stage.Reveal);
            return true;
        }

        return false;
    }

    function reveal(Weapon element, uint32 salt) public isPlayerActive {
        require(currentPhase == Stage.Reveal);

        bytes32 currMove = sha256(
            bytes.concat(
                bytes(Strings.toString(uint256(element))),
                bytes(Strings.toString(salt))
            )
        );

        if (element == Weapon.None) {
            return;
        }

        if (msg.sender == player1
                    && currMove == player1e) {
            player1Move = element;
        } else if (msg.sender == player2
                    && currMove == player2e) {
            player2Move = element;
        } else {
            return;
        }

        if (player1Move != Weapon.None
                        && player2Move != Weapon.None) {
            if (player1Move == player2Move) {
                winner = address(0x0);
                emit GameFinished(winner);
                return;
            }

            if (player1Move == Weapon.Rock) {
                if (player2Move == Weapon.Paper) {
                    winner = player2;
                } else {
                    winner = player1;
                }
            } else if (player1Move == Weapon.Paper) {
                if (player2Move == Weapon.Scissors) {
                    winner = player2;
                } else {
                    winner = player1;
                }
            } else {
                if (player2Move == Weapon.Rock) {
                    winner = player2;
                } else {
                    winner = player1;
                }
            }

            emit GameFinished(winner);
        }
    }
}
