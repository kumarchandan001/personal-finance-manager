import os

ROOT_DIR = "."

IGNORE_DIRS = {
    ".git",
    ".dart_tool",
    "build",
    "node_modules",
    "venv",
    "__pycache__",
    ".idea",
    "ios/Pods",
    "ios/.symlinks"
}

IGNORE_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".ico", ".pdf", ".zip", ".tar", ".gz",
    ".ttf", ".otf", ".woff", ".woff2", ".jks", ".keystore", ".apk", ".ipa",
    ".lock", ".pyc"
}

REPLACEMENTS = [
    ("FinMind AI Assistant", "FINTELIA AI Assistant"),
    ("FinMind AI", "FINTELIA"),
    ("FinMind", "FINTELIA"),
    ("com.finmindai.app", "com.fintelia.app"),
    ("finmind_ai", "fintelia"),
    ("finmindai", "fintelia"),
    ("finmind", "fintelia"),
    ("FINMIND", "FINTELIA"),
]

def rebrand():
    modified_files = 0
    for root, dirs, files in os.walk(ROOT_DIR):
        # Remove ignored directories to not traverse them
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        
        for file in files:
            _, ext = os.path.splitext(file)
            if ext.lower() in IGNORE_EXTENSIONS:
                continue
                
            filepath = os.path.join(root, file)
            # Skip this script
            if os.path.basename(filepath) == "rebrand.py":
                continue

            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                for old_val, new_val in REPLACEMENTS:
                    new_content = new_content.replace(old_val, new_val)
                    
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated: {filepath}")
                    modified_files += 1
            except UnicodeDecodeError:
                # Binary file or unsupported encoding
                pass
            except Exception as e:
                print(f"Error processing {filepath}: {e}")
                
    print(f"\nRebranding completed. Modified {modified_files} files.")

if __name__ == "__main__":
    rebrand()
