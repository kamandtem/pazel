# Quiet momentum: design system
## Reference analysis
The 10 screenshots use violet identity, orange actions, rounded surfaces, generous
whitespace, segmented tabs and five-item navigation. Calendar uses a day strip;
leaderboard uses a dark podium and gold; tools use distinct pastel illustrations.
Room mixes cover/avatar/presence. Home places promotion above useful study metrics.
Pazel keeps the friendly visual language but prioritizes the next study action,
removes advertising clutter and does not copy photos, branded themes or artwork.

## Tokens declared before feature implementation
Restrained violet accent, apricot attention, mint completion, tinted paper.
Primary reference OKLCH(55% .20 290), Flutter sRGB #7152D9.
Paper #F8F7FC; ink #292638; muted #696477; line #E7E2F0.
Apricot #FF8857; mint #23846B. Dark paper #191622; surface #252130.
Font: bundled Vazirmatn, modern continuation of Vazir. Exact legacy Vazir was not
available; this explicitly documented substitution guarantees offline Persian text.
Type: 12 metadata / 14 secondary / 16 body / 20 title / 28 heading / 48 timer.
Spacing 4/8/12/16/24/32/48; radius 12 input /18 button /24 card /32 feature.
Light shadows subtle; dark depth via surfaces. No color-only state encoding.

Buttons 48dp minimum; one primary next action. Inputs have labels and inline errors.
Cards group distinct data; never nested. Destructive discard uses confirmation.
Editors are full routes, not dismissible bottom sheets. Outline icons throughout.
Five destinations on mobile, rail above 840dp. All forms scroll and respect scale.
Charts have text alternatives. Progress is computed, bounded 0..1 and labeled.
Avatars use initials, not borrowed photos. Badges derive from saved sessions.
Branded skeleton, error/retry, disabled busy controls, actionable empty states.
No unnecessary motion, and disableAnimations respected for transitions.
TalkBack, contrast and 200% scaling still require physical device verification.
