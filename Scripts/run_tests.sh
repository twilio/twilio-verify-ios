#/bin/sh
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
if [[ "$PWD" = */Scripts* ]]; then
	echo -e "${RED}${BOLD}❌ERROR ❌${NC}${RED}: Please run this script on the root directory.${NC}"
	exit 0
fi

echo "\n${GREEN}***${NC}${BOLD} Testing TwilioSecurity ${REG}${GREEN}***${NC}"
    bundle exec fastlane test scheme:TwilioSecurity || exit 1

echo "\n${GREEN}***${NC}${BOLD} Testing TwilioVerify ${REG}${GREEN}***${NC}"
    bundle exec fastlane test scheme:TwilioVerify || exit 1

echo "\n${GREEN}***${NC}${BOLD} Testing TwilioVerifyDemo App ${REG}${GREEN}***${NC}"
    bundle exec fastlane test scheme:TwilioVerifyDemo || exit 1

exit 0