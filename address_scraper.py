"""
This Python script reads the contract ranking produced by the "build_contracts.py" script
and maps each Ethereum address to a label indicating the user/entity owning the address.
Labels are retrieved by scraping data from the Etherscan explorer.

Author: Matteo Loporchio
"""

import requests
import sys
import time
from bs4 import BeautifulSoup

INPUT_FILE = sys.argv[1]
OUTPUT_FILE = sys.argv[2]

def get_name(address):
    url = f"https://etherscan.io/address/{address}"
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    page = requests.get(url, headers=headers)
    soup = BeautifulSoup(page.content, "html.parser")
    tag = soup.find("span", {"class":"hash-tag text-truncate lh-sm my-n1"})
    if tag is None:
        return "(unknown)"
    return tag.text.strip()

input_fh = open(INPUT_FILE, 'r')
output_fh = open(OUTPUT_FILE, 'w')
output_fh.write('rank\taddress\tname\n')
count = 0
for line in input_fh:
    if count != 0:
        line = line.strip()
        parts = line.split('\t')
        rank = parts[0]
        address = parts[1]
        name = get_name(address)
        output_fh.write(f'{rank}\t{address}\t{name}\n')
        time.sleep(1)
    count += 1
input_fh.close()
output_fh.close()