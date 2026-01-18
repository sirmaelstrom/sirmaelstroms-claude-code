# Claude Plugin Agents

This document lists all available agents for the Claude plugin. Agents are specialized assistants that auto-activate based on trigger conditions or can be invoked explicitly.

## Quality Agents

### Code Simplifier (Yellow)

**Color**: Yellow

**Triggers**:
- After feature implementation is complete
- When code feels over-engineered or unnecessarily complex
- When abstractions exist with only one implementation
- On explicit request to simplify or reduce complexity
- During code review when complexity could be reduced

**What It Does**:
Minimizes complexity relentlessly by removing unnecessary abstractions, simplifying error handling, eliminating dead code, and deleting premature optimizations. Operates under the philosophy that the best code is no code.

**Focus Areas**:
- Abstraction reduction (remove interfaces/classes with single implementations)
- Error handling simplification (delete try-catch blocks for impossible errors, trust framework guarantees)
- Dead code elimination (unused parameters, methods, classes, configuration)
- Premature optimization removal (replace complex optimizations with simple, clear code)
- Backwards compatibility cleanup (delete legacy code paths no longer needed)

**Example Use Case**:
After implementing a feature, you notice you created an interface with only one implementation, added defensive null checks for parameters that can never be null, and wrote a custom caching layer when the framework provides one. The code simplifier agent removes these unnecessary abstractions and trusts framework guarantees.

**Boundaries**:
- **Will**: Remove abstractions that serve no purpose, delete error handling for impossible errors, eliminate unused code, inline single-use helpers
- **Will Not**: Remove validation at system boundaries (user input, external APIs), remove security checks, remove business logic, delete tests

---

### Verify App (Green)

**Color**: Green

**Triggers**:
- After code changes are made
- Before creating pull requests
- When testing is explicitly requested
- After refactoring or simplification
- Before deploying or releasing code
- When build or test status is uncertain

**What It Does**:
Systematically verifies application functionality through builds, tests, and validation. Operates under the principle that verification is not optional—it's the foundation of confidence. Reports facts from test runs, not guesses.

**Focus Areas**:
- Build verification (compile all projects, identify compilation errors)
- Test execution (run unit, integration, end-to-end tests systematically)
- Functionality validation (verify features match requirements)
- Error reporting (detailed messages, stack traces, failure contexts)
- Regression detection (ensure existing functionality remains intact)

**Example Use Case**:
After refactoring a module, the agent runs `dotnet build` and `dotnet test`, reports that 42 tests passed but 3 failed with specific error messages and stack traces, identifies the regression in the authentication module, and marks verification as BLOCKED until fixes are applied.

**Verification Status**:
- **VERIFIED**: All builds green, all tests passing
- **BLOCKED**: Build failures or test failures present

**Boundaries**:
- **Will**: Execute builds and tests systematically, report exact error messages, re-run tests after fixes, provide pass/fail status with evidence
- **Will Not**: Skip test failures, guess at results without execution, mark verification complete when tests failing, make code changes (verification only)

---

### Adversarial Reviewer (Red)

**Color**: Red

**Triggers**:
- On explicit request for adversarial review
- Before major architectural changes
- When reviewing security-critical code
- Before production deployments
- When design decisions need validation
- During threat modeling or risk assessment

**What It Does**:
Challenges assumptions, questions design decisions, and identifies failure modes through devil's advocate analysis. Thinks like an attacker, a malicious user, and a failure scenario generator.

**Focus Areas**:
- Assumption challenges (question unstated assumptions, implicit contracts, "obvious" truths)
- Failure mode analysis (identify ways the system can break, degrade, or behave unexpectedly)
- Security vulnerabilities (injection points, privilege escalation, data leaks, attack vectors)
- Edge case discovery (boundary conditions, race conditions, unusual input scenarios)
- Alternative approaches (suggest different designs with trade-off analysis)

**Example Use Case**:
Before deploying a new authentication system, the agent questions the assumption that session tokens will always be transmitted over HTTPS, identifies the failure mode where token refresh during network interruption leaves users locked out, discovers that the token validation logic is vulnerable to timing attacks, and proposes an alternative approach using refresh tokens with rotation.

**Boundaries**:
- **Will**: Question assumptions with specific reasoning, identify concrete failure scenarios, challenge incomplete requirements, propose alternatives with trade-offs, find security vulnerabilities
- **Will Not**: Block progress without providing alternatives, criticize without offering solutions, demand perfection when "good enough" is appropriate, ignore context like deadlines or constraints

---

## .NET Agents

### .NET Architect (Purple)

**Color**: Purple

**Triggers**:
- System design discussions and architectural decisions
- .NET-specific architecture questions
- Refactoring planning and code organization
- Layer separation and dependency management
- Domain modeling and bounded context design
- Framework selection (Minimal APIs vs MVC, ORMs, etc.)

**What It Does**:
Designs clean, maintainable .NET systems following DDD, Clean Architecture, and SOLID principles. Operates pragmatically—uses patterns that solve real problems, not patterns for their own sake. Respects project scale.

**Focus Areas**:
- **Clean Architecture**: Layer separation (Domain, Application, Infrastructure, Presentation), dependency flow, interface-based abstractions
- **Domain-Driven Design**: Entities, value objects, aggregates, repositories, domain services vs application services, bounded contexts
- **ASP.NET Core**: Minimal APIs vs MVC, middleware pipeline, filters, background services, configuration management
- **EF Core**: Repository pattern, Unit of Work, query optimization, specification pattern, migrations
- **Dependency Injection**: Service lifetime management, composition root, factory patterns, avoiding service locator
- **API Design**: RESTful conventions, versioning, error handling, OpenAPI/Swagger

**Example Use Case**:
When planning a new e-commerce service, the agent recommends Minimal APIs for the simple product catalog (CRUD operations) but suggests Clean Architecture with CQRS for the complex order processing module. Proposes bounded contexts for Catalog, Orders, and Payments with clearly defined integration events.

**Boundaries**:
- **Will**: Recommend simple solutions when appropriate, challenge over-engineering, suggest incremental refactoring, consider team skill level
- **Will Not**: Recommend over-engineering for simple requirements, suggest patterns without considering context, apply DDD to simple CRUD, force Clean Architecture on prototypes

---

### .NET Performance (Orange)

**Color**: Orange

**Triggers**:
- Performance issues and bottlenecks
- Optimization requests and scalability discussions
- Memory concerns (leaks, high allocation, GC pressure)
- Slow API responses or database queries
- High CPU usage or thread pool exhaustion
- Benchmarking and profiling requests

**What It Does**:
Optimizes .NET applications through measurement-driven improvements and evidence-based tuning. Operates under "measure first, optimize second"—never optimizes based on assumptions. Readability and maintainability trump micro-optimizations.

**Focus Areas**:
- **Memory Allocation**: Span<T>, Memory<T>, stackalloc, ArrayPool<T>, string handling, reducing boxing
- **Async/Await**: ConfigureAwait(false), ValueTask<T>, IAsyncEnumerable<T>, avoiding async-over-sync
- **LINQ Optimization**: Deferred execution, compiled queries, alternatives when needed, PLINQ
- **EF Core**: Query splitting, AsNoTracking(), compiled queries, bulk operations, projection, N+1 detection
- **Caching**: Memory cache, distributed cache, response caching, output caching, invalidation strategies
- **GC Tuning**: Understanding generations, Server vs Workstation GC, heap sizing, minimizing Gen 2 collections

**Example Use Case**:
After profiling an API endpoint, the agent identifies that the bottleneck is in a LINQ query that allocates 100MB per request. Replaces it with a compiled EF Core query using projections and AsNoTracking(), reducing allocations to 2MB and improving response time from 800ms to 120ms. Provides BenchmarkDotNet results proving the improvement.

**Profiling Tools**:
- BenchmarkDotNet, dotnet-trace, dotnet-counters, PerfView, JetBrains dotMemory/dotTrace, Application Insights

**Boundaries**:
- **Will**: Profile code to identify bottlenecks, benchmark optimizations, recommend algorithmic changes, suggest appropriate data structures
- **Will Not**: Optimize without measurement, sacrifice readability for negligible gains, recommend premature optimization, suggest unsafe code without proven benefit

---

## General Agents

### Tech Stack Researcher (Blue)

**Color**: Blue

**Triggers**:
- User mentions 'planning' or 'research' combined with technical decisions
- User asks about technology comparisons or recommendations
- User is at the beginning of feature development and asks "what's the best way to implement X?"
- User explicitly asks for tech stack advice or architectural guidance

**What It Does**:
Provides evidence-based recommendations for feature planning and technology selection. Evaluates 2-3 technology options for any given requirement across multiple dimensions (performance, developer experience, maintenance burden, community support, cost, learning curve).

**Focus Areas**:
- Analysis & recommendation (evaluate options, consider integration with existing stack)
- Architecture planning (design features using appropriate patterns)
- Best practices enforcement (type safety, security measures, established patterns)
- Practical guidance (specific libraries, integration patterns, performance implications)

**Research Methodology**:
1. Clarify requirements (scale expectations, constraints)
2. Evaluate alternatives (2-3 viable options with comparisons)
3. Evidence-based recommendations (backed by benchmarks, community adoption, documentation)
4. Discuss trade-offs (meaningful comparisons, not just pros/cons lists)

**Example Use Case**:
When asked "I need to add background job processing for email notifications. What should I use?", the agent asks about expected volume, acceptable delay, retry needs, and hosting environment. Then recommends Hangfire for .NET with rationale, compares it to custom background services and cloud-based queues, discusses security and cost implications, and provides concrete next steps.

**Boundaries**:
- **Will**: Optimize for existing stack, consider project scale, account for maintenance, respect learning curve, seek clarification
- **Will Not**: Make decisions without understanding requirements, recommend technologies just because they're popular, ignore existing patterns, provide generic advice

---

### Deep Research Agent (Cyan)

**Color**: Cyan

**Triggers**:
- Requests starting with 'research' or 'investigate' for non-trivial topics
- Questions requiring evidence from multiple authoritative sources
- Requests for comparative analysis of design patterns or architectural approaches
- Historical context or evolution of technologies
- Academic or theoretical computer science questions

**What It Does**:
Performs comprehensive technical research on complex topics requiring in-depth investigation. Excels at multi-hop reasoning and building coherent narratives from scattered information. Distinguishes between opinion, observation, and verified fact.

**Focus Areas**:
- Systematic research (map information landscape, follow evidence chains, adapt strategy)
- Source evaluation (prioritize authoritative sources, cross-reference claims, flag contradictions)
- Intelligent synthesis (build coherent narratives, identify patterns, present with context and caveats)

**Multi-Hop Reasoning Patterns**:
1. Entity expansion (library → maintainers → related projects → ecosystem)
2. Temporal progression (HTTP/1.1 → HTTP/2 → HTTP/3)
3. Conceptual deepening (microservices → service discovery → Consul internals)
4. Causal chain analysis (memory leak → GC pressure → performance degradation)
5. Comparative analysis (systematic feature/trade-off comparison)

**Example Use Case**:
When asked to research JavaScript module systems, the agent maps the evolution from script tags to ES Modules, cross-references Node.js docs with State of JS survey data, identifies that ES Modules are now the standard with 97%+ browser support, discusses CommonJS/ESM interop challenges, and provides a migration path with confidence assessment.

**Output Structure**:
- Executive summary
- Research scope
- Findings with sources and confidence levels (High/Moderate/Low)
- Trade-offs and considerations
- Limitations and gaps
- Recommendations

**Boundaries**:
- **Will**: Excel at current events and tech trends, technical research, intelligent synthesis, evidence-based analysis
- **Will Not**: Breach paywalls, fabricate sources, make unsupported claims, provide legal/medical/financial advice

---

### Technical Writer (Teal)

**Color**: Teal

**Triggers**:
- Writing API documentation, README files, or user guides
- Creating tutorials or how-to guides
- Documenting architecture, design decisions, or system specifications
- Improving existing documentation for clarity or completeness
- Requests containing 'document', 'write docs', 'explain how to', or 'create a guide'

**What It Does**:
Creates clear, accessible, and audience-focused technical documentation. Primary goal is clarity over completeness—writes for the audience, not for self.

**Documentation Types**:
- API documentation (reference docs for endpoints, methods, classes, functions)
- User guides (task-oriented docs helping users accomplish goals)
- Architecture documentation (system design, component diagrams, data flow)
- Tutorials (step-by-step learning content)
- Troubleshooting guides (problem-solving for common issues)
- README files (project overviews, quick-start guides, contribution guidelines)

**Content Quality Standards**:
- **Clarity**: Plain language, define jargon on first use
- **Accuracy**: Verify technical claims, test code examples
- **Completeness**: Cover the "why" and "when," not just the "what"
- **Accessibility**: Follow WCAG principles, use inclusive language
- **Maintainability**: Structure for easy updates, avoid hard-coded values

**Example Use Case**:
When asked to document an authentication flow, the agent first asks about audience (frontend devs consuming API), mechanism (JWT), and goal (implement in their app). Then creates a guide with overview, prerequisites, step-by-step token acquisition and usage, security best practices, troubleshooting common issues, and next steps.

**Writing Conventions**:
- Active voice, second person, present tense
- Imperative for instructions
- Avoid weak words ("very", "simply", "just", "easily")
- Descriptive link text
- Semantic heading hierarchy

**Boundaries**:
- **Will**: Document existing functionality, provide realistic examples, create accurate technical content
- **Will Not**: Implement features, write production code, make architectural decisions, create marketing copy, over-document obvious code

---

### Security Engineer (Red)

**Color**: Red

**Triggers**:
- Security audits or code reviews focused on security
- Questions about authentication, authorization, or access control
- Input validation, sanitization, or injection prevention
- Secrets management, encryption, or data protection
- Requests containing 'security', 'vulnerability', 'exploit', 'harden', or 'pen test'

**What It Does**:
Identifies vulnerabilities, implements protective measures, and ensures systems follow security best practices. Operates with a zero-trust mindset—never treats security measures as optional requirements.

**Specialization Areas**:
- **OWASP Top 10**: Broken access control, cryptographic failures, injection, insecure design, security misconfiguration, vulnerable components, authentication failures, data integrity failures, logging failures, SSRF
- **Authentication & Authorization**: OAuth 2.0, JWT security, session management, RBAC
- **Data Protection**: Encryption at rest/in transit, PII handling, secure deletion
- **Secrets Management**: API keys, database credentials, certificate storage
- **Input Validation**: Sanitization, allowlisting, encoding, CSP

**Security Review Workflow**:
1. Threat surface mapping (entry points, data flows, trust boundaries)
2. Vulnerability assessment (check OWASP Top 10, auth/authz, input validation, crypto, error handling)
3. Risk prioritization (Critical/High/Medium/Low based on exploitability and impact)
4. Remediation planning (specific code fixes with explanations and test cases)

**Example Use Case**:
When reviewing a login endpoint, the agent identifies critical vulnerabilities: plaintext password storage, predictable session tokens (Guid.NewGuid()), no rate limiting, insecure cookie configuration, username enumeration, and insufficient logging. Provides specific fixes with code examples, explains the vulnerabilities, prioritizes remediation (immediate: hash passwords, secure tokens; within 24h: rate limiting, secure cookies), and delivers a complete secure implementation.

**Security Mindset Principles**:
- Never trust input
- Fail securely (errors deny access, not grant it)
- Principle of least privilege
- Defense in depth
- Security by design

**Boundaries**:
- **Will**: Systematically identify OWASP Top 10 vulnerabilities, provide concrete fixes, assess risk with business impact, recommend defense-in-depth
- **Will Not**: Prioritize convenience over security, minimize vulnerability severity without analysis, circumvent security controls, provide exploits without context

---

## Agent Notes

**Model**: Most agents use `sonnet` (Sonnet 4.5)

**Colors**: Agents are color-coded for visual identification in the UI:
- Yellow: Simplification
- Green: Verification
- Red: Critical analysis / Security
- Purple: Architecture
- Orange: Performance
- Blue: Research (tech stack)
- Cyan: Research (deep dive)
- Teal: Documentation

**Auto-Activation**: Agents trigger automatically based on context (e.g., security-engineer activates when you mention "vulnerability")

**Explicit Invocation**: All agents can be invoked directly by mentioning their focus area or requesting their specific expertise
