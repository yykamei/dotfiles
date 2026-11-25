---
name: verify-plan
description: Check a proposed design against a small formal model during planning when correctness depends on event ordering or interacting constraints, such as retries or mixed-version rollouts.
---

# Verify a plan

Start with the decision the check could change. For example, can a queue worker
safely retry a delivery after losing the acknowledgement?

1. State the property in checkable terms. For the retry example, each message
   ID may produce at most one durable effect. Identify the assumptions that
   connect this property to the real system.
2. Model only the state and actions needed to challenge it. Start with one
   message and allow delivery, commit, loss of the acknowledgement, and
   redelivery. Include the failure or interleaving the design must survive.
   Check that the model can actually reach that scenario.
3. During planning, use an available model checker, solver, or exhaustive
   enumeration appropriate to the model. Record the model or a reproducible
   reference, the property, the bounds, and the observed outcome. If execution
   is unavailable or the search is incomplete, state what remains unchecked.
4. Trace each counterexample back to the proposed system. Revise the design
   for a feasible trace, or correct a mistaken assumption in the model, then
   repeat the check. For example,
   a commit followed by redelivery can apply the effect twice. Model the
   proposed fix, such as committing the effect and its deduplication record
   atomically, and check the same property again.

Summarize the finding where it justifies the decision in the plan. A completed
bounded check with no counterexample establishes the property within the
stated model and bounds.
Carry assumptions that need implementation or operational evidence into the
relevant steps, such as testing recovery after the database commits.
