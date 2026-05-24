import os
import glob

files = glob.glob('lib/**/*.dart', recursive=True)
for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        with open(filepath, 'r', encoding='latin1') as f:
            content = f.read()
            
    # Fix the corrupted question marks
    new_content = content.replace("symbol: '?'", "symbol: '₹'")
    
    # Fix the remaining dollar signs that were missed
    new_content = new_content.replace("symbol: '\\$'", "symbol: '₹'")
    new_content = new_content.replace("symbol: '$'", "symbol: '₹'")
    
    if content != new_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Fixed {filepath}')
