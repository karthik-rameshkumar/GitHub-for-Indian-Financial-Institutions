# Session 3: Copilot for Learning (Education)

> **Time**: 12:00 PM – 1:00 PM (1 hour)  
> **Format**: Demo + Hands-On Lab  
> **Goal**: Design Copilot-aware assignments that enhance learning

## 🎯 Learning Objectives

By the end of this session, you will:
- [ ] Understand how GitHub Copilot works in educational contexts
- [ ] Use Copilot effectively to accelerate understanding (not shortcut learning)
- [ ] Design assignments that leverage Copilot as a learning tool
- [ ] Create prompts that encourage critical thinking
- [ ] Develop assessment strategies for Copilot-assisted work

## 📋 Session Overview

### Part 1: Copilot Demo (20 minutes)
- What is GitHub Copilot?
- How it works (code completion, chat, explanations)
- Educational access and setup
- Live coding demonstrations

### Part 2: Effective Use for Learning (20 minutes)
- Prompting strategies for students
- Comparing explanations for critical thinking
- Test-driven development with Copilot
- Common pitfalls and how to avoid them

### Part 3: Assignment Design (20 minutes)
- Creating Copilot-friendly assignment briefs
- Building in disclosure requirements
- Assessment approaches
- Hands-on: Design your assignment

## 🤖 Understanding GitHub Copilot

### What is GitHub Copilot?

**GitHub Copilot** is an AI pair programmer that:
- Suggests code completions as you type
- Generates entire functions from comments
- Explains existing code
- Answers programming questions via chat
- Generates tests and documentation

**Two Main Interfaces**:
1. **Inline Suggestions**: Completes code as you type (gray text preview)
2. **Chat Interface**: Ask questions, get explanations, request refactoring

### Educational Access

**Free for Verified Students and Teachers**:
- Apply at [education.github.com/benefits](https://education.github.com/benefits)
- Upload proof of academic affiliation
- Get approved (typically within 1-3 days)
- Access Copilot in VS Code, github.dev, or other IDEs

**What's Included**:
- GitHub Copilot (code completions)
- GitHub Copilot Chat (conversational interface)
- Full access to all models
- No monthly limit (subject to fair use)

### How It Works

**Training**:
- Trained on billions of lines of public code
- Understands syntax, patterns, and idioms
- Context-aware (sees your open files)
- Updated regularly with new models

**Important Limitations**:
- ❌ Not always correct
- ❌ May suggest deprecated patterns
- ❌ Can't understand your specific requirements
- ❌ Might suggest insecure code
- ❌ Doesn't understand business logic

**This is why student learning and verification are critical!**

---

## 💻 Live Demos

### Demo 1: Basic Code Completion

**Scenario**: Writing a Python function

```python
# Demo: Function from comment
# Write a function to calculate factorial recursively

# Watch as Copilot suggests:
def factorial(n):
    if n == 0 or n == 1:
        return 1
    return n * factorial(n - 1)
```

**Teaching Moment**:
- **Don't just accept** - understand the logic
- **Ask Copilot Chat**: "Explain how this factorial function works"
- **Ask for alternatives**: "Show me an iterative version"
- **Test edge cases**: What happens with negative numbers?

### Demo 2: Copilot Chat for Understanding

**Scenario**: Understanding existing code

```python
# Prompt in Copilot Chat:
# "Explain this code in simple terms: [paste code]"

# Or more specific:
# "What's the time complexity of this algorithm?"
# "What edge cases should I test for?"
# "How could I make this code more readable?"
```

**Teaching Moment**:
- Use Chat to learn, not just to get code
- Ask "why" questions
- Request multiple explanations
- Compare Chat response with course materials

### Demo 3: Test-Driven Development

**Scenario**: Writing tests first, then using Copilot for implementation

```python
# 1. Write test first (manually)
def test_palindrome_checker():
    assert is_palindrome("racecar") == True
    assert is_palindrome("hello") == False
    assert is_palindrome("A man a plan a canal Panama") == True
    assert is_palindrome("") == True

# 2. Write function signature and comment
def is_palindrome(s):
    """
    Check if a string is a palindrome.
    Ignore spaces, punctuation, and case.
    """
    # Copilot will suggest implementation here

# 3. Review, understand, and modify suggestion
# 4. Run tests to verify
```

**Teaching Moment**:
- Tests define requirements clearly
- Copilot helps with implementation details
- Student still needs to verify correctness
- Encourages thinking about edge cases first

### Demo 4: Debugging with Copilot

**Scenario**: Understanding error messages

```python
# Code with an error:
numbers = [1, 2, 3, 4, 5]
print(numbers[10])  # IndexError!

# Ask Copilot Chat:
# "Why am I getting 'IndexError: list index out of range'?"
# "How do I safely access list elements?"
# "What's the best way to handle this error?"
```

**Teaching Moment**:
- Copilot explains errors in plain language
- Suggests multiple solutions
- Helps student understand, not just fix
- Still requires student to choose approach

---

## 📚 Teaching Strategies with Copilot

### Strategy 1: Compare and Contrast

**Assignment Approach**:
Ask students to:
1. Solve a problem manually first
2. Ask Copilot for a solution
3. Compare the two approaches
4. Explain which is better and why

**Example Prompt for Students**:
```
Problem: Sort a list of dictionaries by a specific key

Your task:
1. Write your own solution
2. Ask Copilot: "Sort a list of dictionaries by the 'age' key"
3. Compare your solution to Copilot's
4. Answer:
   - What's similar?
   - What's different?
   - Which is better? Why?
   - What did you learn from the comparison?
```

**Learning Outcomes**:
- Critical evaluation skills
- Understanding multiple approaches
- Justification and reasoning
- Metacognition about their own code

---

### Strategy 2: Explanation Chain

**Assignment Approach**:
Require students to explain Copilot-generated code at multiple levels:
1. **Line-by-line**: What does each line do?
2. **Conceptual**: What algorithm/pattern is this?
3. **Trade-offs**: What are pros and cons of this approach?

**Example Assignment Section**:
```markdown
## Task 3: Binary Search Implementation

1. Use Copilot to generate a binary search function
2. Include the Copilot-generated code in your submission
3. Provide three levels of explanation:
   
   ### Level 1: Line-by-Line
   [Explain what each line does]
   
   ### Level 2: Conceptual
   [Explain the algorithm and why it works]
   
   ### Level 3: Analysis
   [Time complexity, space complexity, when to use vs. not use]
```

**Grading Focus**:
- Quality of explanation, not quality of code
- Depth of understanding
- Accuracy of analysis

---

### Strategy 3: Test-First Development

**Assignment Approach**:
Students write tests first, then use Copilot for implementation:

1. Provide test suite (or students write it)
2. Students use Copilot to implement functions
3. Verify tests pass
4. Reflect on the process

**Example Framework**:
```python
# tests/test_assignment.py (provided to students)
def test_calculate_grade():
    assert calculate_grade(95) == "A"
    assert calculate_grade(85) == "B"
    assert calculate_grade(75) == "C"
    assert calculate_grade(50) == "F"
    assert calculate_grade(101) == "Invalid"

# student_code.py (students complete)
def calculate_grade(score):
    """
    Convert numeric score to letter grade.
    Use Copilot to help implement this.
    """
    # TODO: Implement with Copilot's help
    pass

# reflection.md (students complete)
"""
1. What prompt did you give Copilot?
2. Did Copilot's solution pass all tests immediately?
3. What modifications did you make?
4. What did you learn about grade calculation logic?
"""
```

**Benefits**:
- Requirements are clear (tests define them)
- Copilot assists but doesn't decide requirements
- Easy to verify correctness
- Focus on understanding over typing

---

### Strategy 4: Iterative Refinement

**Assignment Approach**:
Students start with Copilot, then improve:

1. Get initial solution from Copilot
2. Identify limitations
3. Iteratively improve
4. Document the journey

**Example Assignment**:
```markdown
## Progressive Enhancement Challenge

### Step 1: Initial Implementation (Copilot)
Use Copilot to generate a function that [does X]
- [ ] Include the prompt you used
- [ ] Include Copilot's suggestion
- [ ] Run initial tests

### Step 2: Identify Issues
Analyze Copilot's solution:
- [ ] What edge cases does it miss?
- [ ] What could be more efficient?
- [ ] What's hard to understand?

### Step 3: Improve
Modify Copilot's solution:
- [ ] Add edge case handling
- [ ] Improve performance
- [ ] Enhance readability
- [ ] Add error handling

### Step 4: Reflect
- What did Copilot do well?
- What did you have to fix?
- What did you learn in the process?
```

**Learning Outcomes**:
- Critical evaluation
- Code improvement skills
- Understanding of software quality
- Ownership of the solution

---

## 🎯 Designing Copilot-Aware Assignments

### Template Structure

**Core Components**:
1. **Learning Objectives** (what skills to develop)
2. **Copilot Usage Guidelines** (what's encouraged/required)
3. **Disclosure Requirements** (how to document AI use)
4. **Prompts to Try** (starter prompts for students)
5. **Reflection Questions** (what did you learn?)

### Example: Copilot-Aware Assignment Brief

```markdown
# Assignment 4: Data Structures Implementation

## Learning Objectives
- Understand stack data structure
- Implement push, pop, peek operations
- Handle edge cases and errors
- Use test-driven development

## Copilot Usage Policy for This Assignment

✅ **Encouraged**:
- Ask Copilot to explain stack concepts
- Use Copilot to generate test cases
- Get Copilot's help with syntax
- Request multiple implementation approaches

✅ **Required**:
- Document all Copilot interactions
- Explain why you chose one approach over others
- Write your own tests first, then implement
- Modify Copilot suggestions to handle edge cases

❌ **Not Allowed**:
- Accepting Copilot suggestions without understanding them
- Skipping the test-writing phase
- Submitting without reflection

## Suggested Prompts

### Understanding
- "Explain how a stack data structure works with real-world analogies"
- "What are the key operations for a stack?"
- "What's the difference between stack and queue?"

### Implementation
- "Generate a Stack class in Python with push, pop, and peek methods"
- "How should I handle popping from an empty stack?"
- "Show me two different ways to implement a stack"

### Testing
- "Generate test cases for a stack implementation"
- "What edge cases should I test for stack operations?"
- "Create a test for stack overflow scenarios"

## Disclosure Requirements

Include this section in your README.md:

### Copilot Assistance Log

#### Prompt 1: [Your prompt]
**Copilot Response**: [Paste response]
**Used**: [Yes/No and what parts]
**Why**: [Reason for accepting/rejecting]

#### Prompt 2: [Your prompt]
...

### Reflection
- What did Copilot help you understand?
- What did Copilot get wrong or miss?
- How did using Copilot change your development process?
- What would you do differently next time?

## Grading

- **Functionality** (30%): Stack works correctly
- **Tests** (20%): Comprehensive test coverage
- **Code Quality** (20%): Readable, well-structured
- **Copilot Disclosure** (15%): Complete and thoughtful
- **Reflection** (15%): Demonstrates learning

**Bonus** (+10%): Excellent explanation of trade-offs between different approaches
```

---

## 💻 Hands-On Activity (15 minutes)

### Your Turn: Design a Copilot-Aware Assignment

**Goal**: Adapt one of your existing assignments for Copilot

**Steps**:

#### 1. Choose an Assignment (2 min)
Pick a programming assignment from your course:
- Not too simple (basic syntax practice)
- Not too complex (multi-week project)
- Has clear learning objectives
- Would benefit from AI assistance

#### 2. Identify Learning Objectives (3 min)
What should students learn?
- [ ] Specific programming concepts
- [ ] Problem-solving approaches
- [ ] Testing strategies
- [ ] Code quality principles

#### 3. Define Copilot Guidelines (5 min)
For your assignment, decide:

**Encouraged Uses**:
- [ ] Understanding concepts
- [ ] Generating test cases
- [ ] Exploring alternatives
- [ ] Debugging help

**Required Elements**:
- [ ] Specific disclosure format
- [ ] Reflection questions
- [ ] Comparison activities
- [ ] Manual work before AI

**Prohibited Uses**:
- [ ] Complete end-to-end generation
- [ ] Zero modification of suggestions
- [ ] Skipping understanding phase

#### 4. Create Sample Prompts (3 min)
Write 3-5 prompts students could use:

**For Understanding**:
```
Example: "Explain [concept] in the context of [your assignment]"
```

**For Implementation**:
```
Example: "Generate [function] that [does X] with [constraints]"
```

**For Testing**:
```
Example: "What edge cases should I test for [feature]?"
```

#### 5. Draft Disclosure Requirements (2 min)
What must students submit?
- [ ] Prompts used
- [ ] Modifications made
- [ ] Learning reflection
- [ ] Code comparison

### Share Out (5 minutes)
Volunteer to share your assignment adaptation with the group

---

## 🎯 Deliverables

By the end of this session:

✅ **Copilot-Friendly Assignment Brief**
- Learning objectives
- Copilot usage guidelines
- Sample prompts for students
- Disclosure requirements
- Reflection questions

✅ **Test-Driven Template** (optional but encouraged)
- Starter test suite
- Function signatures to implement
- Rubric emphasizing understanding

**Submission**:
- Add to your faculty training folder
- Share in GitHub Discussions
- Get feedback from peers

---

## 💡 Best Practices

### For Faculty

✅ **Do**:
- Model good Copilot use in class
- Show students how to ask good questions
- Demonstrate comparing multiple approaches
- Emphasize verification and testing
- Reward thoughtful AI use

❌ **Don't**:
- Assume students know how to use Copilot effectively
- Make all assignments Copilot-friendly (vary the approach)
- Grade only on output quality
- Ban Copilot entirely (students will use it anyway)
- Forget to update policy as tools evolve

### For Students (Share These Tips)

✅ **Effective Copilot Use**:
- Start with your own attempt
- Use Copilot to check understanding
- Always test suggestions
- Modify to fit your specific needs
- Ask for explanations, not just code

❌ **Ineffective Copilot Use**:
- Accepting suggestions blindly
- Copy-pasting without understanding
- Using Copilot before thinking
- Skipping verification
- Not documenting what you learned

---

## 📚 Resources

### GitHub Copilot Documentation
- [Copilot Quickstart](https://docs.github.com/en/copilot/quickstart)
- [Using Copilot Chat](https://docs.github.com/en/copilot/using-github-copilot/asking-github-copilot-questions)
- [Best Practices](https://docs.github.com/en/copilot/using-github-copilot/best-practices-for-using-github-copilot)

### Educational Resources
- [Teaching with Copilot](https://github.blog/category/education/)
- [Copilot in the Classroom](https://education.github.com/experiences/copilot)

### Setup Help
- [Installing Copilot](https://docs.github.com/en/copilot/using-github-copilot/getting-started-with-github-copilot)
- [Education Benefits](https://education.github.com/benefits)

---

## ⏭️ Next Session (After Lunch)

**Session 4: Agentic Futures: Multi-Agent Patterns**
- Understanding multi-agent workflows
- Mapping projects to agent roles
- Designing agentic assignments
- Human-only decision points

**What to Bring**:
- Your Copilot-aware assignment draft
- Ideas for a larger project that could use agentic workflow
- Questions about AI in your classroom

---

**Lunch Break**: 1:00 - 2:00 PM 🍽️

Enjoy your lunch! See you back at 2:00 PM.
