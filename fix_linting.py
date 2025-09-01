#!/usr/bin/env python3
"""
Flutter Linting Auto-Fix Script
Automatically fixes common Flutter linting issues
"""

import os
import re
import glob

def fix_file_issues(file_path):
    """Fix common linting issues in a Dart file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Fix 1: Replace double quotes with single quotes (except for strings with single quotes inside)
        content = re.sub(r'"([^"\']*)"', r"'\1'", content)
        
        # Fix 2: Replace withOpacity with withValues
        content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
        
        # Fix 3: Fix double literals (e.g., 0.0 -> 0)
        content = re.sub(r'\b(\d+)\.0\b', r'\1', content)
        
        # Fix 4: Add const constructors where possible (basic cases)
        content = re.sub(r'new\s+(\w+)\(', r'const \1(', content)
        content = re.sub(r'return\s+(\w+)\(', r'return const \1(', content)
        
        # Fix 5: Replace redundant Offset values
        content = re.sub(r'Offset\(0\.0,\s*0\.0\)', 'Offset.zero', content)
        
        # Write back if changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Fixed: {os.path.basename(file_path)}")
            return True
        else:
            print(f"⚪ No changes: {os.path.basename(file_path)}")
            return False
            
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def fix_import_ordering(file_path):
    """Fix import ordering in Dart files"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        dart_imports = []
        package_imports = []
        relative_imports = []
        other_lines = []
        
        in_imports = True
        
        for line in lines:
            if line.strip().startswith('import '):
                if "'dart:" in line:
                    dart_imports.append(line)
                elif "'package:" in line:
                    package_imports.append(line)
                else:
                    relative_imports.append(line)
            elif line.strip() == '' and in_imports:
                continue  # Skip empty lines in import section
            else:
                in_imports = False
                other_lines.append(line)
        
        # Sort each group
        dart_imports.sort()
        package_imports.sort()
        relative_imports.sort()
        
        # Reconstruct file
        new_content = ''
        if dart_imports:
            new_content += ''.join(dart_imports) + '\n'
        if package_imports:
            new_content += ''.join(package_imports) + '\n'
        if relative_imports:
            new_content += ''.join(relative_imports) + '\n'
        new_content += ''.join(other_lines)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ Fixed imports: {os.path.basename(file_path)}")
        return True
        
    except Exception as e:
        print(f"❌ Error fixing imports in {file_path}: {e}")
        return False

def main():
    """Main function to fix all Dart files"""
    lib_dir = "G:/HAS/has/lib"
    
    if not os.path.exists(lib_dir):
        print(f"❌ Library directory not found: {lib_dir}")
        return
    
    print("🔧 Starting automatic linting fixes...")
    print("=" * 50)
    
    # Find all Dart files
    dart_files = []
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    fixed_count = 0
    
    for dart_file in dart_files:
        print(f"\n🔍 Processing: {os.path.relpath(dart_file, lib_dir)}")
        
        # Fix import ordering
        fix_import_ordering(dart_file)
        
        # Fix other issues
        if fix_file_issues(dart_file):
            fixed_count += 1
    
    print("\n" + "=" * 50)
    print(f"✅ Completed! Fixed {fixed_count} files out of {len(dart_files)}")
    print("🚀 Run 'flutter analyze' to check remaining issues")

if __name__ == "__main__":
    main()
