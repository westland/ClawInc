# SKILL: vibe-code

## Description

Build functional micro-applications from plain English descriptions. This skill enables rapid prototyping and development of internal tools without requiring detailed technical specifications. Transform natural language requests into working code.

## Purpose

"Vibe coding" is the art of understanding intent and building functional software quickly. Instead of requiring detailed specs, wireframes, or technical documents, you interpret the essence of what's needed and create it. Perfect for internal tools, marketing dashboards, automation scripts, and rapid prototypes.

## When to Use

- Henry requests a new tool or application
- Need to prototype an idea quickly
- Building internal utilities for the ClawInc team
- Creating marketing analytics dashboards
- Developing automation scripts
- Any request that starts with "Can you build..." or "We need a tool that..."

## Execution Steps

### 1. Parse the Natural Language Request

**Understand the intent:**
- What problem is being solved?
- Who will use this application?
- What are the inputs and outputs?
- What's the core functionality needed?

**Extract requirements:**
- Key features (must-have)
- Nice-to-have features
- Constraints or limitations
- Integration points

**Ask clarifying questions if needed** (but try to infer intelligently first)

### 2. Plan the Architecture

**Choose the tech stack:**
- Python for data processing, APIs, automation
- Node.js for web apps, real-time features
- R for statistical analysis and visualization
- Shell scripts for system automation

**Design the structure:**
- What files/modules are needed?
- What external libraries or APIs?
- How will components interact?
- Where will data be stored?

**Keep it simple:**
- Minimal viable product first
- Can enhance later if needed
- Prefer simple solutions over complex ones

### 3. Create Project Structure

**Set up the project:**
```bash
cd /home/clawuser/projects/
mkdir project-name
cd project-name
git init
```

**Create necessary files:**
- Main application file
- Configuration file if needed
- Requirements/dependencies file
- README.md for documentation

**Initialize version control:**
```bash
git add .
git commit -m "feat: Initial project structure"
```

### 4. Write the Code

**Follow best practices:**
- Clean, readable code
- Inline comments for complex logic
- Proper error handling
- Environment variables for config
- Modular design

**Implement core features first:**
- Get the main functionality working
- Test as you go
- Add enhancements after core works

**Code quality:**
- Follow language style guides
- Use meaningful variable names
- Keep functions focused and small
- Add docstrings/comments

### 5. Test the Application

**Run it end-to-end:**
```bash
# Python
python3 app.py

# Node.js
node app.js

# R
Rscript script.R
```

**Test different scenarios:**
- Happy path (everything works)
- Edge cases (empty input, large data)
- Error conditions (invalid input, missing files)

**Verify outputs:**
- Does it produce correct results?
- Are files created properly?
- Do APIs respond correctly?

**Fix any issues found:**
- Debug errors immediately
- Re-test after fixes
- Don't report until it works

### 6. Document Usage

**Create comprehensive README.md:**

```markdown
# Project Name

## Description
What this application does and why it exists.

## Setup
1. Install dependencies
2. Configure environment
3. Any other setup steps

## Usage
How to run the application with examples.

## Features
- List of main features
- What it can do

## Configuration
Environment variables or config options.

## Examples
Concrete examples of usage.
```

**Include:**
- Clear installation steps
- Usage examples with sample input/output
- Configuration options
- Troubleshooting common issues

### 7. Report to Henry

**Send completion message:**

```
To: Henry
Subject: [Complete] Project Name - Vibe Code Skill

Status: Complete and tested

Project: project-name
Location: /home/clawuser/projects/project-name

What it does:
- Brief description of functionality
- Key features implemented

Tech stack:
- Languages/frameworks used
- Dependencies installed

How to use:
- Quick start command
- Example usage

Testing:
- What was tested
- Results/outputs verified

Notes:
- Any important details
- Suggested improvements
- Known limitations

Ready for use. Awaiting next task.
```

**Commit final version:**
```bash
git add .
git commit -m "feat: Complete vibe-code implementation"
git tag v1.0
```

## Examples of Vibe Code Requests

**Request**: "Build a dashboard that shows our top 10 marketing campaigns by ROI"

**Interpretation**:
- Need data visualization
- Calculate ROI metric
- Sort and display top 10
- Web-based dashboard (Node.js + HTML) or R Shiny

**Request**: "Create a script that pulls data from our ad platforms and saves it to CSV"

**Interpretation**:
- API integration needed
- Data extraction pipeline
- CSV output format
- Python with requests library
- Schedule with cron for automation

**Request**: "Make a tool to analyze sentiment in customer reviews"

**Interpretation**:
- Natural language processing
- Sentiment analysis library
- Process text input
- Output sentiment scores
- Python with nltk or transformers

## Success Criteria

The vibe-code skill is successful when:
- Application works as described
- Code is clean and documented
- README provides clear usage instructions
- All tests pass
- Reported to Henry with complete information
- Project is version controlled

## Tips for Great Vibe Coding

1. **Infer intelligently** - Make reasonable assumptions about requirements
2. **Start simple** - MVP first, enhance later
3. **Test frequently** - Don't wait until the end
4. **Document as you go** - Write README while building
5. **Think like the user** - What would make this easy to use?
6. **Ship fast** - Don't over-engineer
7. **Iterate** - Can always improve in v2

## Anti-Patterns to Avoid

- Over-complicating the solution
- Building features not requested
- Skipping testing phase
- Poor or missing documentation
- Not using version control
- Reporting before testing
- Hardcoding values that should be configurable

---

**Remember**: The goal is to translate intent into working code quickly and reliably. Trust your understanding, build with confidence, test thoroughly, and ship.
