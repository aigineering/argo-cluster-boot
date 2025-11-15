#!/usr/bin/env python3
"""
Script to extract Go struct field comments and add them to KCL schema
"""

import re
from pathlib import Path

def extract_go_comments(go_file):
    """Extract field comments from Go structs"""
    with open(go_file, 'r') as f:
        content = f.read()
    
    # Pattern to match struct field with comment
    # Captures: comment, field_name, field_type
    pattern = r'^\s*//\s*(.+?)\n\s*(\w+)\s+([^\`]+)`json:"(\w+)'
    
    comments = {}
    current_struct = None
    struct_pattern = r'^type\s+(\w+)\s+struct\s*{'
    
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check for struct definition
        struct_match = re.match(struct_pattern, line)
        if struct_match:
            current_struct = struct_match.group(1)
            comments[current_struct] = {}
            i += 1
            continue
        
        # Check for field comment
        if current_struct and line.strip().startswith('//'):
            comment_lines = []
            # Collect all comment lines
            while i < len(lines) and lines[i].strip().startswith('//'):
                comment = lines[i].strip()[2:].strip()
                if comment:
                    comment_lines.append(comment)
                i += 1
            
            # Next line should be the field
            if i < len(lines):
                field_line = lines[i].strip()
                field_match = re.match(r'(\w+)\s+[^\`]+`json:"(\w+)', field_line)
                if field_match:
                    field_name = field_match.group(1)
                    json_name = field_match.group(2)
                    full_comment = ' '.join(comment_lines)
                    comments[current_struct][json_name] = {
                        'field_name': field_name,
                        'comment': full_comment
                    }
        i += 1
    
    return comments

def update_kcl_with_comments(kcl_file, comments):
    """Update KCL file with extracted comments"""
    with open(kcl_file, 'r') as f:
        kcl_content = f.read()
    
    # For each struct found in comments
    for struct_name, fields in comments.items():
        for json_name, info in fields.items():
            comment = info['comment']
            
            # Pattern to find field in KCL: fieldName?: Type
            # We'll add comment before it
            pattern = rf'(\n\s*)({json_name}\?:\s*[^\n]+)'
            
            def replace_with_comment(match):
                indent = match.group(1)
                field_def = match.group(2)
                # Check if comment already exists right above
                before_match = kcl_content[:match.start()]
                lines_before = before_match.split('\n')
                if len(lines_before) >= 2 and lines_before[-1].strip().startswith('#'):
                    # Comment already exists, skip
                    return match.group(0)
                return f'{indent}# {comment}{indent}{field_def}'
            
            kcl_content = re.sub(pattern, replace_with_comment, kcl_content)
    
    with open(kcl_file, 'w') as f:
        f.write(kcl_content)

if __name__ == '__main__':
    go_file = Path('/Users/sim/src/argo-cluster-boot/kcl/vcluster/config.example.go')
    kcl_file = Path('/Users/sim/src/argo-cluster-boot/kcl/vcluster/vcluster_config.k')
    
    print("Extracting comments from Go file...")
    comments = extract_go_comments(go_file)
    
    print(f"Found {len(comments)} structs with comments")
    for struct_name, fields in list(comments.items())[:5]:
        print(f"  {struct_name}: {len(fields)} fields")
    
    print("\nUpdating KCL file with comments...")
    update_kcl_with_comments(kcl_file, comments)
    
    print("Done!")
