# Govnr Domain Specification

## Purpose

This document describes the Govnr domain model as a first-pass specification for implementation. It is intentionally written beside the domain code because the domain model is the source of truth for Govnr's civic language, rules, and lifecycle.

Govnr is civic infrastructure for direct democracy at any scale. The domain should support small informal groups, formal organisations, enterprises, public institutions, cities, countries, and eventually very large democratic spaces.

The default democratic principle is:

```text
one eligible member, one equal vote
```

Other decision rules may be supported later, but equal political power should be the baseline model unless a group explicitly configures otherwise.

## Domain Boundaries

The domain layer owns civic meaning and rules. It should not know about HTTP, databases, queues, AI SDKs, auth providers, or deployment infrastructure.

The domain layer should define:

- Entities and aggregate roots.
- Value objects.
- Domain services and policies.
- Domain events.
- Lifecycle invariants.
- Vocabulary used by the application, API, web app, verification tools, and documentation.

The domain layer should not define:

- Database tables or ORM models.
- API request or response DTOs.
- Worker jobs.
- Email templates.
- AI prompts.
- Ledger storage mechanisms.
- Authentication provider details.

## Core Lifecycle

The first complete civic lifecycle is:

```text
Organisation -> Space -> Membership -> Petition -> Motion -> Vote -> Result -> Decision
```

In more detail:

1. A person has an identity in the system.
2. A civic body creates an organisation.
3. The organisation contains one or more spaces where democracy happens.
4. Members join or are admitted into a space.
5. Eligible members create petitions or proposals.
6. Petitions gather support.
7. Successful petitions become motions.
8. Motions enter a voting period.
9. Eligible members cast votes.
10. Votes are finalised according to configured rules.
11. Results are recorded and made verifiable.
12. Passed motions become decisions, statutes, policies, or other official records.

## Bounded Contexts

### Identity

Identity represents people and their relationship to the platform. It should distinguish a person's platform account from their membership in a specific civic space.

Identity is not the same as eligibility. A person can be known to Govnr but not eligible to participate in a specific vote.

### Organisation and Spaces

Organisations represent real-world or virtual bodies using Govnr. Spaces are the democratic arenas inside them.

Examples:

- A book club as an organisation with one main space.
- A sports club with spaces for members, committee, and teams.
- A company with spaces for employees, departments, and shareholder groups.
- A city with spaces for residents, committees, districts, and consultations.

### Membership and Eligibility

Membership describes who belongs to a space. Eligibility describes what a member may do in a specific context.

Eligibility may depend on:

- Active membership.
- Verification status.
- Role.
- Suspension or moderation status.
- Residency, employment, shareholder status, or another external condition.
- Registration before a cutoff date.
- Conflict-of-interest rules.

### Proposal Intake

Proposal intake covers petitions, draft ideas, and other early-stage civic initiatives. This is where members can raise issues without immediately creating a formal vote.

### Motion and Voting

Motions are formal decision items. They have rules, timelines, eligibility constraints, ballot options, and result calculation.

### Deliberation

Deliberation covers comments, arguments, annotations, amendments, AI summaries, and discussion moderation. It supports informed participation without becoming the official decision itself.

### Records and Decisions

Passed motions become durable civic records. Depending on the organisation, those records may be called decisions, statutes, policies, resolutions, mandates, or rules.

### Audit and Verification

Auditability covers domain events, civic action logs, result records, and ledger-relevant events. The domain should define what must be recorded, while infrastructure decides how to store, hash, anchor, and export it.

## Aggregate Roots and Entities

### Person

A person represents a human participant in Govnr.

Primary responsibilities:

- Hold stable platform identity.
- Link to authentication identity through the application layer.
- Own memberships in organisations or spaces.
- Act as author, supporter, voter, commenter, moderator, or administrator.

Important fields:

- `id`
- `displayName`
- `emailAddress`
- `profile`
- `createdAt`
- `status`

Important invariants:

- A person must have a stable unique identifier.
- A person may have many memberships.
- Authentication details should not be domain concerns beyond identity linkage.

Possible statuses:

- `active`
- `disabled`
- `deleted`

### Organisation

An organisation is a body using Govnr.

Primary responsibilities:

- Own spaces.
- Define organisation-level governance defaults.
- Hold organisation-level roles and policies.
- Represent a real or virtual civic body.

Examples:

- Club.
- Company.
- Trade union.
- Local council.
- Political party.
- Community group.
- Nation-scale civic body.

Important fields:

- `id`
- `name`
- `slug`
- `description`
- `type`
- `status`
- `createdAt`

Important invariants:

- Organisation names should be clear and human-readable.
- Slugs must be unique within the platform.
- Organisations may define defaults, but spaces may override allowed settings.

Possible statuses:

- `draft`
- `active`
- `suspended`
- `archived`

### Space

A space is a democratic arena within an organisation.

Primary responsibilities:

- Own memberships for that space.
- Own petitions, motions, deliberation, votes, and decisions.
- Define local governance settings.

Examples:

- Main members forum.
- Board space.
- Residents assembly.
- Department-level decision space.
- Temporary consultation space.

Important fields:

- `id`
- `organisationId`
- `name`
- `slug`
- `description`
- `visibility`
- `governanceSettings`
- `status`

Important invariants:

- A space belongs to exactly one organisation.
- A space has a defined membership model.
- Democratic activity happens inside a space.

Visibility options:

- `public`
- `listed`
- `private`
- `secret`

### Membership

Membership links a person to a space or organisation.

Primary responsibilities:

- Determine participation rights.
- Track admission, verification, suspension, and departure.
- Carry roles within a civic context.

Important fields:

- `id`
- `personId`
- `organisationId`
- `spaceId`
- `status`
- `roles`
- `verifiedAt`
- `joinedAt`
- `leftAt`

Important invariants:

- A vote requires active eligible membership.
- A person should not have duplicate active memberships in the same space.
- Suspended members may be restricted from creating, supporting, voting, or commenting.

Possible statuses:

- `invited`
- `pending`
- `active`
- `suspended`
- `left`
- `removed`

### Role

A role grants capabilities in a specific organisation or space.

Primary responsibilities:

- Represent civic and operational authority.
- Support least-privilege permissions.
- Keep group administration separate from platform administration.

Common roles:

- `member`
- `moderator`
- `spaceAdmin`
- `organisationAdmin`
- `platformOperator`

Important invariants:

- Roles are scoped.
- Platform roles do not imply voting rights.
- Voting rights come from eligibility, not administrative power.

### GovernanceSettings

Governance settings define the configurable democratic rules for a space.

Primary responsibilities:

- Define petition thresholds.
- Define motion timelines.
- Define voting method and result rules.
- Define quorum and majority requirements.
- Define whether votes may be changed during an active voting period.

Important fields:

- `petitionSupportThreshold`
- `petitionDuration`
- `motionNoticePeriod`
- `motionVotingDuration`
- `quorumRule`
- `majorityRule`
- `voteChangePolicy`
- `abstentionPolicy`

Important invariants:

- Settings must be explicit before votes are opened.
- Changes to settings must not retroactively alter active or completed votes unless a formal correction process exists.
- The settings used for a vote must be snapshotted with the motion.

### Petition

A petition is an early-stage proposal seeking enough support to become a formal motion.

Primary responsibilities:

- Capture a proposed issue or action.
- Gather support from eligible members.
- Promote to a motion when thresholds are met.
- Expire if thresholds are not met in time.

Important fields:

- `id`
- `spaceId`
- `title`
- `summary`
- `body`
- `authorId`
- `status`
- `supportThreshold`
- `supportCount`
- `openedAt`
- `expiresAt`
- `promotedMotionId`

Possible statuses:

- `draft`
- `open`
- `successful`
- `expired`
- `withdrawn`
- `rejected`
- `promoted`

Important invariants:

- Only eligible members may create petitions unless the space allows external suggestions.
- Only eligible members may support petitions.
- A member may support a petition at most once.
- A successful petition should create at most one motion unless explicitly reopened.

### PetitionSupport

Petition support records that an eligible member supports a petition.

Primary responsibilities:

- Count support toward petition threshold.
- Provide audit trail for promotion.

Important fields:

- `id`
- `petitionId`
- `membershipId`
- `supportedAt`

Important invariants:

- A membership may support a petition only once.
- Support should only count if the supporter was eligible at the time support was given.

### Motion

A motion is a formal decision item.

Primary responsibilities:

- Define the question being decided.
- Define ballot options.
- Define voting rules and schedule.
- Receive votes.
- Produce a result.
- Become a decision if passed.

Important fields:

- `id`
- `spaceId`
- `sourcePetitionId`
- `title`
- `summary`
- `body`
- `authorId`
- `status`
- `ballot`
- `rulesSnapshot`
- `noticeStartsAt`
- `votingStartsAt`
- `votingEndsAt`
- `resultId`

Possible statuses:

- `draft`
- `scheduled`
- `openForDeliberation`
- `votingOpen`
- `votingClosed`
- `passed`
- `failed`
- `cancelled`
- `voided`

Important invariants:

- A motion must have explicit rules before voting opens.
- A motion cannot receive votes before voting opens.
- A motion cannot receive votes after voting closes.
- A motion result must be calculated from the rules snapshot, not mutable current settings.
- A finalised motion should not be edited except through a formal correction or amendment process.

### Ballot

A ballot defines the available choices for a motion.

Primary responsibilities:

- Define vote choices.
- Define whether abstention is supported.
- Define whether the question is binary, multiple choice, ranked, or another supported method.

Initial ballot types:

- `yesNo`
- `yesNoAbstain`

Future ballot types:

- `multipleChoice`
- `rankedChoice`
- `score`
- `approval`

Important invariants:

- A ballot cannot change after voting opens.
- Votes must match the ballot type.

### Vote

A vote records a member's choice on a motion.

Primary responsibilities:

- Capture the selected ballot option.
- Link the vote to eligible membership.
- Feed result calculation.
- Produce ledger-relevant events.

Important fields:

- `id`
- `motionId`
- `membershipId`
- `choice`
- `castAt`
- `supersedesVoteId`
- `status`

Possible statuses:

- `cast`
- `superseded`
- `rejected`
- `voided`

Important invariants:

- A membership may have only one effective vote per motion.
- Vote changes are allowed only if the motion rules permit them.
- Vote eligibility must be evaluated at cast time.
- Vote privacy requirements must be explicit before implementation.

### EligibilityRecord

An eligibility record captures why a person was or was not eligible to participate in a specific civic action.

Primary responsibilities:

- Support auditability.
- Explain vote acceptance or rejection.
- Snapshot relevant eligibility facts at action time.

Important fields:

- `id`
- `membershipId`
- `actionType`
- `targetId`
- `eligible`
- `reason`
- `evaluatedAt`

Important invariants:

- Eligibility should be explainable.
- Eligibility records should not expose unnecessary private data.

### Result

A result records the outcome of a motion.

Primary responsibilities:

- Count valid votes.
- Record turnout.
- Apply quorum and majority rules.
- Declare passed, failed, tied, or voided outcome.
- Reference verification material.

Important fields:

- `id`
- `motionId`
- `status`
- `eligibleVoterCount`
- `validVoteCount`
- `invalidVoteCount`
- `abstentionCount`
- `choiceTotals`
- `quorumSatisfied`
- `majoritySatisfied`
- `outcome`
- `calculatedAt`
- `verificationBundleId`

Possible outcomes:

- `passed`
- `failed`
- `tied`
- `voided`
- `requiresReview`

Important invariants:

- Results must be reproducible from accepted votes and the rules snapshot.
- Results must be immutable after finalisation except through a formal correction process.
- Result calculation should produce audit events.

### Decision

A decision is the durable record created by a passed motion.

Primary responsibilities:

- Preserve the official decision.
- Link back to the motion and result.
- Provide an authoritative civic record.

Depending on context, a decision may be labelled:

- Statute.
- Policy.
- Resolution.
- Mandate.
- Rule.
- Record.

Important fields:

- `id`
- `spaceId`
- `motionId`
- `title`
- `body`
- `status`
- `adoptedAt`
- `effectiveFrom`
- `supersededByDecisionId`

Possible statuses:

- `active`
- `superseded`
- `repealed`
- `archived`

Important invariants:

- A decision must originate from an accepted governance process.
- A decision should preserve the text approved by the motion.
- Later amendments should create traceable change history.

### Draft

A draft is a working text for petitions, motions, amendments, or decisions.

Primary responsibilities:

- Support collaborative drafting.
- Preserve version history.
- Allow comparison between versions.
- Support AI-assisted drafting without making AI the author of record.

Important fields:

- `id`
- `spaceId`
- `subjectType`
- `subjectId`
- `title`
- `content`
- `currentVersionId`
- `createdBy`
- `updatedBy`

Important invariants:

- Draft versions must be preserved.
- AI contributions must be labelled if incorporated.
- Official motion or decision text should reference a stable draft version.

### DraftVersion

A draft version is an immutable snapshot of draft content.

Important fields:

- `id`
- `draftId`
- `versionNumber`
- `title`
- `content`
- `createdBy`
- `createdAt`
- `changeNote`

Important invariants:

- Version numbers increase monotonically per draft.
- Existing versions should not be edited.

### Amendment

An amendment proposes a change to a motion or decision text.

Primary responsibilities:

- Capture proposed text change.
- Explain rationale.
- Enter deliberation or voting as required by local rules.

Important fields:

- `id`
- `spaceId`
- `targetType`
- `targetId`
- `proposedBy`
- `status`
- `changeDescription`
- `draftVersionId`

Possible statuses:

- `draft`
- `proposed`
- `accepted`
- `rejected`
- `withdrawn`
- `superseded`

### DeliberationThread

A deliberation thread groups discussion around a civic subject.

Primary responsibilities:

- Hold comments and arguments.
- Support moderation.
- Support summaries.

Subjects may include:

- Petition.
- Motion.
- Draft.
- Amendment.
- Decision.

Important fields:

- `id`
- `spaceId`
- `subjectType`
- `subjectId`
- `status`

### Comment

A comment is a contribution to deliberation.

Primary responsibilities:

- Capture member discussion.
- Support replies.
- Support moderation actions.

Important fields:

- `id`
- `threadId`
- `authorId`
- `parentCommentId`
- `body`
- `status`
- `createdAt`
- `editedAt`

Possible statuses:

- `visible`
- `edited`
- `hidden`
- `removed`
- `flagged`

Important invariants:

- Moderation should preserve auditability.
- Deleted or hidden comments may need tombstones for discussion integrity.

### Argument

An argument is a structured deliberation item for or against a petition, motion, amendment, or decision.

Primary responsibilities:

- Help participants understand trade-offs.
- Separate structured reasoning from general comments.
- Support neutral summaries and pro/con views.

Important fields:

- `id`
- `subjectType`
- `subjectId`
- `stance`
- `title`
- `body`
- `authorId`
- `sources`

Possible stances:

- `for`
- `against`
- `neutral`
- `question`

### Source

A source supports claims in deliberation, AI research, summaries, or arguments.

Important fields:

- `id`
- `url`
- `title`
- `publisher`
- `retrievedAt`
- `summary`

Important invariants:

- Source metadata should distinguish cited material from AI interpretation.
- Sources may become unavailable, so important metadata should be preserved.

### ModerationCase

A moderation case tracks potential violations of rules, conduct standards, or safety policies.

Primary responsibilities:

- Manage reports.
- Track moderation decisions.
- Preserve fairness and accountability.

Important fields:

- `id`
- `spaceId`
- `reportedSubjectType`
- `reportedSubjectId`
- `reportedBy`
- `assignedTo`
- `status`
- `reason`
- `decision`
- `createdAt`
- `resolvedAt`

Possible statuses:

- `open`
- `reviewing`
- `resolved`
- `dismissed`
- `escalated`

### ActivityEvent

An activity event records important visible actions in the civic space.

Primary responsibilities:

- Power activity feeds.
- Support notifications.
- Provide user-facing history.

Examples:

- Petition created.
- Petition supported.
- Motion opened.
- Vote opened.
- Vote closed.
- Result finalised.
- Decision adopted.

Activity events are not necessarily ledger events. Ledger events are the subset requiring cryptographic integrity and public verification.

### AuditEvent

An audit event records important system and civic actions for accountability.

Primary responsibilities:

- Provide traceability.
- Support compliance and review.
- Feed ledger-relevant event generation where appropriate.

Important invariants:

- Audit events should be append-only.
- Audit events should contain enough context to explain what happened.
- Sensitive personal data should be minimised.

### LedgerEvent

A ledger event is a canonical event intended for tamper-evident verification.

Primary responsibilities:

- Represent vote and result events in canonical form.
- Support hashing, chaining, Merkle proofs, and verification exports.
- Preserve result integrity without exposing unnecessary private data.

Candidate ledger event types:

- `motion.voting_opened`
- `vote.accepted`
- `vote.superseded`
- `vote.rejected`
- `motion.voting_closed`
- `result.calculated`
- `result.finalised`
- `decision.adopted`

Important invariants:

- Ledger event schemas must be versioned.
- Canonical serialisation must be deterministic.
- Ledger events should be generated from domain/application decisions, not directly from API input.

### VerificationBundle

A verification bundle contains enough public or semi-public material to verify a completed result.

Primary responsibilities:

- Verify inclusion of accepted votes or commitments.
- Verify result calculation.
- Verify ledger roots or hash chain.
- Support independent verification tools.

Important fields:

- `id`
- `motionId`
- `resultId`
- `eventSchemaVersion`
- `ledgerRoot`
- `merkleRoot`
- `generatedAt`
- `files`

Important invariants:

- Bundles must not leak private voting data beyond the chosen privacy model.
- Bundles should remain verifiable without trusting the Govnr UI.

### AISummary

An AI summary is generated assistance, not an official civic decision.

Primary responsibilities:

- Summarise long discussions.
- Compare draft versions.
- Explain arguments and trade-offs.
- Help participants understand a motion.

Important fields:

- `id`
- `subjectType`
- `subjectId`
- `model`
- `promptVersion`
- `sourceIds`
- `body`
- `createdAt`
- `status`

Important invariants:

- AI-generated content must be labelled.
- AI summaries must not silently modify official records.
- Source material and prompt version should be auditable where appropriate.

### AIResearchNote

An AI research note captures assisted research with citations.

Primary responsibilities:

- Help members find supporting information.
- Preserve citations and retrieval context.
- Keep research separate from official motion text.

Important invariants:

- Research output should cite sources.
- Unverified claims should be marked as such.
- AI research should not be treated as authoritative by default.

## Value Objects

### EntityId

A stable unique identifier for an entity.

### Slug

A URL-safe identifier for human-readable routing.

Important invariants:

- Unique within relevant scope.
- Stable unless explicitly changed.

### TimeWindow

A start and end time for civic activity.

Used for:

- Petition support periods.
- Motion notice periods.
- Voting periods.

Important invariants:

- End must be after start.
- Time windows should use explicit timezone handling.

### Percentage

A numeric percentage used for thresholds.

Important invariants:

- Must be within allowed range.
- Precision rules should be explicit.

### QuorumRule

Defines minimum participation required for a valid result.

Examples:

- No quorum.
- Percentage of eligible members.
- Fixed minimum vote count.

### MajorityRule

Defines what it means for a motion to pass.

Examples:

- Simple majority of valid non-abstaining votes.
- Absolute majority of eligible members.
- Supermajority.
- Unanimity.

### VoteChoice

Represents a valid ballot choice.

Initial choices:

- `yes`
- `no`
- `abstain`

### CivicText

Structured text for petitions, motions, drafts, decisions, and explanations.

Important concerns:

- Plain text versus rich text.
- Sanitisation.
- Versioning.
- Future localisation.

### SourceReference

Reference to a cited source.

Fields may include:

- URL.
- Title.
- Publisher.
- Retrieval date.
- Hash or archived copy reference.

## Policies and Domain Services

### EligibilityPolicy

Determines whether a membership may perform an action.

Actions:

- Create petition.
- Support petition.
- Comment.
- Propose amendment.
- Cast vote.
- Moderate content.
- Administer space.

### PetitionPromotionPolicy

Determines whether a petition has enough support to become a motion.

Inputs:

- Support count.
- Eligible member count.
- Threshold.
- Expiry time.
- Petition status.

### MotionSchedulingPolicy

Determines when voting may begin and end.

Inputs:

- Notice period.
- Voting duration.
- Space settings.
- Emergency or expedited rules if later supported.

### VoteAcceptancePolicy

Determines whether a vote may be accepted.

Inputs:

- Motion status.
- Voting window.
- Membership eligibility.
- Ballot validity.
- Vote change policy.

### ResultCalculationPolicy

Calculates a result from accepted votes and the rules snapshot.

Inputs:

- Ballot.
- Accepted votes.
- Eligible member count.
- Quorum rule.
- Majority rule.
- Abstention policy.

### DecisionAdoptionPolicy

Determines what official record is created from a passed motion.

Inputs:

- Motion.
- Result.
- Approved text.
- Effective date.

### ModerationPolicy

Determines what moderation actions are allowed and how they affect visible content.

### AISafetyPolicy

Determines how AI-generated material may be used.

Rules:

- AI may assist drafting, summarising, comparison, and research.
- AI must not finalise votes, determine eligibility, or silently alter records.
- AI output must be labelled when shown to users.

## Domain Events

Domain events describe meaningful facts that have happened.

Initial events:

- `OrganisationCreated`
- `SpaceCreated`
- `MembershipActivated`
- `MembershipSuspended`
- `PetitionCreated`
- `PetitionSupported`
- `PetitionExpired`
- `PetitionPromotedToMotion`
- `MotionCreated`
- `MotionScheduled`
- `MotionOpenedForVoting`
- `VoteCast`
- `VoteSuperseded`
- `VoteRejected`
- `MotionClosedForVoting`
- `ResultCalculated`
- `ResultFinalised`
- `DecisionAdopted`
- `DraftCreated`
- `DraftVersionCreated`
- `AmendmentProposed`
- `CommentPosted`
- `CommentModerated`
- `AISummaryGenerated`
- `VerificationBundleGenerated`

Some domain events may produce activity events, audit events, ledger events, notifications, or worker jobs through the application layer.

## Privacy and Verification Questions

The domain must leave room for different voting privacy models.

Open questions:

- Are votes public, private to members, private to administrators, or secret?
- Should voters be able to prove how they voted?
- Should the system prevent coercion by avoiding receipt-like proofs?
- How should eligibility be proven without exposing private identity data?
- Which events belong in public verification bundles?
- What should be verifiable by non-members?

These questions should be settled before implementing production voting.

## Initial Implementation Priority

The first implementation should focus on the simplest complete democratic path:

1. Organisation.
2. Space.
3. Membership.
4. Governance settings.
5. Petition.
6. Petition support.
7. Motion.
8. Vote.
9. Result.
10. Decision.
11. Ledger event.
12. Verification bundle.

Everything else can be introduced as the product matures.

## Legacy Rails Mapping

The legacy Rails app provides useful domain clues, but not the new implementation model.

Approximate mapping:

- `User` -> `Person`
- `Group` -> `Organisation` or `Space`
- `GroupMembership` -> `Membership`
- `GroupSetting` -> `GovernanceSettings`
- `Petition` -> `Petition`
- `Motion` -> `Motion`
- `Vote` from `acts_as_votable` -> `Vote`
- `Draft` -> `Draft`
- `DraftVersion` -> `DraftVersion`
- `Statute` -> `Decision`
- `Comment` -> `Comment`
- `PublicActivity` records -> `ActivityEvent`

The new model should not preserve legacy names where they are unclear. Prefer civic language that will still make sense to non-technical users and serious institutions.

