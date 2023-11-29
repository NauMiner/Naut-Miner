## Documentation

https://book.getfoundry.sh/

### Run script with Anvil

```shell
forge init
forge install openzeppelin/openzeppelin-contracts
anvil
forge script script/deploy.s.sol --broadcast --rpc-url http://localhost:8545
```