# Marlin-scripts
My collection of Marlin scripts - for Ubuntu 18.04 LTS. YMMV - use at your own risk.

## Installers
* Compilers for OpenWeaver & ABCI geth (installs all required build prerequisites automatically).
* Installer for beacon
* Installer for relay (which also installes abci geth in lightmode)
* Custom eth ports (5003 for p2p & 5001 for rpc)
* Runs purely on external (autodected) IP (only same server benefits from localhost)

## Unitifles
* Runfiles for the different components (beacon, abci geth & relay)
* Systemd service unitfiles readty to start (and enable)
* Get automatically generated by the install scripts (so redundant, informative only)

NOTE : the current way of things won't allow for simulataneous internal / external relay connection won't work (sequential commands), even if you'd uncomment.

*Have fun ^_^*


### Donations welcome
* BTC : 3Lmfs7Y9fxJWgKMyANzTsNRdppkjk5wzBG
* ETH : 0xD3136a99Be75bEB3565c386cA28076E3A5621C56

