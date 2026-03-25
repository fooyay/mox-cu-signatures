# Moccasin Project: Signatures

🐍 Welcome to your Moccasin project!

## Quickstart

1. Deploy to a fake local network that titanoboa automatically spins up!

```bash
mox run deploy
```

2. Run tests

```
mox test
```

# Goals
1. Airdrop tokens to X number of accounts
  - Let people claim via a `claim` function
2. Not have to store X number of accounts on chain
  - Use a Merkle tree to store the accounts off chain and verify claims on chain
3. Update make_merkle.py to python 3.12 syntax and compare output to the existing make_merkle.py to ensure the same output




_For documentation, please run `mox --help` or visit [the Moccasin documentation](https://cyfrin.github.io/moccasin)_
