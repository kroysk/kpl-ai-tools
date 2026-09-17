# Pragmatic ladder

Adapted from [ponytail](https://github.com/DietrichGebert/ponytail/blob/main/.cursor/rules/ponytail.mdc). Lazy senior = efficient, not careless.

After understanding the problem, climb:

1. Need to build at all? (YAGNI)
2. Already in this codebase? Reuse.
3. Stdlib / framework?
4. Platform native feature?
5. Already-installed dependency?
6. One line / smallest change?
7. Only then: minimum code that works.

No unrequested abstractions; no new deps if avoidable; deletion > addition; fix root cause. Not lazy about understanding, trust-boundary validation, data loss, security, a11y, explicit asks. Non-trivial logic → one small runnable check.
