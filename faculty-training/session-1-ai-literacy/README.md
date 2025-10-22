# Session 1: AI Literacy for Educators

> **Time**: 9:30 AM – 10:30 AM (1 hour)  
> **Format**: Interactive Workshop  
> **Goal**: Develop AI literacy and create a course AI policy

## 🎯 Learning Objectives

By the end of this session, you will:
- [ ] Understand what AI can and cannot do in educational contexts
- [ ] Explain what "agentic" means for classrooms
- [ ] Identify appropriate and inappropriate uses of AI in learning
- [ ] Draft a 1-page AI Use & Disclosure Policy for your course
- [ ] Evaluate AI tools for educational applicability

## 📋 Session Overview

### Part 1: AI Fundamentals (20 minutes)
- What is AI? What is generative AI?
- Capabilities and limitations
- Understanding "agentic" systems
- AI in education landscape

### Part 2: Hands-On Exploration (25 minutes)
- Live AI demos
- Prompt engineering practice
- Evaluating AI responses

### Part 3: Policy Creation (15 minutes)
- Collaborative policy drafting
- Share and discuss approaches

## 🤖 Understanding AI in Education

### What AI Can Do

**Strengths**:
- ✅ **Pattern Recognition**: Identify syntax errors, code patterns, common approaches
- ✅ **Information Synthesis**: Summarize concepts, explain topics multiple ways
- ✅ **Code Generation**: Produce boilerplate, complete functions, suggest implementations
- ✅ **Transformation**: Refactor code, change formats, translate between languages
- ✅ **Ideation**: Brainstorm approaches, suggest alternatives, generate examples

**Example Uses**:
```
Student: "Explain recursion using a real-world example"
AI: Provides multiple analogies (Russian dolls, directories, family trees)

Student: "Debug this code: [paste code]"
AI: Identifies syntax error and explains why it's wrong

Student: "Show me 3 different ways to sort a list"
AI: Provides bubble sort, merge sort, quicksort with explanations
```

### What AI Cannot (or Should Not) Do

**Limitations**:
- ❌ **Deep Understanding**: No genuine comprehension, just pattern matching
- ❌ **Reliable Correctness**: Can produce plausible but wrong answers
- ❌ **Contextual Judgment**: Lacks domain-specific expertise
- ❌ **Creative Problem-Solving**: Cannot truly innovate beyond training data
- ❌ **Ethical Reasoning**: No moral compass or values-based decisions
- ❌ **Verification**: Cannot guarantee its own correctness

**Example Failures**:
```
Student: "Is this the best algorithm for my use case?"
AI: Suggests an algorithm without knowing performance requirements, data size, etc.

Student: "Write my final project"
AI: Generates code that may work but student learns nothing

Student: "Is it ethical to use facial recognition here?"
AI: Provides pros/cons but cannot make ethical judgments
```

### What is "Agentic"?

**Traditional AI (Assistive)**:
- Single-turn interactions
- Human prompts → AI responds
- No planning or tool use
- Example: "Write a function to sort numbers"

**Agentic AI**:
- Multi-step reasoning
- Can plan, execute, and reflect
- Uses tools and resources
- Example: Agent breaks down "build a web app" into:
  1. Design data model
  2. Create API endpoints
  3. Build frontend
  4. Write tests
  5. Deploy

**Implications for Teaching**:
- Students need to understand agentic workflows
- Projects can be designed around agent roles
- Learning focuses on orchestration, not just coding
- Critical thinking becomes even more important

---

## 💻 Hands-On Activities

### Activity 1: Prompt Engineering (10 minutes)

**Goal**: Learn to write effective prompts

**Exercise**: Try these prompts with [Microsoft Copilot](https://copilot.microsoft.com/) or ChatGPT:

#### Prompt Set 1: Vague vs. Specific
```
❌ Vague: "Tell me about sorting"

✅ Specific: "Explain bubble sort algorithm to a college freshman 
who knows basic Python. Include time complexity and a simple example."
```

**Observe**: How do responses differ?

#### Prompt Set 2: Asking for Learning
```
❌ Solution-focused: "Write code to find prime numbers"

✅ Learning-focused: "Explain the logic for checking if a number 
is prime. What are the key concepts I need to understand?"
```

**Observe**: Which approach helps learning more?

#### Prompt Set 3: Requesting Multiple Perspectives
```
✅ "Explain recursion using 3 different real-world analogies. 
For each, explain what represents the base case and recursive case."
```

**Observe**: Do different analogies help understanding?

**Key Takeaways**:
- Specificity matters
- Context helps AI give better responses
- Ask for explanations, not just solutions
- Request multiple approaches for comparison

---

### Activity 2: Evaluating AI Responses (10 minutes)

**Goal**: Develop critical evaluation skills

**Exercise**: For each AI response, identify issues:

#### Example 1: Code Suggestion
```python
# Prompt: "Sort a list of numbers"
# AI Response:
def sort_numbers(numbers):
    for i in range(len(numbers)):
        for j in range(i+1, len(numbers)):
            if numbers[i] > numbers[j]:
                numbers[i], numbers[j] = numbers[j], numbers[i]
    return numbers
```

**Discussion Questions**:
- Is this correct? (Yes, bubble sort)
- Is this the best approach? (Depends on context)
- What's missing? (Comments, edge case handling, time complexity note)
- What would you teach students to ask? ("What's the time complexity?")

#### Example 2: Conceptual Explanation
```
Prompt: "What's the difference between a list and a dictionary in Python?"

AI Response: "A list is ordered and indexed by integers. 
A dictionary is unordered and indexed by keys."
```

**Discussion Questions**:
- Is this correct? (Partially - dicts are ordered as of Python 3.7)
- What's missing? (Use cases, when to choose which)
- How would you improve this prompt? (Ask for examples, trade-offs)

#### Example 3: Problem-Solving Approach
```
Prompt: "How do I make my web app faster?"

AI Response: "Use caching, optimize database queries, 
minify assets, use a CDN, enable gzip compression..."
```

**Discussion Questions**:
- Is this helpful? (Generic, not specific to user's problem)
- What's the issue? (No diagnosis of actual bottleneck)
- What should student ask first? ("How do I identify performance bottlenecks?")

**Key Takeaways**:
- Always verify AI suggestions
- Context matters immensely
- Generic advice may not apply to specific situations
- Teaching students to ask good follow-up questions is crucial

---

### Activity 3: Exploring Agentic Systems (5 minutes)

**Goal**: See multi-agent workflows in action

**Demo Sites** (all free):
1. **Hugging Face Spaces** - [huggingface.co/spaces](https://huggingface.co/spaces)
   - Search for "agent" or "multi-agent"
   - Try a simple agent demo
   - Observe: planning → execution → reflection

2. **GitHub Projects** - [github.com/features/issues](https://github.com/features/issues)
   - Show how issues can represent agent tasks
   - Kanban board for workflow visualization
   - Discuss: How could students model agent roles?

**Discussion**:
- How is this different from single-prompt AI?
- What skills do students need for agentic workflows?
- How might you structure a project around agent roles?

---

## 📝 Policy Creation Workshop

### Goal
Create a 1-page AI Use & Disclosure Policy for your course

### Template Provided
Use [`../policies/ai-use-disclosure.md`](../policies/ai-use-disclosure.md) as a starting point.

### Key Sections to Customize

#### 1. Permitted Uses
**Consider**:
- What AI tools are available to your students?
- What learning objectives can AI support?
- What skills do you want students to develop?

**Example Customizations**:
- For CS101: Focus on learning syntax, understanding concepts
- For Senior Project: Focus on architecture, design patterns
- For Data Science: Focus on interpretation, not just code generation

#### 2. Prohibited Uses
**Consider**:
- What would defeat the learning objectives?
- What constitutes plagiarism in your course?
- What assessments should be AI-free?

**Example Customizations**:
- Exams: "AI tools are not permitted during timed assessments"
- Labs: "Initial implementation must be your own; AI can help refine"
- Projects: "AI can assist with implementation; design must be yours"

#### 3. Disclosure Requirements
**Consider**:
- How much detail do you need?
- What format works for your workflow?
- How will you grade transparency?

**Example Approaches**:
- **Lightweight**: "List AI tools used and for what purpose"
- **Moderate**: "Include 2-3 example prompts and what you learned"
- **Detailed**: "Full AI conversation log + reflection on modifications"

#### 4. Grading Impact
**Consider**:
- Will you reward transparency?
- How will you handle violations?
- What's your late/resubmission policy?

**Example Policies**:
- **Bonus approach**: "+5% for excellent AI disclosure and reflection"
- **Penalty approach**: "-10% for missing/inadequate disclosure"
- **Required approach**: "AI disclosure is mandatory; missing = incomplete"

### Workshop Activity (15 minutes)

**Step 1: Individual Work (5 min)**
- Review the template policy
- Mark sections you want to keep/change/remove
- Jot down customizations for your course

**Step 2: Pair Discussion (5 min)**
- Share with a neighbor
- Discuss different approaches
- Get feedback on your ideas

**Step 3: Group Share (5 min)**
- Volunteer to share your approach
- Class discussion on different policies
- Instructor highlights effective strategies

### Tips for Your Policy

✅ **Do**:
- Be specific and clear
- Provide examples (good and bad)
- Explain the "why" behind rules
- Include a quick reference card
- Make it student-friendly

❌ **Avoid**:
- Vague language ("appropriate use")
- Overly restrictive (banning all AI)
- Overly permissive (no guidelines)
- Punishment-first framing
- Legal jargon

### Next Steps

After this session:
1. Finish customizing your policy
2. Add to your course syllabus
3. Plan a 10-minute day-1 review with students
4. Create a sign-off/acknowledgment form
5. Post policy in course LMS and GitHub

---

## 🎯 Deliverable

**What to Complete**:
Draft a 1-page AI Use & Disclosure Policy for your course

**Required Elements**:
- [ ] Course name and semester
- [ ] Permitted AI uses (with examples)
- [ ] Prohibited AI uses (with examples)
- [ ] Disclosure requirements and format
- [ ] Grading implications (positive and negative)
- [ ] Quick reference card or checklist

**Format Options**:
- Markdown file (recommended for GitHub)
- Google Doc (for collaboration)
- Word document
- PDF

**Submission**:
- Upload to shared folder (link provided)
- Or commit to your faculty GitHub repo
- Or email to instructor

---

## 💡 Key Takeaways

### About AI
1. **AI is a tool**, not a replacement for learning
2. **AI makes mistakes** - students must verify
3. **AI lacks context** - students must provide it
4. **Agentic AI** changes how we structure projects
5. **Critical thinking** is more important than ever

### About Teaching with AI
1. **Transparency is key** - require disclosure
2. **Process matters** - grade the journey, not just destination
3. **Start with policy** - set clear expectations day 1
4. **Model good use** - show students effective prompting
5. **Iterate and adapt** - policies will evolve

### About Your Policy
1. **Make it practical** - students should reference it often
2. **Make it positive** - focus on learning, not just rules
3. **Make it clear** - no ambiguity about expectations
4. **Make it yours** - customize for your course context
5. **Make it live** - update based on what you learn

---

## 📚 Resources

### AI in Education
- [Teaching in the Age of AI](https://github.blog/category/education/)
- [AI Literacy for Educators](https://www.iste.org/ai)
- [Responsible AI Practices](https://www.microsoft.com/en-us/ai/responsible-ai)

### Example Policies
- [Stanford AI Policy Examples](https://communitystandards.stanford.edu/generative-ai-policy-guidance)
- [MIT Guidelines](https://mitsloan.mit.edu/student-life/policies-and-procedures/academic-integrity)

### Prompt Engineering
- [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [Effective Prompting Techniques](https://www.promptingguide.ai/)

---

## ⏭️ Next Session

**Session 2: Hands-On GitHub in Teaching**
- Create your first GitHub Classroom assignment
- Set up Codespaces for zero-config development
- Configure autograding with GitHub Actions

**What to Bring**:
- Your AI policy draft
- Ideas for an assignment to convert
- Questions about GitHub Classroom

---

**Questions?** We have 5 minutes for Q&A before the break.

**Tea Break**: 10:30 - 10:45 AM ☕
