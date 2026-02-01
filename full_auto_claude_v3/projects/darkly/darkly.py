#!/usr/bin/env python3
"""
darkly - Security Audit Tool
Web security vulnerability scanner and analyzer
"""

import sys
import re
import urllib.parse
import hashlib
import base64
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum


class VulnSeverity(Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


@dataclass
class Vulnerability:
    """Security vulnerability finding."""
    name: str
    severity: VulnSeverity
    description: str
    location: str
    evidence: str = ""
    remediation: str = ""


class SecurityAnalyzer:
    """Web security analyzer."""

    def __init__(self):
        self.vulnerabilities: List[Vulnerability] = []

    def add_vuln(self, vuln: Vulnerability):
        """Add a vulnerability finding."""
        self.vulnerabilities.append(vuln)

    # =========== XSS Detection ===========

    def check_xss(self, content: str, source: str = "unknown") -> List[Vulnerability]:
        """Check for potential XSS vulnerabilities."""
        vulns = []

        # Reflected XSS patterns
        xss_patterns = [
            r'<script[^>]*>.*?</script>',
            r'javascript:',
            r'on\w+\s*=',
            r'<img[^>]+onerror',
            r'<svg[^>]+onload',
            r'<iframe[^>]+src\s*=',
            r'document\.cookie',
            r'document\.write',
            r'innerHTML\s*=',
            r'eval\s*\(',
            r'setTimeout\s*\([^)]*["\']',
            r'setInterval\s*\([^)]*["\']',
        ]

        for pattern in xss_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE | re.DOTALL)
            if matches:
                vulns.append(Vulnerability(
                    name="Potential XSS Vulnerability",
                    severity=VulnSeverity.HIGH,
                    description=f"Found pattern that may indicate XSS: {pattern}",
                    location=source,
                    evidence=str(matches[:3]),
                    remediation="Sanitize user input, use Content-Security-Policy headers"
                ))

        return vulns

    # =========== SQL Injection Detection ===========

    def check_sqli(self, content: str, source: str = "unknown") -> List[Vulnerability]:
        """Check for potential SQL injection vulnerabilities."""
        vulns = []

        # SQL injection patterns
        sqli_patterns = [
            r'SELECT\s+.+\s+FROM\s+.+\s+WHERE',
            r'INSERT\s+INTO\s+.+\s+VALUES',
            r'UPDATE\s+.+\s+SET\s+.+\s+WHERE',
            r'DELETE\s+FROM\s+.+\s+WHERE',
            r'\bOR\s+1\s*=\s*1',
            r'\bAND\s+1\s*=\s*1',
            r'\bUNION\s+SELECT',
            r'--\s*$',
            r';\s*--',
            r'\bDROP\s+TABLE',
            r'\bEXEC\s+',
            r'\bEXECUTE\s+',
        ]

        for pattern in sqli_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                vulns.append(Vulnerability(
                    name="Potential SQL Injection",
                    severity=VulnSeverity.CRITICAL,
                    description=f"Found SQL pattern: {pattern}",
                    location=source,
                    evidence=str(matches[:3]),
                    remediation="Use parameterized queries/prepared statements"
                ))

        return vulns

    # =========== Path Traversal Detection ===========

    def check_path_traversal(self, content: str, source: str = "unknown") -> List[Vulnerability]:
        """Check for path traversal vulnerabilities."""
        vulns = []

        patterns = [
            r'\.\./\.\.',
            r'\.\.\\\.\\',
            r'%2e%2e%2f',
            r'%252e%252e%252f',
            r'/etc/passwd',
            r'c:\\windows',
            r'file://',
        ]

        for pattern in patterns:
            if re.search(pattern, content, re.IGNORECASE):
                vulns.append(Vulnerability(
                    name="Path Traversal Attempt",
                    severity=VulnSeverity.HIGH,
                    description=f"Found path traversal pattern: {pattern}",
                    location=source,
                    evidence=pattern,
                    remediation="Validate and sanitize file paths, use allowlists"
                ))

        return vulns

    # =========== Sensitive Data Exposure ===========

    def check_sensitive_data(self, content: str, source: str = "unknown") -> List[Vulnerability]:
        """Check for exposed sensitive data."""
        vulns = []

        patterns = {
            "API Key": r'(?:api[_-]?key|apikey)["\s:=]+["\']?([a-zA-Z0-9]{20,})["\']?',
            "AWS Access Key": r'AKIA[0-9A-Z]{16}',
            "AWS Secret Key": r'(?:aws)?[_-]?secret[_-]?(?:access)?[_-]?key["\s:=]+["\']?([a-zA-Z0-9/+=]{40})["\']?',
            "Password in URL": r'://[^:]+:([^@]+)@',
            "Private Key": r'-----BEGIN (?:RSA |DSA |EC )?PRIVATE KEY-----',
            "Credit Card": r'\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})\b',
            "SSN": r'\b\d{3}-\d{2}-\d{4}\b',
            "Email": r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
            "JWT Token": r'eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+',
            "Basic Auth": r'Basic\s+[a-zA-Z0-9+/=]{10,}',
        }

        for name, pattern in patterns.items():
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                vulns.append(Vulnerability(
                    name=f"Sensitive Data Exposure: {name}",
                    severity=VulnSeverity.HIGH if "Key" in name or "Password" in name else VulnSeverity.MEDIUM,
                    description=f"Found potentially sensitive {name}",
                    location=source,
                    evidence=f"Found {len(matches)} instance(s)",
                    remediation="Remove sensitive data, use environment variables"
                ))

        return vulns

    # =========== Header Security ===========

    def check_security_headers(self, headers: Dict[str, str], source: str = "unknown") -> List[Vulnerability]:
        """Check for missing security headers."""
        vulns = []

        required_headers = {
            "Content-Security-Policy": (VulnSeverity.MEDIUM, "Prevents XSS attacks"),
            "X-Frame-Options": (VulnSeverity.MEDIUM, "Prevents clickjacking"),
            "X-Content-Type-Options": (VulnSeverity.LOW, "Prevents MIME sniffing"),
            "Strict-Transport-Security": (VulnSeverity.MEDIUM, "Enforces HTTPS"),
            "X-XSS-Protection": (VulnSeverity.LOW, "Legacy XSS filter"),
            "Referrer-Policy": (VulnSeverity.LOW, "Controls referrer info"),
        }

        headers_lower = {k.lower(): v for k, v in headers.items()}

        for header, (severity, desc) in required_headers.items():
            if header.lower() not in headers_lower:
                vulns.append(Vulnerability(
                    name=f"Missing Security Header: {header}",
                    severity=severity,
                    description=f"The {header} header is not set. {desc}",
                    location=source,
                    remediation=f"Add {header} header to responses"
                ))

        return vulns

    # =========== Cookie Security ===========

    def check_cookies(self, cookies: List[Dict[str, str]], source: str = "unknown") -> List[Vulnerability]:
        """Check cookie security settings."""
        vulns = []

        for cookie in cookies:
            name = cookie.get("name", "unknown")

            if not cookie.get("httpOnly", False):
                vulns.append(Vulnerability(
                    name=f"Cookie Missing HttpOnly: {name}",
                    severity=VulnSeverity.MEDIUM,
                    description="Cookie accessible via JavaScript",
                    location=source,
                    remediation="Set HttpOnly flag on cookie"
                ))

            if not cookie.get("secure", False):
                vulns.append(Vulnerability(
                    name=f"Cookie Missing Secure Flag: {name}",
                    severity=VulnSeverity.MEDIUM,
                    description="Cookie may be sent over HTTP",
                    location=source,
                    remediation="Set Secure flag on cookie"
                ))

            if cookie.get("sameSite", "").lower() == "none":
                vulns.append(Vulnerability(
                    name=f"Cookie SameSite=None: {name}",
                    severity=VulnSeverity.LOW,
                    description="Cookie can be sent cross-site",
                    location=source,
                    remediation="Set SameSite to Strict or Lax"
                ))

        return vulns

    # =========== URL Analysis ===========

    def check_url(self, url: str) -> List[Vulnerability]:
        """Analyze URL for security issues."""
        vulns = []

        parsed = urllib.parse.urlparse(url)

        # Check for HTTP
        if parsed.scheme == "http":
            vulns.append(Vulnerability(
                name="Insecure Protocol",
                severity=VulnSeverity.MEDIUM,
                description="URL uses HTTP instead of HTTPS",
                location=url,
                remediation="Use HTTPS for all connections"
            ))

        # Check for credentials in URL
        if parsed.password:
            vulns.append(Vulnerability(
                name="Credentials in URL",
                severity=VulnSeverity.HIGH,
                description="Password exposed in URL",
                location=url,
                evidence=f"Password length: {len(parsed.password)}",
                remediation="Never include credentials in URLs"
            ))

        # Check query parameters
        params = urllib.parse.parse_qs(parsed.query)
        sensitive_params = ["password", "token", "key", "secret", "api_key", "auth"]

        for param in params:
            if any(s in param.lower() for s in sensitive_params):
                vulns.append(Vulnerability(
                    name="Sensitive Parameter in URL",
                    severity=VulnSeverity.MEDIUM,
                    description=f"Potentially sensitive parameter: {param}",
                    location=url,
                    remediation="Send sensitive data in POST body or headers"
                ))

        return vulns

    # =========== Password Strength ===========

    def check_password_strength(self, password: str) -> Tuple[int, List[str]]:
        """Check password strength. Returns score (0-100) and issues."""
        score = 0
        issues = []

        # Length
        if len(password) >= 8:
            score += 20
        else:
            issues.append("Password should be at least 8 characters")

        if len(password) >= 12:
            score += 10

        if len(password) >= 16:
            score += 10

        # Complexity
        if re.search(r'[a-z]', password):
            score += 10
        else:
            issues.append("Add lowercase letters")

        if re.search(r'[A-Z]', password):
            score += 10
        else:
            issues.append("Add uppercase letters")

        if re.search(r'[0-9]', password):
            score += 10
        else:
            issues.append("Add numbers")

        if re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            score += 15
        else:
            issues.append("Add special characters")

        # Common patterns
        common = ["password", "123456", "qwerty", "admin", "letmein"]
        if password.lower() in common:
            score = max(0, score - 50)
            issues.append("Avoid common passwords")

        # Sequential characters
        if re.search(r'(.)\1{2,}', password):
            score = max(0, score - 10)
            issues.append("Avoid repeated characters")

        return min(100, score), issues

    # =========== Hash Analysis ===========

    def identify_hash(self, hash_str: str) -> str:
        """Identify hash type."""
        length = len(hash_str)

        if not re.match(r'^[a-fA-F0-9]+$', hash_str):
            if hash_str.startswith('$2a$') or hash_str.startswith('$2b$'):
                return "bcrypt"
            if hash_str.startswith('$argon2'):
                return "Argon2"
            if hash_str.startswith('$6$'):
                return "SHA-512 crypt"
            if hash_str.startswith('$5$'):
                return "SHA-256 crypt"
            return "Unknown"

        hash_types = {
            32: "MD5",
            40: "SHA-1",
            56: "SHA-224",
            64: "SHA-256",
            96: "SHA-384",
            128: "SHA-512",
        }

        return hash_types.get(length, f"Unknown ({length} chars)")

    # =========== Report Generation ===========

    def generate_report(self) -> str:
        """Generate security report."""
        lines = [
            "=" * 70,
            "                    SECURITY AUDIT REPORT",
            "=" * 70,
            "",
        ]

        # Summary
        by_severity = {s: [] for s in VulnSeverity}
        for vuln in self.vulnerabilities:
            by_severity[vuln.severity].append(vuln)

        lines.append("SUMMARY")
        lines.append("-" * 40)
        for severity in VulnSeverity:
            count = len(by_severity[severity])
            if count > 0:
                lines.append(f"  {severity.value:10s}: {count}")
        lines.append(f"  {'TOTAL':10s}: {len(self.vulnerabilities)}")
        lines.append("")

        # Details
        lines.append("FINDINGS")
        lines.append("-" * 40)

        for i, vuln in enumerate(self.vulnerabilities, 1):
            lines.append(f"\n[{i}] {vuln.name}")
            lines.append(f"    Severity:    {vuln.severity.value}")
            lines.append(f"    Location:    {vuln.location}")
            lines.append(f"    Description: {vuln.description}")
            if vuln.evidence:
                lines.append(f"    Evidence:    {vuln.evidence[:100]}")
            if vuln.remediation:
                lines.append(f"    Remediation: {vuln.remediation}")

        lines.append("\n" + "=" * 70)

        return "\n".join(lines)


def run_demo():
    """Run security analysis demo."""
    print("darkly - Security Audit Tool")
    print("=" * 50)

    analyzer = SecurityAnalyzer()

    # Demo: XSS detection
    print("\n[1] XSS Detection")
    print("-" * 40)
    test_content = '''
    <script>alert('XSS')</script>
    <img src=x onerror="alert(1)">
    onclick="malicious()"
    document.cookie
    '''
    vulns = analyzer.check_xss(test_content, "test_page.html")
    for v in vulns:
        analyzer.add_vuln(v)
        print(f"  Found: {v.name}")

    # Demo: SQL injection
    print("\n[2] SQL Injection Detection")
    print("-" * 40)
    sql_content = '''
    SELECT * FROM users WHERE id = 1 OR 1=1
    UNION SELECT password FROM admin--
    '''
    vulns = analyzer.check_sqli(sql_content, "query.sql")
    for v in vulns:
        analyzer.add_vuln(v)
        print(f"  Found: {v.name}")

    # Demo: Sensitive data
    print("\n[3] Sensitive Data Exposure")
    print("-" * 40)
    sensitive_content = '''
    API_KEY=AKIAIOSFODNN7EXAMPLE
    password: secret123
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U
    '''
    vulns = analyzer.check_sensitive_data(sensitive_content, "config.txt")
    for v in vulns:
        analyzer.add_vuln(v)
        print(f"  Found: {v.name}")

    # Demo: Security headers
    print("\n[4] Security Headers Check")
    print("-" * 40)
    headers = {"Content-Type": "text/html"}
    vulns = analyzer.check_security_headers(headers, "https://example.com")
    for v in vulns:
        analyzer.add_vuln(v)
        print(f"  Missing: {v.name}")

    # Demo: URL analysis
    print("\n[5] URL Analysis")
    print("-" * 40)
    test_url = "http://example.com/api?password=secret&token=abc123"
    vulns = analyzer.check_url(test_url)
    for v in vulns:
        analyzer.add_vuln(v)
        print(f"  Found: {v.name}")

    # Demo: Password strength
    print("\n[6] Password Strength")
    print("-" * 40)
    passwords = ["password", "MyP@ssw0rd!", "correcthorsebatterystaple"]
    for pwd in passwords:
        score, issues = analyzer.check_password_strength(pwd)
        print(f"  '{pwd[:10]}...': {score}/100")
        for issue in issues[:2]:
            print(f"    - {issue}")

    # Demo: Hash identification
    print("\n[7] Hash Identification")
    print("-" * 40)
    hashes = [
        "5d41402abc4b2a76b9719d911017c592",
        "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12",
        "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy",
    ]
    for h in hashes:
        hash_type = analyzer.identify_hash(h)
        print(f"  {h[:30]}... -> {hash_type}")

    # Generate report
    print("\n" + analyzer.generate_report())


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("darkly - Security Audit Tool")
            print("\nUsage:")
            print("  python darkly.py              - Run demo")
            print("  python darkly.py <file>       - Analyze file")
            print("\nCapabilities:")
            print("  - XSS detection")
            print("  - SQL injection detection")
            print("  - Path traversal detection")
            print("  - Sensitive data exposure")
            print("  - Security header analysis")
            print("  - Cookie security check")
            print("  - URL analysis")
            print("  - Password strength")
            print("  - Hash identification")
            return

        # Analyze file
        import os
        if os.path.exists(sys.argv[1]):
            analyzer = SecurityAnalyzer()
            with open(sys.argv[1], 'r', errors='ignore') as f:
                content = f.read()

            print(f"Analyzing: {sys.argv[1]}")
            print("-" * 40)

            for check in [
                analyzer.check_xss,
                analyzer.check_sqli,
                analyzer.check_path_traversal,
                analyzer.check_sensitive_data,
            ]:
                for vuln in check(content, sys.argv[1]):
                    analyzer.add_vuln(vuln)

            print(analyzer.generate_report())
            return

    run_demo()


if __name__ == "__main__":
    main()
