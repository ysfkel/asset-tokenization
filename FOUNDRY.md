To execute a script local 
> forge script script/Token.s.sol:TokenScript
>

To simulate executing a script to deploy  run below withut --broadcast
forge script script/Token.s.sol:TokenScript --rpc-url $GOERLI_RPC_URL 

To execute a script with rpc specify --broadcast
forge script script/Token.s.sol:TokenScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv 


deployed token 
0xc8652ae50144987883fd01b808bd0db2f28ac135

forge script script/DepolyPayroll.s.sol:DepolyPayroll --rpc-url $RPC_URL --broadcast --verify -vvvv 


forge script script/DepolyPayroll.s.sol:DepolyPayroll --rpc-url localhost --broadcast --verify -vvvv 

 forge script script/DepolyPayroll.s.sol:DepolyPayroll --rpc-url $RPC_URL --broadcast --private-key <your private key string here> d0d3324037eae964a0d3153ba7cb7751648c87f49632427c352d9c06bd379212

 generate doc
 forge doc --out docs --serve --port 4000 


 test 
 You can also run specific tests by passing a filter:
$ forge test --match-contract ComplicatedContractTest --match-test testDeposit


forge script script/payroll/Deploy.s.sol:Deploy --rpc-url localhost --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast

forge script script/asset/Deploy.s.sol:Deploy --rpc-url localhost --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast