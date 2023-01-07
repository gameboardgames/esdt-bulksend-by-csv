#! /bin/bash
DENOMINATION="000000000000000000"
EXTRADECIMAL="000000"
#chainids
#testnet ChainID: T
#devnet ChainID: D
#mainnet chainID: 1
chainID="1"
PROXY="https://gateway.elrond.com"
#the above two lines confirm this is on mainnet
MYWALLET="erd1xau0xlwlzldje349cxgngnaxym6mmn2pertqkk6ev7dmrlg9urysxjdlyv"
#obv you'll want to change this above to your own my wallet address. 
PEM_FILE="./privatewalletkey.pem"
#text colors, for no particular reason are the next 4 lines
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
  extradec="000000"
  #get nonce
  NONCE=$(erdpy account get --nonce --address="$MYWALLET" --proxy="$PROXY")
  rm hexfordatafield.txt
  extra0orspace=""
  #send address display
  echo -e " \n"
  echo -e "${LBLUE}Send address: ${YELLOW} $send_address_c1"
  echo -e " \n"
  echo -e "${LBLUE}Nonce: ${YELLOW} $NONCE"
  echo -e " \n"
  echo -e "${LBLUE}Quantity of steaks: ${NC} $steaks_c2"
  #adjustedsteaks=$(echo $steaks_c2|tr -d '\n\r')
  #turn readable csv steaks value into proper value
  #prepsteaks="${steaks_c2}"
  #echo -n "Value of prep steaks: $prepsteaks" 
  #adjustedsteaks=$(echo $steaks_c2|tr -d '\n')
  #adjustedsteaks=$steaks_c2$EXTRADECIMAL
  echo -e "${LBLUE} \n"
  echo -n "Adjusted no. of steaks:"
  adjustedsteaks=$steaks_c2$EXTRADECIMAL
  echo "Is:$adjustedsteaks"
  #prepsteaks="$adjustedsteaks_c2"
  #echo -n "Second prep adjustment of steaks: "
  #echo -n " $prepsteaks"
  echo -e " \n"
  echo -e "${LBLUE}Converted to hex:${YELLOW}\n"
  #printf "%x\n", $adjustedsteaks | tee hexfordatafield.txt
  printf "%x" $adjustedsteaks | tee hexfordatafield.txt
  #above line does a hex conversion and saves the output to the txt file
  hexfordatafield=$(cat hexfordatafield.txt)
  #make data field of hex 
  stringlength=${#hexfordatafield}
  echo -e " \n"
  echo -e "${LBLUE}Adjusted esdt amount hex-field DATA string length: ${YELLOW} $stringlength ${LBLUE}"
  #the following checks to see if the hex field character length is odd or even. If it is odd, a "0" need to be added to the data field for it to be read properl
  if [ $((stringlength%2)) -eq 0 ]
   then
   echo -e "${LBLUE}Hex field length is even."
   else
   echo -e "${LBLUE}Hex field length is odd. Adding 0 to start of hex for DATA field..."
   extra0orspace="0"
  fi
 datafield="ESDTTransfer@535445414b532d616262396631@$extra0orspace$hexfordatafield"
 #important!!! this line above is set to STEAKS token currently. You must change @535445414b532d616262396631 to the token you are using. You can get this hex ID 
 #from checking the original smart contract that created the token, or use a tool to convert.
 #or also you can see your hex ID by sending the ESDT token from your wallet and noting the identifier field your token uses
 echo -e "${LBLUE}Data Field:${YELLOW}\n"
 echo -e "$datafield${LBLUE}\n"
 #refernce:  erdpy --verbose tx new --send --outfile="./sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --value="$2$DENOMINATION" --gas-limit=50000 --proxy=$PROXY
 # my version:
 echo -e "${LBLUE}Preparing tx as follows:${YELLOW}\n"
 echo "erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
 sendtx="erdpy --verbose tx new --send --outfile="sent-tx-$NONCE.json" --pem=$PEM_FILE --nonce=$NONCE --receiver=$send_address_c1"" --value=0 --gas-limit 500000 --chain=$chainID"" --proxy=$PROXY --data=$datafield"
 #note the following sleeps are needed because with out them, the sending will happen to fast -- which throws off the nonce, as nonce only chages after a TX has had time to be processed 
 sleep 9
 eval $sendtx
 echo -n "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json. \n"
 #reference DATA field for steaks4all esdt transfer:      ESDTTransfer@535445414b532d616262396631@e4e1c0      ESDTTransfer@535445414b532d616262396631@e4e1c0
 echo -e "${LBLUE}---------Transaction sent!"
 echo -e "${RED} Proceeding to next transaction----${NC}"
 sleep 6
done < <(tail -n +1 samplesend.csv)
#change the file name above as needed. 
#and remember to eat vegetables as well, sometimes, steaks need side dishes 
