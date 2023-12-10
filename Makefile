-include .env

deploy:
	@echo "Deploying to Anvil..."
	forge script script/DeployFundMe.s.sol --rpc-url $(URL) --private-key $(P_KEY) --broadcast