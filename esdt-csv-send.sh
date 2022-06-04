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
PEM_FILE="./steaksp.pem"
#text color
RED='\033[0;31m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
NC='\033[0m' # No Color
printf "Clearing hex cache..."
rm hexfordatafield.txt
#this deletes the cached hex from the last time the script was run
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
  echo -e "${LBLUE}Send address: ${YELLOW} $send_address_c1"
  echo -e "${LBLUE}Nonce: ${YELLOW} $NONCE \n"
  echo -e "${LBLUE}Quantity of steaks: ${YELLOW} $steaks_c2 \n"
  #turn readable csv steaks value into proper value
  adjustedsteaks_c2="$steaks_c2$EXTRADECIMAL"
  #adjustedsteaks_c2=$steaks_c2
  #adjustedsteaks_c2+=$EXTRADECIMAL
  echo -e "${LBLUE}Adjusted no. of steaks:${YELLOW} $adjustedsteaks_c2 ${NC}\n" 
#hexfordatafield="printf '$extra0orspace%x\n' $steaks_c2$EXTRADECIMAL | tee hexfordatafield.txt"
hexfordatafield="printf '$extra0orspace%x\n' $adjustedsteaks_c2 | tee hexfordatafield.txt"
echo -e "${LBLUE}Converted to hex:${YELLOW}"
eval $hexfordatafield
hexfordatafield=$( cat hexfordatafield.txt )
#make data field
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
#important!!! this line above is set to STEAKS token currently. You must change @535445414b532d616262396631 to the token you are using
#which you can see by sending a normal ESDT token from your wallet and noting the identifier field your token uses 
echo -e "${LBLUE}Data Field:${YELLOW}\n"
echo -e "$datafield${LBLUE}\n"
#refernce:  erdpy --verbose tx new --send --outfile="./sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --value="$2$DENOMINATION" --gas-limit=50000 --proxy=$PROXY
# my version:
echo -e "${LBLUE}Preparing tx as follows:${YELLOW}\n"
echo "erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
sendtx="erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
#note the following sleeps are needed because with out them, the sending will happen to fast -- which throws off the nonce, as nonce only chages after a TX has had time to be processed 
sleep 6
eval $sendtx
#echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
#reference DATA field for steaks4all esdt transfer:      ESDTTransfer@535445414b532d616262396631@e4e1c0      ESDTTransfer@535445414b532d616262396631@e4e1c0
echo -e "${LBLUE}---------Transaction sent!"
echo -e "Proceeding to next transaction----"
sleep 6
done < <(tail -n +2 thisismysendlist.csv)
