# pragma version 0.4.3
"""
@title Merkle Airdrop
@license MIT
"""

# immutables
merkle_root: public(immutable(bytes32))
airdrop_token: public(immutable(address))

# constants
PROOF_MAX_DEPTH: constant(uint8) = max_value(uint8)

@deploy
def __init__(_merkle_root: bytes32, _airdrop_token: address):
    merkle_root = _merkle_root
    airdrop_token = _airdrop_token

@external
def claim(
    account: address,
    amount: uint256,
    merkle_proof: DynArray[bytes32, PROOF_MAX_DEPTH],
    v: uint8,
    r: bytes32,
    s: bytes32
):
    """
    @param account The address of the account claiming the airdrop.
    @param amount The amount of tokens being claimed.
    @param merkle_proof A Merkle proof that the account and amount are
        part of the Merkle tree represented by `merkle_root`.
    @param v The recovery byte of the signature.
    @param r The r value of the signature.
    @param s The s value of the signature.
    @dev This function will allow users to claim their airdrop tokens.
    """
    pass