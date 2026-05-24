import os
import glob
import re

files = glob.glob('lib/**/*.dart', recursive=True)
for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        with open(filepath, 'r', encoding='latin1') as f:
            content = f.read()
            
    # Force replace any NumberFormat currency symbol setting to Rupee
    new_content = re.sub(r"NumberFormat\.currency\(\s*symbol:\s*['\"].*?['\"]", "NumberFormat.currency(symbol: '₹'", content)
    new_content = re.sub(r"NumberFormat\.compactCurrency\(\s*symbol:\s*['\"].*?['\"]", "NumberFormat.compactCurrency(symbol: '₹'", new_content)
    
    if content != new_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Fixed {filepath}')
