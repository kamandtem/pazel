# Database schema v1
Sembast document database: native app-support file and Web IndexedDB.
Schema metadata contains version 1; a newer version fails safely.
Dates are UTC ISO 8601 except `day`, which is local ISO civil yyyy-MM-dd, not Jalali.

| Store | Key | Fields |
|---|---|---|
| meta | schema/seeded/onboarding/auth | version / flags |
| users | local | name,surname,phone,gender,grade,field,examYear,goal,city,school,sleep,wake,dailyGoalMinutes |
| settings | local | dark,persianDigits,notifications |
| subjects | id | title,color ARGB |
| study_plans | id | subjectId,topic,day,startMinute,minutes,tests,priority,activity,note,done,position |
| study_sessions | timer ID | subjectId,topic,startedAt,endedAt,seconds,tests,quality,focus,mood,note,planId |
| active_timer | current | id,subjectId,topic,startedAt,anchor,elapsedSeconds,mode,phase,focusMinutes,breakMinutes,cycles,planId |
| flashcards | id | subjectId,front,back,box,intervalDays,dueAt,reviews |
| flashcard_reviews | id | cardId,rating,reviewedAt,previousBox,nextBox,nextDueAt |
| notes | civil day | text |
| notifications | id | title,body,createdAt,read |
| outbox | event id | entity,recordId,operation,payload,createdAt,attempts |
| analytics | event id | name,at (no personal payload) |

All writes and outbox envelopes share a transaction. Never clear outbox until a
future server acknowledgement. No online synchronization is claimed in v0.1.
Sessions are append-only. Wallet and multiplayer scores must be server-authoritative.
Single active timer. Negative duration/tests and unknown subjects are rejected.
90-day session snapshots; older data remains in database. Plans/cards still loaded
as a local pilot snapshot; production pagination and compaction remain TODO.

Planned stores, NOT fake tables pretending to work: lessons, topics,
pomodoro_sessions, exams, exam_questions, exam_results, calendar_events, moods,
podcasts, podcast_history, leagues, league_members, league_challenges, achievements,
transactions, wallet, cart, products, orders, advisor_requests, ai_chats,
ai_messages, challenges, social_connections, health_entries, consent_records.
Add typed models and migrations with each feature. Mood currently belongs to session.
