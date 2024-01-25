// Define the interface for Rock-Paper-Scissors
#[starknet::interface]
trait IRPSActions<TContractState> {
    fn play_move(self: @TContractState, move_type: u32); // 0: Rock, 1: Paper, 2: Scissors
}

// Dojo contract module for Rock-Paper-Scissors
#[dojo::contract]
mod rps_actions {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::rand::RngTrait;
    use super::IRPSActions;

    // Enum representing the possible moves in Rock-Paper-Scissors
    #[repr(u32)]
    enum MoveType {
        Rock = 0,
        Paper = 1,
        Scissors = 2,
    }

    // Event struct for notifying moves
    #[event]
    #[derive(Drop, starknet::Event)]
    struct MoveEvent {
        player: ContractAddress,
        move_type: MoveType,
    }

    // Implementation of the Rock-Paper-Scissors contract
    #[abi(embed_v0)]
    impl RPSActionsImpl of IRPSActions<ContractState> {
        // ContractState is defined by system decorator expansion

        // Function for a player to make a move
        fn play_move(self: @ContractState, move_type: u32) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller (player).
            let player = get_caller_address();

            // Ensure a valid move type is provided
            assert(move_type < 3, 'Invalid move type');

            // Generate a random move for the opponent
            let opponent_move = starknet::rand::get_rng().gen_range(0..3);

            // Determine the winner based on moves
            let result = match (move_type, opponent_move) {
                (0, 2) | (1, 0) | (2, 1) => 1, // Caller wins
                (0, 1) | (1, 2) | (2, 0) => 2, // Opponent wins
                _ => 0, // It's a tie
            };

            // Emit an event to the world to notify about the player's move.
            emit!(world, MoveEvent { player, move_type: MoveType::from(move_type) });
        }
    }
}
