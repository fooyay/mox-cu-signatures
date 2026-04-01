# pragma version 0.4.3
"""
@title Merkle Airdrop
@license MIT
"""

from snekmate.utils import merkle_proof_verification as mpv
from snekmate.utils import eip712_domain_separator as eip712
from snekmate.utils import ecdsa
from ethereum.ercs import IERC20

initializes: eip712

struct AirdropClaim:
    account: address
    amount: uint256

# immutables
merkle_root: public(immutable(bytes32))
airdrop_token: public(immutable(IERC20))

# constants
PROOF_MAX_DEPTH: constant(uint8) = max_value(uint8)
MESSAGE_TYPEHASH: constant(bytes32) = keccak256(b"AirdropClaim(address account,uint256 amount)")
EIP712_NAME: constant(String[20]) = "MerkleAirdrop"
EIP712_VERSION: constant(String[20]) = "1"


# storage
has_claimed: HashMap[address, bool]

# events
event Claimed:
    account: indexed(address)
    amount: indexed(uint256)

@deploy
def __init__(_merkle_root: bytes32, _airdrop_token: address):
    eip712.__init__(EIP712_NAME, EIP712_VERSION)
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

    message_hash: bytes32 = self._get_message_hash(account, amount)
    assert self._is_valid_signature(account, message_hash, v, r, s), "merkle_airdrop: Invalid signature."

    leaf: bytes32 = keccak256(abi_encode(keccak256(abi_encode(account, amount))))
    assert mpv._verify(merkle_proof, merkle_root, leaf), "merkle_airdrop: Invalid Merkle proof."

    self.has_claimed[account] = True
    log Claimed(account=account, amount=amount)

    success: bool = extcall airdrop_token.transfer(account, amount)
    assert success, "merkle_airdrop: Token transfer failed."

@internal
def _get_message_hash(account: address, amount: uint256) -> bytes32:
    """
    Get the hash of the message that should be signed for claiming.
    @param account The address of the account claiming the airdrop.
    @param amount The amount of tokens being claimed.
    @return The hash of the message that should be signed for claiming.
    """
    airdrop_claim: AirdropClaim = AirdropClaim(account=account, amount=amount)
    initial_hash: bytes32 = keccak256(abi_encode(MESSAGE_TYPEHASH, airdrop_claim))
    return eip712._hash_typed_data_v4(initial_hash)

@internal
def _is_valid_signature(account: address, message_hash: bytes32, v: uint8, r: bytes32, s: bytes32) -> bool:
    """
    Verify that the signature is valid and was signed by the account.
    @param account The address of the account claiming the airdrop.
    @param message_hash The hash of the message that should be signed for claiming.
    @param v The recovery byte of the signature.
    @param r The r value of the signature.
    @param s The s value of the signature.
    @return True if the signature is valid and was signed by the account, false otherwise.
    """
    v_u256: uint256 = convert(v, uint256)
    r_u256: uint256 = convert(r, uint256)
    s_u256: uint256 = convert(s, uint256)
    actual_signer: address = ecdsa._try_recover_vrs(message_hash, v_u256, r_u256, s_u256)
    return actual_signer == account