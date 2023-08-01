import os
import re
import time

# Run the script and capture its output
reset_script_path = "/opt/MatchX/bin/reset_lgw_both.sh"
reset_command = "{} start".format(reset_script_path)
os.system(reset_command)

time.sleep(10)

# Run the script to get the EUI and capture its output
eui_script_path = "/opt/MatchX/bin/chip_id"
output = os.popen(eui_script_path).read()

# Extract the EUI using regular expressions
eui_match = re.search(r'INFO: concentrator EUI: (0x[0-9a-fA-F]+)', output)

if eui_match:
    concentrator_eui = eui_match.group(1)
    print("Concentrator EUI: {}".format(concentrator_eui))
else:
    print("Unable to find concentrator EUI.")