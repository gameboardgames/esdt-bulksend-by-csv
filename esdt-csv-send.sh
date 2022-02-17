#! /bin/bash
DENOMINATION="000000000000000000"
EXTRADECIMAL="000000"
#chainids
#testnet ChainID: T
#devnet ChainID: D
#mainnet chainID: 1
chainID="1"
PROXY="https://gateway.elrond.com"
MYWALLET="erd1xau0xlwlzldje349cxgngnaxym6mmn2pertqkk6ev7dmrlg9urysxjdlyv"
PEM_FILE="./steakssenderwalllet.pem"
#text colors codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
NC='\033[0m' # No Color
printf "Reading CSV file...\n"
printf "Press ${RED}control-c${NC} to abort the ESDT bulk transfer...\n"
read -t 5 -n 1 -s -r -p "Press any key to continue with ESDT bulk transfer, auto-starting in 5 seconds..."
echo -e "...${YELLOW}Starting${NC}"
printf "...${RED}Starting...${NC}\n"
#echo -e "Starting.."
while IFS="," read -r send_address_c1 steaks_c2
do
  #get nonce
  NONCE=$(erdpy account get --nonce --address="$MYWALLET" --proxy="$PROXY")
  extra0orspace=""
  #send address display
  echo -e " \n"
  echo -e "${LBLUE}Send address: ${YELLOW} $send_address_c1 ${LBLUE}"
  echo -e "Quantity of steaks: ${YELLOW} $steaks_c2 ${LBLUE}"
  echo -e "Nonce: ${YELLOW} $NONCE ${LBLUE}"
  #turn readable csv steaks value into proper value
  adjustedsteaks_c2=$steaks_c2$EXTRADECIMAL
  echo -e "Adjusted no. of steaks:${YELLOW} $adjustedsteaks_c2 ${LBLUE}" 

hexfordatafield="printf '$extra0orspace%x\n' $steaks_c2$EXTRADECIMAL | tee hexfordatafield.txt"
echo -e "Converted to hex:${YELLOW}"
eval $hexfordatafield
#make data field 
hexfordatafield=$( cat hexfordatafield.txt )
stringlength=${#hexfordatafield}
echo -e "${LBLUE}Adjusted esdt amount hex-field DATA string length: ${YELLOW} $stringlength ${LBLUE}"
#the following checks to see if the hex field character length is odd or even. If it is odd, a "0" need to be added to the data field for it to be read properly 
if [ $((stringlength%2)) -eq 0 ]
then
  echo -e "${LBLUE}Hex field length is even."
else
  echo -e "${LBLUE}Hex field length is odd. Adding 0 to start of hex for DATA field..."
  extra0orspace="0" 
fi
datafield="ESDTTransfer@535445414b532d616262396631@$extra0orspace$hexfordatafield"
echo -e "${LBLUE}Data Field:${YELLOW}\n"
echo -e "$datafield${LBUE}\n"
#refernce:  erdpy --verbose tx new --send --outfile="./sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --value="$DENOMINATION" --gas-limit=50000 --proxy=$PROXY
# my version:
echo -e "${LBLUE}Preparing tx as follows:${YELLOW}\n"
echo "erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
sendtx="erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
#note the following sleeps are needed because without them, the sending will happen too fast -- which throws off the nonce, as nonce only chages after a TX has had time to be processed 
sleep 6
eval $sendtx
#echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
#reference DATA field for steaks4all esdt transfer:      ESDTTransfer@535445414b532d616262396631@e4e1c0      
echo -e "${LBLUE}---------Transaction sent!"
echo -e "Proceeding to next transaction----"
sleep 6
done < <(tail -n +2 samplesend.csv)
