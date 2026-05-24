import os
import glob
import re

files = glob.glob('lib/**/*.dart', recursive=True)
for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception:
        with open(filepath, 'r', encoding='latin1') as f:
            lines = f.readlines()
            
    new_lines = []
    changed = False
    for line in lines:
        if 'NumberFormat.currency(symbol:' in line:
            new_line = re.sub(r"symbol:\s*['\"].*?['\"]", "symbol: '₹'", line)
            if new_line != line:
                changed = True
            new_lines.append(new_line)
        elif 'NumberFormat.compactCurrency(symbol:' in line and 'symbol =' not in line:
            new_line = re.sub(r"symbol:\s*['\"].*?['\"]", "symbol: '₹'", line)
            if new_line != line:
                changed = True
            new_lines.append(new_line)
        elif 'String symbol =' in line and 'compactCurrency' in line:
            new_line = re.sub(r"symbol\s*=\s*['\"].*?['\"]", "symbol = '₹'", line)
            if new_line != line:
                changed = True
            new_lines.append(new_line)
        elif 'String symbol =' in line and 'currency(' in line:
            new_line = re.sub(r"symbol\s*=\s*['\"].*?['\"]", "symbol = '₹'", line)
            if new_line != line:
                changed = True
            new_lines.append(new_line)
        else:
            new_lines.append(line)
            
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f'Fixed {filepath}')
