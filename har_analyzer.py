#!/usr/bin/env python3
"""
HAR File Analyzer - Checks for HTTP errors in HAR files
"""

import json
import os
import glob
from pathlib import Path

def categorize_status_code(status):
    """Categorize HTTP status codes into their respective ranges"""
    if 100 <= status <= 199:
        return "1xx_informational"
    elif 200 <= status <= 299:
        return "2xx_success"
    elif 300 <= status <= 399:
        return "3xx_redirection"
    elif 400 <= status <= 499:
        return "4xx_client_error"
    elif 500 <= status <= 599:
        return "5xx_server_error"
    else:
        return "unknown"

def get_status_description(status):
    """Get description for HTTP status codes per RFC 9110"""
    status_descriptions = {
        # 1xx Informational - RFC 9110 Section 15.2
        100: "Continue",
        101: "Switching Protocols",
        102: "Processing",
        103: "Early Hints",
        
        # 2xx Successful - RFC 9110 Section 15.3
        200: "OK",
        201: "Created",
        202: "Accepted",
        203: "Non-Authoritative Information",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        207: "Multi-Status",
        208: "Already Reported",
        226: "IM Used",
        
        # 3xx Redirection - RFC 9110 Section 15.4
        300: "Multiple Choices",
        301: "Moved Permanently",
        302: "Found",
        303: "See Other",
        304: "Not Modified",
        305: "Use Proxy",
        307: "Temporary Redirect",
        308: "Permanent Redirect",
        
        # 4xx Client Error - RFC 9110 Section 15.5
        400: "Bad Request",
        401: "Unauthorized",
        402: "Payment Required",
        403: "Forbidden",
        404: "Not Found",
        405: "Method Not Allowed",
        406: "Not Acceptable",
        407: "Proxy Authentication Required",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        411: "Length Required",
        412: "Precondition Failed",
        413: "Content Too Large",
        414: "URI Too Long",
        415: "Unsupported Media Type",
        416: "Range Not Satisfiable",
        417: "Expectation Failed",
        418: "I'm a teapot",
        421: "Misdirected Request",
        422: "Unprocessable Content",
        423: "Locked",
        424: "Failed Dependency",
        425: "Too Early",
        426: "Upgrade Required",
        428: "Precondition Required",
        429: "Too Many Requests",
        431: "Request Header Fields Too Large",
        451: "Unavailable For Legal Reasons",
        
        # 5xx Server Error - RFC 9110 Section 15.6
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
        505: "HTTP Version Not Supported",
        506: "Variant Also Negotiates",
        507: "Insufficient Storage",
        508: "Loop Detected",
        510: "Not Extended",
        511: "Network Authentication Required"
    }
    return status_descriptions.get(status, f"Unknown Status ({status})")

def analyze_har_file(har_file_path):
    """Analysis of a HAR file for all HTTP status codes"""
    print(f"\n🔍 Analyzing: {os.path.basename(har_file_path)}")
    
    try:
        with open(har_file_path, 'r', encoding='utf-8') as f:
            har_data = json.load(f)
        
        # Categorized collections
        status_stats = {
            "1xx_informational": [],
            "2xx_success": [],
            "3xx_redirection": [],
            "4xx_client_error": [],
            "5xx_server_error": [],
            "unknown": []
        }
        
        total_requests = 0
        
        # Check if HAR has entries
        if 'log' in har_data and 'entries' in har_data['log']:
            entries = har_data['log']['entries']
            total_requests = len(entries)
            
            for entry in entries:
                if 'response' in entry:
                    status = entry['response'].get('status', 0)
                    url = entry['request'].get('url', 'Unknown URL')
                    method = entry['request'].get('method', 'Unknown')
                    timestamp = entry.get('startedDateTime', 'Unknown')
                    
                    # Create detailed entry info
                    entry_info = {
                        'status': status,
                        'url': url,
                        'method': method,
                        'timestamp': timestamp,
                        'request_headers': entry['request'].get('headers', []),
                        'response_headers': entry['response'].get('headers', []),
                        'response_text': entry['response'].get('content', {}).get('text', ''),
                        'description': get_status_description(status)
                    }
                    
                    # Categorize by status code range
                    category = categorize_status_code(status)
                    status_stats[category].append(entry_info)
        
        # Print summary statistics
        print(f"📊 Total requests: {total_requests}")
        print(f"✅ 2xx Successful: {len(status_stats['2xx_success'])}")
        print(f"↪️ 3xx Redirection: {len(status_stats['3xx_redirection'])}")
        print(f"❌ 4xx Client Error: {len(status_stats['4xx_client_error'])}")
        print(f"🚨 5xx Server Error: {len(status_stats['5xx_server_error'])}")
        if status_stats['1xx_informational']:
            print(f"ℹ️ 1xx Informational: {len(status_stats['1xx_informational'])}")
        if status_stats['unknown']:
            print(f"❓ Unknown Status: {len(status_stats['unknown'])}")
        
        # Show detailed breakdown of errors
        all_errors = status_stats['4xx_client_error'] + status_stats['5xx_server_error']
        
        if status_stats['4xx_client_error']:
            print(f"\n❌ 4XX CLIENT ERROR ({len(status_stats['4xx_client_error'])}):")
            error_counts = {}
            for error in status_stats['4xx_client_error']:
                status = error['status']
                error_counts[status] = error_counts.get(status, 0) + 1
            
            for status in sorted(error_counts.keys()):
                count = error_counts[status]
                description = get_status_description(status)
                print(f"  • {status} ({description}): {count} errors")
        
        if status_stats['5xx_server_error']:
            print(f"\n🚨 5XX SERVER ERROR ({len(status_stats['5xx_server_error'])}):")
            error_counts = {}
            for error in status_stats['5xx_server_error']:
                status = error['status']
                error_counts[status] = error_counts.get(status, 0) + 1
            
            for status in sorted(error_counts.keys()):
                count = error_counts[status]
                description = get_status_description(status)
                print(f"  • {status} ({description}): {count} errors")
        
        if status_stats['3xx_redirection']:
            print(f"\n↪️ 3XX REDIRECTION ({len(status_stats['3xx_redirection'])}):")
            redirect_counts = {}
            for redirect in status_stats['3xx_redirection']:
                status = redirect['status']
                redirect_counts[status] = redirect_counts.get(status, 0) + 1
            
            for status in sorted(redirect_counts.keys()):
                count = redirect_counts[status]
                description = get_status_description(status)
                print(f"  • {status} ({description}): {count} redirects")
        
        return status_stats, total_requests
        
    except Exception as e:
        print(f"❌ Error reading HAR file: {e}")
        return {}, 0

def main():
    """Analysis of all HAR files for all HTTP status code ranges"""
    har_dir = "output/har_files"
    
    if not os.path.exists(har_dir):
        print(f"❌ HAR directory not found: {har_dir}")
        return
    
    har_files = glob.glob(os.path.join(har_dir, "*.har"))
    
    if not har_files:
        print(f"❌ No HAR files found in: {har_dir}")
        return
    
    print(f"🔍 Found {len(har_files)} HAR files to analyze")
    print("📊 COMPREHENSIVE HTTP STATUS CODE ANALYSIS")
    print("=" * 80)
    
    # Aggregate statistics across all files
    combined_stats = {
        "1xx_informational": [],
        "2xx_success": [],
        "3xx_redirection": [],
        "4xx_client_error": [],
        "5xx_server_error": [],
        "unknown": []
    }
    
    total_requests_all = 0
    
    for har_file in sorted(har_files):
        status_stats, total_requests = analyze_har_file(har_file)
        
        # Aggregate results
        for category, entries in status_stats.items():
            combined_stats[category].extend(entries)
        
        total_requests_all += total_requests
    
    print("\n" + "=" * 80)
    print("📊 COMPREHENSIVE STATUS CODE REPORT")
    print("=" * 80)
    print(f"📁 Total HAR files analyzed: {len(har_files)}")
    print(f"🌐 Total requests across all files: {total_requests_all}")
    
    # Overall statistics
    success_percentage = (len(combined_stats['2xx_success']) / total_requests_all * 100) if total_requests_all > 0 else 0
    error_percentage = ((len(combined_stats['4xx_client_error']) + len(combined_stats['5xx_server_error'])) / total_requests_all * 100) if total_requests_all > 0 else 0
    
    print(f"\n📈 OVERALL HEALTH METRICS:")
    print(f"✅ Successful Rate (2xx): {len(combined_stats['2xx_success'])} ({success_percentage:.1f}%)")
    print(f"❌ Error Rate (4xx+5xx): {len(combined_stats['4xx_client_error']) + len(combined_stats['5xx_server_error'])} ({error_percentage:.1f}%)")
    print(f"↪️ Redirection (3xx): {len(combined_stats['3xx_redirection'])}")
    
    # Detailed breakdown by category per RFC 9110
    if combined_stats['4xx_client_error']:
        print(f"\n❌ CLIENT ERROR (4xx) - {len(combined_stats['4xx_client_error'])} Total:")
        error_counts = {}
        critical_errors = []
        
        for error in combined_stats['4xx_client_error']:
            status = error['status']
            error_counts[status] = error_counts.get(status, 0) + 1
            
            # Flag critical errors for detailed review
            if status in [401, 403, 404]:
                critical_errors.append(error)
        
        for status in sorted(error_counts.keys()):
            count = error_counts[status]
            description = get_status_description(status)
            severity = "🚨 CRITICAL" if status in [401, 403] else "⚠️ WARNING" if status == 404 else "ℹ️ INFO"
            print(f"  • {status} ({description}): {count} errors {severity}")
        
        # Show critical errors in detail
        forbidden_errors = [e for e in critical_errors if e['status'] == 403]
        unauthorized_errors = [e for e in critical_errors if e['status'] == 401]
        
        if forbidden_errors:
            print(f"\n🚨 FORBIDDEN (403) ERRORS - AUTHENTICATION ISSUES:")
            for i, error in enumerate(forbidden_errors[:5], 1):  # Show first 5
                print(f"  {i}. {error['method']} {error['url'][:80]}...")
            if len(forbidden_errors) > 5:
                print(f"     ... and {len(forbidden_errors) - 5} more")
        
        if unauthorized_errors:
            print(f"\n🚨 UNAUTHORIZED (401) ERRORS - AUTHENTICATION REQUIRED:")
            for i, error in enumerate(unauthorized_errors[:5], 1):  # Show first 5
                print(f"  {i}. {error['method']} {error['url'][:80]}...")
            if len(unauthorized_errors) > 5:
                print(f"     ... and {len(unauthorized_errors) - 5} more")
    
    if combined_stats['5xx_server_error']:
        print(f"\n🚨 SERVER ERROR (5xx) - {len(combined_stats['5xx_server_error'])} Total:")
        error_counts = {}
        
        for error in combined_stats['5xx_server_error']:
            status = error['status']
            error_counts[status] = error_counts.get(status, 0) + 1
        
        for status in sorted(error_counts.keys()):
            count = error_counts[status]
            description = get_status_description(status)
            print(f"  • {status} ({description}): {count} errors 🚨 CRITICAL")
    
    if combined_stats['3xx_redirection']:
        print(f"\n↪️ REDIRECTION (3xx) - {len(combined_stats['3xx_redirection'])} Total:")
        redirect_counts = {}
        
        for redirect in combined_stats['3xx_redirection']:
            status = redirect['status']
            redirect_counts[status] = redirect_counts.get(status, 0) + 1
        
        for status in sorted(redirect_counts.keys()):
            count = redirect_counts[status]
            description = get_status_description(status)
            print(f"  • {status} ({description}): {count} redirects")
    
    # Final assessment
    print("\n" + "=" * 80)
    print("🏥 HEALTH ASSESSMENT")
    print("=" * 80)
    
    total_errors = len(combined_stats['4xx_client_error']) + len(combined_stats['5xx_server_error'])
    forbidden_count = len([e for e in combined_stats['4xx_client_error'] if e['status'] == 403])
    unauthorized_count = len([e for e in combined_stats['4xx_client_error'] if e['status'] == 401])
    server_error_count = len(combined_stats['5xx_server_error'])
    
    if total_errors == 0:
        print("🟢 EXCELLENT: No HTTP errors detected!")
    elif error_percentage < 1.0:
        print(f"🟡 GOOD: Low error rate ({error_percentage:.1f}%)")
    elif error_percentage < 5.0:
        print(f"🟠 FAIR: Moderate error rate ({error_percentage:.1f}%)")
    else:
        print(f"🔴 POOR: High error rate ({error_percentage:.1f}%)")
    
    if forbidden_count > 0:
        print(f"🚨 SECURITY: {forbidden_count} forbidden errors - Review authentication!")
    if unauthorized_count > 0:
        print(f"🔐 AUTH: {unauthorized_count} unauthorized errors - Check credentials!")
    if server_error_count > 0:
        print(f"⚡ SERVER: {server_error_count} server errors - Check backend health!")
    
    if total_errors == 0:
        print("✅ All systems functioning normally!")
    
    print("=" * 80)

if __name__ == "__main__":
    main() 