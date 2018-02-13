# recon.sh
This is the recon.sh project changelog file.
recon.sh is a reconnaissance script, written to automate first recon stage during a penetration test.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.10] - unreleased
###   Added
- splitted the script in more files
- colours
### Changed
- the basepath for result is now defaulted to $HOME/$APPNAME
- Added a new is_port_open method to check for opened port using $ports

## [0.9] - 2018-02-06
###  Added
- first release on github
- '--reason' parameter to nmap
- UDP scanning
- attempt a curl call on website root directory
- add heartbleed specific test
- added whatweb against port 80 and 443

## [0.8] - 2018-01-03
### Added
- test_ftp for ftp testing
- test_ssh for ssh testing
- test_smtp for smtp testing
- test_dns for dns testing
- test_mysql for mysql testing
- TCP port 139 for SMB protocol
### Changed
- dirb and nikto filename

## [0.7] - 2017-11-20
### Added
- sqlmap crawling website
- support for HTTP routine for port 443 and 8080

## [0.6] - 2017-09-28
### Added
- smbclient scan
### Changed
- if nmap output is present on target directory, than scan is skipped and file
  used for next step

## [0.5] - 2017-09-27
### Added
- nmap, searchexploit, dirb and nikto scripting

