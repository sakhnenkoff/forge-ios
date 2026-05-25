# Generated Residue Negative Fixture

This fixture is intentionally invalid. It exists only to prove strict proof-app absence gates reject copied template residue.

Forbidden residue intentionally present here:
- App Store and TestFlight signing instructions for public launch.
- DayRateLab setup notes copied from an earlier proof app.
- Set up an account, authentication route, and payment setup before local proof.
- Configure subscriptions and purchase flows for users.

Why this fixture is excluded from pass matrices: it is a negative gate fixture, not a generated app example. Tests must assert that it fails.

Accepted local-boundary copy exception: real generated proof apps may state narrow negative boundaries such as "no account creation" or "no payment setup" when the sentence clearly forbids the module rather than instructing the worker to add it. Positive setup/configuration/wiring instructions remain blockers.
