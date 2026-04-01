# SKILL: debug-app

## Description

Diagnose and fix bugs, errors, and issues in applications. This skill provides a systematic approach to troubleshooting code problems, identifying root causes, implementing fixes, and ensuring the solution works properly.

## Purpose

Software breaks. When it does, you fix it. This skill guides you through the debugging process from initial error report to verified fix, ensuring nothing is missed and the problem doesn't recur.

## When to Use

- Henry reports a bug or error
- Application crashes or behaves unexpectedly
- Users encounter errors
- Tests are failing
- Performance issues
- Integration problems
- Any issue with existing code

## Execution Steps

### 1. Reproduce the Bug

**Get detailed information:**
- What is the expected behavior?
- What actually happens?
- When did this start occurring?
- What changed recently?

**Gather reproduction steps:**
```
To reproduce:
1. Run command X
2. With input Y
3. Observe error Z
```

**Attempt to reproduce:**
- Follow the exact steps provided
- Try in the same environment
- Verify you can see the same issue

**Document what you observe:**
- Exact error messages
- Stack traces
- Unexpected outputs
- When it happens vs. when it doesn't

**If you can't reproduce:**
- Ask for more details
- Check environment differences
- Try different scenarios
- May not be a consistent bug

### 2. Read Error Logs and Trace

**Examine error messages:**
```bash
# Check application logs
tail -n 100 /path/to/app/logs/error.log

# Check system logs if relevant
journalctl -u service-name -n 100

# Python traceback
# Read the full stack trace from bottom to top

# Node.js errors
# Check error.stack for full trace
```

**Understand the error:**
- What is the error type? (TypeError, ReferenceError, etc.)
- What line of code failed?
- What was the state when it failed?
- What's the call stack?

**Look for patterns:**
- Does it happen every time or intermittently?
- Does it happen with specific inputs?
- Are there related errors?

**Check recent changes:**
```bash
# View recent git commits
git log -10 --oneline

# See what changed
git diff HEAD~5 HEAD
```

### 3. Identify Root Cause

**Follow the trail:**
- Start at the error location
- Trace back through the code path
- Understand the data flow
- Find where things went wrong

**Common bug categories:**

**Type Errors:**
- Wrong data type passed to function
- Null/undefined where value expected
- Type coercion issues

**Logic Errors:**
- Incorrect conditional logic
- Off-by-one errors
- Wrong algorithm or calculation

**State Errors:**
- Race conditions
- Uninitialized variables
- Incorrect state management

**Integration Errors:**
- API changes
- Missing dependencies
- Configuration issues
- Network problems

**Use debugging techniques:**
```python
# Add print statements
print(f"Debug: variable_name = {variable_name}")

# Python debugger
import pdb; pdb.set_trace()
```

```javascript
// Console logging
console.log('Debug: variableName =', variableName);

// Node debugger
debugger;
```

**Hypothesis formation:**
- What do you think is causing this?
- Why do you think that?
- How can you verify your hypothesis?

**Test your hypothesis:**
- Make a small change
- Test if it fixes or changes the behavior
- Confirms or rules out your theory

### 4. Implement Fix

**Plan the fix:**
- What needs to change?
- Minimal change that solves the problem
- Won't break other functionality
- Handles edge cases

**Make the code change:**
```bash
# Create a fix branch if working on production
git checkout -b fix/bug-description

# Edit the necessary files
# Apply your fix
```

**Types of fixes:**

**Add validation:**
```python
# Before
result = data['field'] * 2

# After
if 'field' in data and isinstance(data['field'], (int, float)):
    result = data['field'] * 2
else:
    raise ValueError("Invalid field data")
```

**Fix logic:**
```javascript
// Before
if (count > 0) {  // Wrong condition

// After
if (count >= 0) {  // Correct condition
```

**Add error handling:**
```python
# Before
response = requests.get(url)
data = response.json()

# After
try:
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    data = response.json()
except requests.exceptions.RequestException as e:
    logger.error(f"API request failed: {e}")
    return None
```

**Update dependencies:**
```bash
# Fix version conflicts
pip install package==correct.version

# Update package.json
npm install package@correct.version
```

**Commit the fix:**
```bash
git add .
git commit -m "fix: Resolve bug-description

- Root cause: explanation
- Solution: what was changed
- Tested: scenarios verified"
```

### 5. Test the Fix

**Test the original bug:**
- Run the exact reproduction steps
- Verify the error no longer occurs
- Confirm expected behavior now happens

**Test related functionality:**
- Ensure fix didn't break other features
- Run related test cases
- Check edge cases

**Run automated tests if available:**
```bash
# Python
pytest tests/

# Node.js
npm test

# R
R CMD check
```

**Manual testing:**
- Test with various inputs
- Test boundary conditions
- Test error scenarios

**Performance check:**
- Verify fix doesn't slow things down
- Check resource usage
- Monitor for new errors

**Document test results:**
```
Test Results:
✓ Original bug no longer reproduces
✓ Feature works with valid input
✓ Handles invalid input gracefully
✓ Edge cases covered
✓ No performance regression
✓ Related features still work
```

### 6. Document What Went Wrong and the Solution

**Update code comments:**
```python
# Fixed: Bug where null values caused crashes
# Now validates data before processing
if data is not None and len(data) > 0:
    process(data)
```

**Create/update CHANGELOG.md:**
```markdown
## [1.0.1] - 2026-04-01

### Fixed
- Resolved TypeError when processing empty datasets
- Added validation for API response data
- Fixed off-by-one error in pagination logic
```

**Document in project notes:**
```markdown
# Bug Fix: TypeError in Data Processor

## Issue
Application crashed when processing empty datasets from API.

## Root Cause
Code assumed data would always be present. API sometimes
returns empty array for valid requests.

## Solution
Added validation to check for empty data before processing.
Returns early with appropriate message instead of crashing.

## Prevention
Added unit tests for empty data scenarios to catch this
type of issue in the future.
```

**Add tests to prevent regression:**
```python
def test_handles_empty_data():
    """Ensure processor handles empty data gracefully."""
    result = process_data([])
    assert result is not None
    assert result == expected_empty_result
```

### 7. Report to Henry

**Send completion message:**

```
To: Henry
Subject: [Fixed] Bug Name/Description

Status: Fixed and tested

Bug: Brief description of the issue

Root cause:
- What was causing the problem
- Why it happened

Solution:
- What was changed
- How it fixes the issue

Testing:
- Original bug verified fixed
- Related functionality tested
- No regressions found

Files changed:
- path/to/file1.py
- path/to/file2.js

Commit: fix/bug-description (commit hash)

Prevention:
- Added tests to catch this in future
- Updated validation logic
- Documented edge case

Ready for deployment. Issue resolved.
```

**Optional: Suggest improvements:**
- Better error handling elsewhere
- Additional monitoring
- Related issues to address
- Code refactoring opportunities

## Debugging Tools & Techniques

### Python
```python
# Logging
import logging
logging.debug("Variable value: %s", var)

# Stack trace
import traceback
traceback.print_exc()

# Interactive debugger
import pdb
pdb.set_trace()
```

### Node.js
```javascript
// Detailed logging
console.log('Object:', JSON.stringify(obj, null, 2));

// Stack trace
console.trace();

// Debug module
const debug = require('debug')('app:module');
debug('Debug message');
```

### R
```r
# Print debugging
print(paste("Value:", variable))

# Traceback
traceback()

# Browser debugger
browser()
```

### Shell
```bash
# Debug mode
set -x  # Print commands as executed
set -e  # Exit on error

# Verbose output
bash -x script.sh
```

## Common Bug Patterns

**Null/Undefined Issues:**
- Always validate before using
- Use optional chaining in JS
- Check existence in Python

**Type Mismatches:**
- Validate input types
- Use type hints/TypeScript
- Convert types explicitly

**Async Issues:**
- Use proper await/promises
- Handle race conditions
- Timeouts and error cases

**Off-by-One:**
- Check loop boundaries
- Array index calculations
- Range start/end values

## Success Criteria

Debug-app skill is successful when:
- Bug no longer reproduces
- Root cause identified and documented
- Fix is tested thoroughly
- No regressions introduced
- Code is cleaner/more robust
- Future occurrences prevented
- Reported to Henry with details

## Tips for Effective Debugging

1. **Reproduce first** - Can't fix what you can't see
2. **Read the error** - Message tells you a lot
3. **Understand before fixing** - Know why it broke
4. **Keep changes minimal** - Fix only what's needed
5. **Test thoroughly** - Verify the fix works
6. **Prevent recurrence** - Add tests, improve validation
7. **Document learnings** - Help future debugging

---

**Remember**: Bugs are learning opportunities. Each fix makes the codebase more robust and your debugging skills sharper. Be systematic, be thorough, and make it better than before.
