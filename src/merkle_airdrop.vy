# pragma version 0.4.3
"""
@title Merkle Airdrop
@license MIT
"""

from snekmate.utils import merkle_proof_verification as mpv
from ethereum.ercs import IERC20

# immutables
merkle_root: public(immutable(bytes32))
airdrop_token: public(immutable(IERC20))

# constants
PROOF_MAX_DEPTH: constant(uint8) = max_value(uint8)

# storage
has_claimed: HashMap[address, bool]

# events
event Claimed:
    account: indexed(address)
    amount: indexed(uint256)

@deploy
def __init__(_merkle_root: bytes32, _airdrop_token: address):
    merkle_root = _merkle_root
    airdrop_token = IERC20(_airdrop_token)

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
    assert not self.has_claimed[account], "merkle_airdrop: This account has already claimed the airdrop."

    # todo: signature verification

    leaf: bytes32 = keccak256(abi_encode(keccak256(abi_encode(account, amount))))
    assert mpv._verify(merkle_proof, merkle_root, leaf), "merkle_airdrop: Invalid Merkle proof."

    self.has_claimed[account] = True
    log Claimed(account, amount)

    success: bool = extcall airdrop_token.transfer(account, amount)