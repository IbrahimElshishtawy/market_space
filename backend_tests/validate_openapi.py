#!/usr/bin/env python3
"""
Automated validation of Deal One OpenAPI 3.1.0 specifications.
"""
import sys
import yaml
from pathlib import Path
from openapi_spec_validator import validate

def validate_openapi_file(file_path: Path):
    print(f"Validating {file_path}...")
    if not file_path.exists():
        print(f"Error: {file_path} does not exist.")
        return False
        
    with open(file_path, "r", encoding="utf-8") as f:
        try:
            spec_dict = yaml.safe_load(f)
        except Exception as e:
            print(f"YAML parsing failed: {e}")
            return False

    try:
        validate(spec_dict)
        print(f"SUCCESS: {file_path} is valid OpenAPI {spec_dict.get('openapi')}")
    except Exception as e:
        print(f"OpenAPI validation error in {file_path}: {e}")
        return False

    # Check endpoint count
    paths = spec_dict.get("paths", {})
    total_ops = sum(len(methods) for methods in paths.values())
    print(f"Endpoints count: {len(paths)} paths, {total_ops} operations.")
    if total_ops != 55:
        print(f"Warning: Expected 55 operations, found {total_ops}")
        return False

    return True

def main():
    files = [
        Path("backend_blueprint/openapi/deal_one_openapi.yaml"),
        Path("backend_blueprint/15_OPENAPI/deal_one_openapi.yaml")
    ]
    all_ok = True
    for f in files:
        if not validate_openapi_file(f):
            all_ok = False
            
    if not all_ok:
        sys.exit(1)
    print("\nAll OpenAPI specifications successfully validated and certified!")

if __name__ == "__main__":
    main()
