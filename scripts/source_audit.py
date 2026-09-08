"""Structural audit only. NOT a Dart parser, analyzer, test run or build."""
from pathlib import Path
import re, json, xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
issues=[]
files=list((root/'lib').rglob('*.dart'))+list((root/'test').rglob('*.dart'))

def balance(text):
    n=len(text)
    def string(i, raw=False):
        q=text[i]; delimiter=q*3 if text.startswith(q*3,i) else q
        i+=len(delimiter)
        while i<n:
            if text.startswith(delimiter,i): return i+len(delimiter)
            if not raw and text[i]=='\\': i+=2; continue
            if not raw and text.startswith('${',i): i=code(i+2,True); continue
            i+=1
        raise ValueError('unterminated string')
    def code(i=0,interpolation=False):
        stack=[]
        while i<n:
            c=text[i]
            if interpolation and c=='}' and not stack: return i+1
            if text.startswith('//',i):
                at=text.find('\n',i); i=n if at<0 else at+1; continue
            if text.startswith('/*',i):
                at=text.find('*/',i+2)
                if at<0: raise ValueError('unterminated block comment')
                i=at+2; continue
            if c in "\"'": i=string(i); continue
            if c=='r' and i+1<n and text[i+1] in "\"'": i=string(i+1,True); continue
            if c in '([{': stack.append((c,i))
            elif c in ')]}':
                if not stack or stack[-1][0] != {')':'(',']':'[','}':'{'}[c]:
                    raise ValueError(f'unmatched {c} at line {text.count(chr(10),0,i)+1}')
                stack.pop()
            i+=1
        if stack: raise ValueError(f'unclosed {stack[-1][0]}')
        if interpolation: raise ValueError('unclosed interpolation')
        return i
    code()

for p in files:
    text=p.read_text()
    try: balance(text)
    except ValueError as e: issues.append(f'{p.relative_to(root)}: {e}')
    for target in re.findall(r"(?:import|export)\s+'([^']+)'",text):
        if target.startswith('dart:'): continue
        if target.startswith('package:pazel/'):
            resolved=root/'lib'/target[len('package:pazel/'):]
        elif target.startswith('package:'): continue
        else: resolved=p.parent/target
        if not resolved.exists(): issues.append(f'{p.relative_to(root)}: missing {target}')
strings=(root/'lib/core/localization/strings.dart').read_text()
keys=set(re.findall(r'static (?:const|String)\s+(\w+)',strings))
for p in files:
    for key in set(re.findall(r'\bS\.(\w+)',p.read_text()))-keys:
        issues.append(f'{p.relative_to(root)}: missing localization {key}')
for p in list(root.rglob('*.xml'))+list(root.rglob('*.svg')):
    try: ET.parse(p)
    except ET.ParseError as e: issues.append(f'{p.relative_to(root)}: {e}')
for path in ['assets/fonts/Vazirmatn-Regular.ttf','assets/fonts/Vazirmatn-Medium.ttf','assets/fonts/Vazirmatn-Bold.ttf']:
    if not (root/path).exists(): issues.append(f'Missing font {path}')
report={'dart_files':len(files),'dart_lines':sum(len(p.read_text().splitlines()) for p in files),
    'structural_issues':issues, 'flutter_analyze':'NOT RUN: SDK unavailable',
    'flutter_test':'NOT RUN: SDK unavailable', 'apk_build':'NOT RUN: Android SDK/Flutter unavailable',
    'web_build':'NOT RUN: Flutter unavailable',
    'disclaimer':'Structural checks do not prove valid Dart types, plugin compatibility, runtime behavior or successful compilation.'}
print(json.dumps(report,ensure_ascii=False,indent=2))
if issues: raise SystemExit(1)
