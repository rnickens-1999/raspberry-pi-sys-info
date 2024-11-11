#!/bin/bash

# Define memory constants
MEMORY_256MB="256MB"
MEMORY_512MB="512MB"
MEMORY_1GB="1GB"
MEMORY_2GB="2GB"
MEMORY_4GB="4GB"
MEMORY_8GB="8GB"

# Define model constants
MODEL_A="A"
MODEL_B="B"
MODEL_A_PLUS="A+"
MODEL_B_PLUS="B+"
MODEL_2B="2B"
MODEL_ALPHA="Alpha (early prototype)"
MODEL_CM1="CM1"
MODEL_3B="3B"
MODEL_ZERO="Zero"
MODEL_CM3="CM3"
MODEL_ZERO_W="Zero W"
MODEL_3B_PLUS="3B+"
MODEL_3A_PLUS="3A+"
MODEL_INTERNAL="Internal use only"
MODEL_CM3_PLUS="CM3+"
MODEL_4B="4B"
MODEL_ZERO_2_W="Zero 2 W"
MODEL_400="400"
MODEL_CM4="CM4"
MODEL_CM4S="CM4S"
MODEL_5="5"

# Define the output file
OUTPUT_FILE="pi_system_info.txt"

# Fetch OS release information
echo "Gathering OS release information..."
echo "=== OS Release Information ===" > "$OUTPUT_FILE"
cat /etc/os-release >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Fetch Network Configuration for eth0 and wlan0
echo "Gathering network configuration..."
echo "=== Network Configuration ===" >> "$OUTPUT_FILE"
echo "Host Name: $(hostname)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for interface in eth0 wlan0; do
    echo "Interface: $interface" >> "$OUTPUT_FILE"

    # Get IPv4 address
    ip_address=$(ip -4 addr show "$interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    if [ -n "$ip_address" ]; then
        echo "IPv4 Address: $ip_address" >> "$OUTPUT_FILE"
    else
        echo "IPv4 Address: Not available" >> "$OUTPUT_FILE"
    fi

    # Get MAC address
    mac_address=$(cat /sys/class/net/"$interface"/address)
    echo "MAC Address: $mac_address" >> "$OUTPUT_FILE"

    echo "" >> "$OUTPUT_FILE"
done

# Fetch the revision code from /proc/cpuinfo
echo "Gathering revision and model information..."
revcode=$(awk '/Revision/ {print $3}' /proc/cpuinfo)

# Convert the revision code from hexadecimal to decimal
code=$((16#$revcode))

# Extract values based on bit shifts
new=$(( (code >> 23) & 0x1 ))
model=$(( (code >> 4) & 0xff ))
mem=$(( (code >> 20) & 0x7 ))

# Determine memory size based on mem variable
case $mem in
    0) mem_size=$MEMORY_256MB ;;
    1) mem_size=$MEMORY_512MB ;;
    2) mem_size=$MEMORY_1GB ;;
    3) mem_size=$MEMORY_2GB ;;
    4) mem_size=$MEMORY_4GB ;;
    5) mem_size=$MEMORY_8GB ;;
    *) mem_size="Unknown" ;;
esac

# Determine model name based on model variable
case $model in
    0) model_name=$MODEL_A ;;
    1) model_name=$MODEL_B ;;
    2) model_name=$MODEL_A_PLUS ;;
    3) model_name=$MODEL_B_PLUS ;;
    4) model_name=$MODEL_2B ;;
    5) model_name=$MODEL_ALPHA ;;
    6) model_name=$MODEL_CM1 ;;
    8) model_name=$MODEL_3B ;;
    9) model_name=$MODEL_ZERO ;;
    10) model_name=$MODEL_CM3 ;;
    12) model_name=$MODEL_ZERO_W ;;
    13) model_name=$MODEL_3B_PLUS ;;
    14) model_name=$MODEL_3A_PLUS ;;
    15) model_name=$MODEL_INTERNAL ;;
    16) model_name=$MODEL_CM3_PLUS ;;
    17) model_name=$MODEL_4B ;;
    18) model_name=$MODEL_ZERO_2_W ;;
    19) model_name=$MODEL_400 ;;
    20) model_name=$MODEL_CM4 ;;
    21) model_name=$MODEL_CM4S ;;
    22) model_name=$MODEL_INTERNAL ;;
    23) model_name=$MODEL_5 ;;
    *) model_name="Unknown Model" ;;
esac

# Fetch CPU information
echo "Gathering CPU information..."
echo "=== CPU Information ===" >> "$OUTPUT_FILE"
grep -E "Model|Hardware|Revision" /proc/cpuinfo >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Append revision and model details to the output file
#echo "=== Revision and Model Information ===" >> "$OUTPUT_FILE"
#echo "Revision Code (Hex): $revcode" >> "$OUTPUT_FILE"
#echo "Converted Revision Code (Decimal): $code" >> "$OUTPUT_FILE"
#echo "Model: $model_name" >> "$OUTPUT_FILE"
echo "Memory Size: $mem_size" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Notify user that the process is complete
echo "System information has been saved to $OUTPUT_FILE. Here is the gathered information:"
echo -e "\r\n"
cat "$OUTPUT_FILE"
