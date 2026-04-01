from script.make_merkle import DEFAULT_AMOUNT
from eth_account._utils.signing import sign_message_hash
from eth_keys.datatypes import PrivateKey
from eth_utils import to_bytes

proof = [
    bytes.fromhex("8ebcc963f0588d1ded1ebd0d349946755f27e95d1917f9427a207d8935e04d4b"),
    bytes.fromhex("e5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576"),
]


def test_initial_balance_is_zero(merkle, token, user):
    starting_token_balance = token.balanceOf(user.address)
    assert starting_token_balance == 0


def test_user_can_claim_airdrop(merkle, token, user):
    starting_token_balance = token.balanceOf(user.address)

    message_hash = merkle.get_message_hash(user.address, DEFAULT_AMOUNT)
    v, r, s, _ = sign_message_hash(PrivateKey(user.key), message_hash)

    merkle.claim(
        user.address,
        DEFAULT_AMOUNT,
        proof,
        v,
        to_bytes(r),
        to_bytes(s),
    )

    ending_balance = token.balanceOf(user.address)
    assert ending_balance == starting_token_balance + DEFAULT_AMOUNT


def test_invalid_user_cannot_claim_airdrop(merkle, token, bad_user):
    starting_token_balance = token.balanceOf(bad_user.address)

    message_hash = merkle.get_message_hash(bad_user.address, DEFAULT_AMOUNT)
    v, r, s, _ = sign_message_hash(PrivateKey(bad_user.key), message_hash)

    try:
        merkle.claim(
            bad_user.address,
            DEFAULT_AMOUNT,
            proof,
            v,
            to_bytes(r),
            to_bytes(s),
        )
        assert False, "Expected claim to fail for invalid user"
    except Exception as e:
        assert "merkle_airdrop: Invalid Merkle proof." in str(e)

    ending_balance = token.balanceOf(bad_user.address)
    assert ending_balance == starting_token_balance
