# Google Word List (full transcription)


Source: https://developers.google.com/style/word-list
License: CC BY 4.0 (Google Developer Documentation Style Guide); transcribed verbatim with attribution
Last refreshed: 2026-04-28

## Categories
- `clarity`: words that add no information
- `hedge-words`: softeners without epistemic honesty
- `action-verbs`: verbs for UI actions
- `mouse-keyboard`: input device terminology
- `login`: authentication terms
- `web-internet`: web/internet terms
- `error-messages`: error message tone
- `direction`: directional words
- `numbers-dates`: numerals, units, dates
- `inclusive`: bias-free / inclusive
- `ableist`: ableist metaphors
- `gendered`: gendered language
- `culturally-narrow`: cultural assumptions
- `technical-jargon`: overly technical terms

---

## Numbers and symbols

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| + (in text) | (keep, see Notes) | no | Acceptable with numbers in text (e.g., "300+ attributes") except in formal contexts. |
| & (ampersand) | and | no | Don't use instead of "and" in headings, text, or navigation; OK in code or when referencing UI elements that use &. |

---

## Clarity & hedge-words

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| actionable | useful | no | Avoid unless it is the clearest option; replace with "useful" or a similar concrete adjective. |
| actually | (drop) | no | Filler word; removing it rarely changes meaning. |
| and so on | (drop) | no | Avoid; use "including" or list items explicitly instead of trailing off. |
| as of this writing | (drop) | yes | Avoid; the phrase is implied and can prematurely disclose strategy. |
| currently | (drop) | no | Avoid in timeless documentation; the word is implied and becomes outdated. |
| does not yet | (drop) | no | Avoid in timeless documentation; phrase discloses product strategy prematurely. |
| e.g. | for example | yes | Don't use the Latin abbreviation; replace with "for example" or "such as". |
| easy, easily | (drop) | no | What is easy varies by reader; eliminate when possible without changing meaning. |
| eventually | (drop) | no | Avoid in timeless documentation; can become outdated. |
| etc. | (drop) | no | Avoid; use "including" or list specific items instead. |
| for instance | for example | yes | Don't use; risks confusion with the noun "instance"; use "for example" instead. |
| future, in the future | (drop) | no | Avoid in timeless documentation; can become outdated. |
| i.e. | that is | yes | Don't use the Latin abbreviation; replace with "that is". |
| in order to | to | yes | Avoid; use "to" instead, except when needed for grammatical clarity. |
| just | (drop) | no | Avoid as a filler word; use more specific terms when needed. |
| latest | (drop) | no | Avoid in timeless documentation; provide a version number or date if used. |
| let's | (drop) | no | Avoid if possible in documentation prose. |
| leverage | use | no | Avoid if meaning "use"; choose a precise term like "build on" or "use" instead. |
| new, newer | (drop) | no | Avoid in timeless documentation; provide version numbers or dates instead. |
| now | (drop) | no | Avoid when describing product features; use only for past/present comparisons. |
| old, older | earlier | no | Don't use for previous product versions; use "earlier" and provide version numbers. |
| once | after | no | Use "after" instead if that is the meaning, to avoid temporal ambiguity. |
| please | (drop) | no | Avoid in normal procedures; use only when requesting permission or expressing concern. |
| presently, at present | (drop) | no | Avoid; these are implied and can prematurely disclose product strategy. |
| really | (drop) | no | Filler intensifier; removing it rarely changes meaning. |
| simple, simply | (drop) | no | Avoid overuse; what is simple for experts may not be for beginners. |
| someday | (drop) | no | Avoid in timeless documentation; implies future change. |
| soon | (drop) | no | Avoid; can become outdated; use specific timeframes instead. |
| today | (drop) | no | Avoid in timeless documentation; use specific dates instead. |
| typical | (drop) | no | Avoid; it is vague; use specific examples instead. |
| under development | (drop) | no | Avoid in timeless docs; be specific about status. |
| user-friendly | easy to use | no | Avoid; use more specific terms like "easy to use" or "intuitive". |
| very | (drop) | no | Avoid; often a filler word; be more specific instead. |
| we | (drop) | no | Avoid first-person plural in documentation; use second person instead. |

---

## Action verbs

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| check (checkbox) | select | no | Don't use for marking a checkbox; replace with "select". |
| choose | select | no | Acceptable generically; use "select" specifically for UI elements. |
| click | (keep, see Notes) | no | Use for most targets on desktop; don't use "click on"; hyphenate "right-click," "left-click," "double-click". |
| click here | (drop) | no | Don't use; link text should describe the destination, not the action. |
| deselect | clear | yes | Don't use for clearing checkboxes; replace with "clear". |
| disable | turn off | no | Don't use for broken items; use "inactive," "unavailable," "deactivate," or "turn off". |
| double-tap | (keep, see Notes) | no | Hyphenate; lowercase except at sentence/heading/list start; standard touch term. |
| drag | (keep, see Notes) | no | Use "drag" alone; not "click and drag" or "drag and drop" as a verb; hyphenate as adjective "drag-and-drop". |
| enable | turn on | no | For user actions, prefer "turn on" especially in Workspace docs; "enable" is OK for activating features consistently. |
| enter | (keep, see Notes) | no | Use when describing text input; specify if the Enter key should not be pressed. |
| execute | run | yes | Use the simpler "run" when meaning is equivalent. |
| fill in / fill out | (keep, see Notes) | no | "Fill in" for individual fields; "fill out" for complete forms. |
| hit | click / press / type | no | Don't use for "click," "press," or "type". |
| long press | touch and hold | yes | Don't use in Android; use "touch & hold". |
| run | (keep, see Notes) | no | Preferred over "execute" when meaning is equivalent. |
| select | (keep, see Notes) | no | Preferred over "check" for checkbox actions and over "choose" for UI elements. |
| tap | (keep, see Notes) | no | In Android documentation, use instead of "click" for touchscreen interaction. |
| turn off | (keep, see Notes) | no | Use instead of "disable" for user actions. |
| turn on | (keep, see Notes) | no | Use instead of "enable" for user actions, especially in Workspace docs. |
| type | (keep, see Notes) | no | Use for entering text with a keyboard; distinguish from "enter" when Enter key shouldn't be pressed. |
| uncheck | clear | yes | Don't use; use "clear" instead for checkboxes. |

---

## Mouse and keyboard

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| Control+S / Command+S | (keep, see Notes) | no | Use "Control+CHARACTER" format; don't use "Ctl-S" or "Cmd-S"; mention both for cross-platform instructions. |
| hold the pointer over | (keep, see Notes) | no | Use only when duration matters or no-click waiting is required; not a synonym for "hover". |
| hover | hold the pointer over | yes | Don't use; instead use "hold the pointer over". |
| point to | (keep, see Notes) | no | Refers to mouse pointer positioning without implying wait time; distinct from "hold the pointer over". |
| right-click | (keep, see Notes) | no | Hyphenate; standard UI interaction term. |
| tab (key) | Tab key | no | Don't use "tab" to refer to the Tab key; write "Tab key". |
| touch & hold | (keep, see Notes) | no | In Android documentation, preferred over "long press". |

---

## Login and authentication

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| authN, authZ | authentication / authorization | no | Don't use these abbreviations; spell out in full. |
| log in / login | sign in / sign-in | no | Prefer "sign in" (verb) and "sign-in" (noun/adjective); use consistently. |
| log out | sign out | no | Prefer "sign out" over "log out"; use consistently throughout. |
| sign in / sign out | (keep, see Notes) | no | Preferred terms for authentication actions; use consistently. |
| two-factor authentication | (keep, see Notes) | no | Hyphenate; use instead of "2FA" without context. |
| two-step verification | (keep, see Notes) | no | See "2-Step Verification" (Google's product uses initial caps). |
| username | (keep, see Notes) | no | One word; preferred over "account name". |
| account name | username | yes | Don't use; replace with "username". |

---

## Web and internet

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| address bar | (keep, see Notes) | no | Use for the URL bar or combined URL/search box; don't use "omnibox". |
| ecommerce | (keep, see Notes) | no | Not "e-commerce"; use the closed compound form. |
| email | (keep, see Notes) | no | Not "e-mail"; use as a noun only and pair with a verb like "send". |
| internet | (keep, see Notes) | no | Lowercase except at sentence beginning. |
| omnibox | address bar | yes | Don't use; use "address bar" instead. |
| web | (keep, see Notes) | no | Lowercase; avoid capitalizing to "Web". |
| web address | (keep, see Notes) | no | Use instead of "URL" when appropriate for the audience. |
| web app | (keep, see Notes) | no | Two words; acceptable term. |
| web page | (keep, see Notes) | no | Two words; not "webpage". |
| web service | (keep, see Notes) | no | Two words; not "webservice". |
| webhook | (keep, see Notes) | no | One word; not "web hook" or "web-hook". |
| website | (keep, see Notes) | no | One word; not "web site". |

---

## Error messages

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| abort | stop / exit / cancel / end | no | Avoid generally; use "stop," "exit," "cancel," or "end" instead. |
| fail over / failover | (keep, see Notes) | no | Verb form: "fail over"; noun/adjective: "failover". |
| hang, hung | stop responding | no | Don't use for unresponsive systems; use "stop responding" or "not responding". |
| kill | stop / exit / cancel / end | no | Avoid; use "stop," "exit," "cancel," or "end". |
| sorry | (drop) | no | Don't overuse; reserve for genuine errors or problems. |
| stop | (keep, see Notes) | no | Preferred over "abort" or "kill" for process termination. |
| unsuccessful | failed | no | Avoid; use "failed" or describe the specific error. |
| wrong | incorrect | no | Avoid; use "incorrect" or describe the specific error. |

---

## Direction

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| above | (drop) | no | Don't use for version ranges, document positions, or UI directions; OK in non-directional hierarchy contexts. |
| below | (drop) | no | Don't use for version ranges, document positions, or UI directions; OK in phrases like "below average". |
| earlier | (keep, see Notes) | no | Use for version ranges instead of "lower"; for document positions, use instead of directional language. |
| higher | later | no | Don't use for version ranges; use "later" (exception: Android docs use "higher"). |
| later | (keep, see Notes) | no | Use for version number ranges instead of "higher". |
| left-nav, right-nav | navigation menu | no | Don't use directional language; use "navigation menu". |
| lower | earlier | no | Don't use for version ranges; use "earlier". |
| upper | later | no | Don't use for version numbers; use "later". |

---

## Numbers and dates

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| 2-Step Verification | (keep, see Notes) | no | Use initial caps for Google's product; lowercase for generic two-step verification. |
| A/B testing | (keep, see Notes) | no | Capitalize with slash notation. |
| AM, PM | (keep, see Notes) | no | Use all caps, no periods, with a space before (e.g., "9:00 AM"). |
| GBps | (keep, see Notes) | no | Gigabytes per second; don't use "GB/s". |
| Gbps | (keep, see Notes) | no | Gigabits per second; don't use "Gb/s". |
| KBps | (keep, see Notes) | no | Kilobytes per second; don't use "KB/s". |
| Kbps | (keep, see Notes) | no | Kilobits per second; don't use "Kb/s". |
| MBps | (keep, see Notes) | no | Megabytes per second; don't use "MB/s". |
| Mbps | (keep, see Notes) | no | Megabits per second; don't use "Mb/s". |
| per | (keep, see Notes) | no | Use instead of slash for rates; "requests per day" not "requests/day". |
| zero | (keep, see Notes) | no | Use instead of "0" in prose contexts. |
| zero-based | (keep, see Notes) | no | Hyphenate as a compound modifier. |

---

## Inclusive language

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| a and an | (keep, see Notes) | no | Use "a" before consonant sounds; follow article guidelines for edge cases. |
| singular they | (keep, see Notes) | no | Preferred gender-neutral pronoun form; acceptable and preferred for generic references. |
| they, their, them | (keep, see Notes) | no | Preferred singular pronouns for gender-neutral references. |

---

## Ableist language

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| abnormal | (drop) | no | Don't use for people; acceptable for computer system conditions. |
| blind (figurative) | ignore / unaware / disregard | no | Avoid "blind to" or "blind writes"; use "ignore," "unaware," or "disregard". |
| cripple | slowed down | no | Don't use; use "slowed down" or descriptive language. |
| crazy, bonkers, mad, lunatic, insane, loony | complicated / complex / unexpected | no | Don't use; replace with "complicated," "complex," or "unexpected". |
| deficient | (drop) | no | Don't use for people; OK for computer systems. |
| deformed | (drop) | no | Don't use for people; OK for systems or objects. |
| dumb down | simplify | no | Don't use; replace with "simplify" or "remove technical jargon". |
| gimp, gimpy | (drop) | no | Don't use for code deficiencies; acceptable only in company or tool names. |
| grayed-out / greyed-out | unavailable | no | Don't use; replace with "unavailable". |
| hang, hung (system) | stop responding | no | Don't use for unresponsive systems; use "stop responding". |
| healthy | (drop) | no | Don't use; see "health check" guidance for context-appropriate alternatives. |
| lame | (drop) | no | Don't use; use precise, non-figurative language instead. |
| ragged right | (keep, see Notes) | no | Acceptable in typography/formatting contexts; don't use to describe people. |
| sanity check | (drop) | no | Replace with "check," "verify," or "confirm". |

---

## Gendered language

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| female adapter | socket | yes | Don't use; replace with the genderless term "socket". |
| gender-neutral he/him/his | they/them/their | no | Don't use; employ singular "they" instead. |
| guys, you guys | everyone / folks | no | Replace with non-gendered "everyone" or "folks". |
| he, him, his | they / them / their | no | Don't use for general reference; use singular "they" instead. |
| male adapter | plug | yes | Don't use; use the genderless term "plug". |
| man hours | person hours | yes | Avoid gendered term; use "person hours". |
| man-in-the-middle (MITM) | on-path attacker / person-in-the-middle (PITM) | no | Avoid gendered term; use "on-path attacker" or "person-in-the-middle (PITM)". |
| manmade | artificial / manufactured / synthetic | no | Avoid gendered term; use "artificial," "manufactured," or "synthetic". |
| manned | staffed / crewed | no | Avoid gendered term; use "staffed" or "crewed". |
| manpower | staff / workforce | no | Avoid gendered term; use "staff" or "workforce". |
| master | primary / main / parent / controller | no | Use with caution; never with "slave"; replace with specific terms like "primary," "main," "parent," or "controller". |
| preferred pronouns | pronouns | yes | Don't use "preferred"; just say "pronouns". |
| slave | replica / secondary / standby | no | Don't use; replace with "replica," "secondary," or "standby" depending on context. |
| team lead | team leader / team manager | no | Avoid gendered language; use "team leader" or "team manager". |

---

## Culturally narrow language

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| America, American | US / United States | no | Use only for the Americas or American continent; use "US" or "United States" for country references. |
| Black Friday | peak scale event | no | Avoid unless explicitly referring to the US event; use "peak scale event". |
| brown bag, brown-bag | learning session / lunch and learn | no | Don't use; replace with "learning session" or "lunch and learn". |
| build cop, build sheriff | build monitor | no | Don't use; replace with "build monitor". |
| Cyber Monday | peak scale event | no | Avoid unless explicitly referring to the US event; use "peak scale event". |
| dojo | training / workshop | no | Don't use; replace with "training" or "workshop". |
| ghetto | clumsy / workaround / inelegant | no | Don't use; replace with precise descriptors. |
| grandfather clause / grandfathered | legacy / exempt / made an exception | no | Don't use; replace with "legacy," "exempt," or "made an exception". |
| guru | expert / teacher | no | If possible, use "expert" or "teacher" instead. |
| gypsy | Romani / Roma / Traveller | no | Don't use; use "Romani," "Roma," or "Traveller" as appropriate. |
| holiday / the holidays | (drop) | no | Don't use for year-end; refer to specific quarters or months. |
| housekeeping | maintenance / cleanup | no | Don't use; prefer "maintenance" or "cleanup". |
| mom test | beginner user test / novice user test | no | Don't use; use "beginner user test" or "novice user test". |
| monkey, monkey test | (keep, see Notes) | no | Don't use for people; refer to the specific function type for tests. |
| ninja | expert | no | Don't use for people; use "expert" instead; acceptable in company/product names. |
| pets versus cattle | persistent versus dynamic | no | Don't use; prefer "persistent versus dynamic" or "manually configured versus automated". |
| tapas | appetizers / snacks | no | Don't use; use precise terms like "appetizers" or "snacks". |
| US, USA, United States | US / United States | no | Use "US" or "United States" rather than "America". |
| Western | (keep, see Notes) | no | Capitalize; avoid ambiguous geographic references. |

---

## Technical jargon

| Term | Replacement | Mechanical | Notes |
|------|-------------|------------|-------|
| -aware (suffix) | (drop) | no | Avoid as a compound modifier; OK in product names like "Identity-Aware Proxy". |
| access (verb) | see / edit / view | no | Avoid when possible; replace with friendlier terms like "see," "edit," or "view". |
| ad hoc | (keep, see Notes) | no | Acceptable in database/analytics contexts; don't hyphenate or italicize. |
| admin | administrator | no | Write out "administrator" unless it is a UI label; OK in Android documentation. |
| agnostic | platform-independent | no | Don't use; replace with "platform-independent" or similar. |
| AI | (keep, see Notes) | no | Can use without spelling out; spell out on first use if audience is unfamiliar. |
| aka | also known as | yes | Don't use; write out "also known as" or use parentheses or alternative phrasing. |
| allowlist (verb) | (drop) | no | Don't use as a verb; OK as a noun; see blacklist guidance. |
| alpha | (keep, see Notes) | no | Lowercase except in product names. |
| and/or | (drop) | no | Don't use unless space-limited (tables); see slash guidance. |
| anti-pattern | (drop) | no | Avoid; use a specific term like "SQL errors" instead. |
| API | (keep, see Notes) | no | Use for web or language-specific APIs; don't use for methods or classes. |
| app | (keep, see Notes) | no | Use generally for end-user programs, especially mobile/web; use "application" for enterprise or standard phrases. |
| appendix | (keep, see Notes) | no | Use plural "appendixes," not "appendices". |
| as (causal) | because | no | If meaning "because," use "because" instead; "as" refers to time passage. |
| authentication and authorization | (keep, see Notes) | no | Use "authenticated" for users, "authorized" for requests; use preposition "against" with "authenticate". |
| autoupdate | automatically update | no | Don't use; replace with "automatically update". |
| backend | (keep, see Notes) | no | Not "back-end" or "back end". |
| bar (placeholder) | (drop) | no | Avoid; see "foo" guidance; use clearer, meaningful placeholder names. |
| bare metal | (keep, see Notes) | no | Lowercase; hyphenate when used as a compound modifier. |
| base64 | (keep, see Notes) | no | Lowercase; use code font only if it is a string literal or quoted from code. |
| baz (placeholder) | (drop) | no | Avoid; see "foo" guidance; use meaningful placeholder names. |
| best effort | (drop) | no | Avoid; use specific wording; can note "sometimes referred to as best effort". |
| beta | (keep, see Notes) | no | Lowercase except in product names. |
| big-endian | (keep, see Notes) | no | Hyphenate; lowercase except at sentence/heading/list start. |
| black-box | synthetic monitoring | no | Avoid; use "synthetic monitoring" for monitoring or "opaque-box testing" for testing. |
| blackhat / black hat / black-hat | (drop) | no | Don't use; replace with specific terms like "illegal" or "unethical". |
| blackhole (verb/adjective) | dropped without notification | no | Don't use; replace with "dropped without notification" or a descriptive phrase. |
| blacklist / black list / black-list | denylist / excludelist / blocklist | no | Don't use; replace noun with "denylist," "excludelist," or "blocklist"; replace verbs with descriptive phrases. |
| blast radius | affected area / spatial impact | no | Don't use; replace with "affected area" or "spatial impact". |
| blue-green | (keep, see Notes) | no | Not "blue/green" or "blue green". |
| boolean | (keep, see Notes) | no | Use code font for programming keyword; lowercase for abstract type; uppercase for "Boolean mathematics". |
| break-glass | emergency access / manual fallback | no | Don't use; replace with "emergency access" or "manual fallback". |
| button | (keep, see Notes) | no | A link is not the same as a button; don't use "button" for links; use for mechanical/capacitive buttons. |
| can | (keep, see Notes) | no | Use to convey permission, ability, optional action, or possible outcome. |
| canary | (keep, see Notes) | no | Don't use as a verb; avoid jargon; define on first use if used. |
| cell phone / cellphone | mobile phone / mobile device | no | Don't use; use "mobile phone" or "mobile device". |
| cellular data | mobile data | yes | Don't use; replace with "mobile data". |
| cellular network | mobile network | yes | Don't use; replace with "mobile network". |
| chapter | document / page / section | no | Don't use for non-book documentation; use "document," "page," or "section". |
| checkbox | (keep, see Notes) | no | Not "check box". |
| CLI | (keep, see Notes) | no | Don't use generically; refer to the specific interface like "Google Cloud CLI". |
| codebase | (keep, see Notes) | no | Not "code base". |
| codelab | (keep, see Notes) | no | Not "code lab" or "code-lab". |
| colocate | (keep, see Notes) | no | Not "co-locate" or "colo". |
| compliant, compliance | (keep, see Notes) | no | Use with caution; makes a strong statement about standards adherence. |
| comprise | consist of / contain / include | no | Don't use; replace with "consist of," "contain," or "include". |
| config | configuration | no | Avoid; spell out "configuration" or "configuring" in non-code contexts. |
| console | (keep, see Notes) | no | Don't use in isolation; use the specific console name like "Google Cloud console". |
| Copy and paste | (drop) | no | Avoid; explain what to enter instead of how to copy and paste. |
| could | can | no | Avoid; use "can" where possible. |
| CPU | (keep, see Notes) | no | All caps; no need to expand on first mention. |
| Create a new | Create a | yes | Avoid "new" unless distinguishing from recent items; use "Create a...". |
| cross-site request forgery | (keep, see Notes) | no | Lowercase except at sentence/heading/list start. |
| curated roles | predefined roles | yes | Don't use; replace with "predefined roles". |
| curl | (keep, see Notes) | no | Not "cURL"; use code font appropriately. |
| dashboard | (keep, see Notes) | no | Don't use for the Google Cloud console; use lowercase unless part of a product name. |
| data | (keep, see Notes) | no | Treat as singular ("data is"); use as a mass noun ("less data"). |
| data center | (keep, see Notes) | no | Not "datacenter". |
| data cleaning | (keep, see Notes) | no | Not "data cleansing". |
| dead-letter queue | (keep, see Notes) | no | Define on first use (e.g., "unprocessed messages queue"). |
| deep linking | (keep, see Notes) | no | Not "deep-linking"; omit if possible. |
| demilitarized zone (DMZ) | perimeter network | no | Don't use; replace with "perimeter network". |
| denigrate | disparage | yes | Don't use; replace with "disparage". |
| denylist (verb) | (drop) | no | Don't use as a verb; OK as a noun; see blacklist guidance. |
| deprecate | (keep, see Notes) | no | Means recommend against use; don't use to mean "removed" or "deleted". |
| desire, desired | want / need | no | Don't use; replace with "want" or "need". |
| DevOps | (keep, see Notes) | no | Short for "development operations"; no need to spell out on first mention. |
| dialog | (keep, see Notes) | no | Use for dialog UI element; "dialogue" only for person-to-person interaction. |
| directory / folder | (keep, see Notes) | no | Match context terminology; use "directory" for command-line, "folder" for GUI. |
| disclosure triangle / disclosure widget | expander arrow | no | Don't use; replace with "expander arrow". |
| display (verb) | (keep, see Notes) | no | Requires an object; not "The area displays" but "The area is displayed" or "displays the image". |
| distributed denial-of-service (DDoS) | (keep, see Notes) | no | Hyphenate as shown; use "DDoS" on subsequent mention. |
| documentation or document or documents | (keep, see Notes) | no | Use "this document" for page text; spell out "documentation" except in space-limited contexts. |
| downscope | (drop) | no | Use a descriptive term like "constrain scope"; define if used; not "down scope". |
| drop-down | list / menu | no | Omit when possible; include only if ambiguity arises without it. |
| dummy variable | indicator variable | no | Don't use for placeholders; avoid in statistics contexts; use "indicator variable". |
| each | (keep, see Notes) | no | Refers to individual items separately, not collectively; don't use as a synonym for "all". |
| edge availability domain | (keep, see Notes) | no | Don't use "edge availability zone" or abbreviate as "EAD". |
| egress | (keep, see Notes) | no | Use lowercase for networking contexts. |
| element | (keep, see Notes) | no | In HTML/XML, distinguish from "tag"; don't use "tag" for entire element. |
| endpoint | (keep, see Notes) | no | Not "end point". |
| ephemeral external IP address | (keep, see Notes) | no | Don't shorten or use variations. |
| exploit | (keep, see Notes) | no | Use only negatively (exploiting vulnerabilities), not to mean "use". |
| extract | (keep, see Notes) | no | Use instead of "unarchive" or "uncompress". |
| fat | high-capacity / full-featured | no | Don't use; employ precise modifiers like "high-capacity" or "full-featured". |
| FHIR | (keep, see Notes) | no | Refer as "a FHIR," not "an FHIR". |
| filename | (keep, see Notes) | no | Not "file name". |
| file system | (keep, see Notes) | no | Not "filesystem". |
| final solution | solution / definitive / optimal | no | Don't use; try "solution," "definitive," "optimal," or "best". |
| fintech | (keep, see Notes) | no | Write out on first mention: "financial technology (fintech)". |
| firewalls | firewall rules | no | In Compute Engine/networking docs, use "firewall rules" instead. |
| first class / first-class citizen | higher-order / anonymous / nested | no | Don't use; employ "higher-order," "anonymous," "nested," or descriptive characteristics. |
| foo (placeholder) | (drop) | no | Avoid; use clearer, meaningful placeholder names. |
| for example | (keep, see Notes) | no | Follow with a comma; separate example using dashes, commas, or parentheses. |
| frontend | (keep, see Notes) | no | Not "front-end" or "front end". |
| functionality | capabilities / features | no | Use cautiously; "capabilities" or "features" is often clearer. |
| generative AI | (keep, see Notes) | no | Spell out "generative"; use sentence case; don't hyphenate unless clarity requires it. |
| Google (as verb) | search with Google | no | Don't use "Google" or "Googling" as a verb; use "search with Google". |
| Google Account | (keep, see Notes) | no | Capitalize "Account". |
| Google Cloud | (keep, see Notes) | no | Not "GCP," "Cloud Platform," or "Cloud". |
| Google Cloud console | (keep, see Notes) | no | Can shorten to "the console" after first use. |
| Google I/O | (keep, see Notes) | no | Not "I-O" or "IO". |
| graylist / greylist | (drop) | no | Don't use; see "blacklist" for alternatives. |
| hamburger / hamburger menu | (drop) | no | Don't use; use the aria-label for the icon instead. |
| hands off / hands-on | automated / customizable | no | Use less figurative terms like "automated" or "customizable". |
| hardcode / hardcoded | (keep, see Notes) | no | Don't hyphenate. |
| health check | (keep, see Notes) | no | Use cautiously; only if the term appears in the interface; avoid figurative language. |
| high availability / high-availability | (keep, see Notes) | no | Noun: "high availability"; adjective: "high-availability"; abbreviate as "HA" after first use. |
| home screen | (keep, see Notes) | no | Two words in Android; not "homescreen" or "home-screen". |
| hostname | (keep, see Notes) | no | Not "host name". |
| hotspot | (keep, see Notes) | no | Define on first use; use as a noun only, not in verb/gerund forms. |
| HTTPS | (keep, see Notes) | no | Not "HTTPs". |
| IaaS | (keep, see Notes) | no | Write out on first mention as "infrastructure as a service (IaaS)". |
| IAM | (keep, see Notes) | no | Spell out "Identity and Access Management (IAM)" on first use for the Google Cloud product. |
| ID | (keep, see Notes) | no | Use "ID" (not "Id" or "id") except in string literals; consider spelling out as "identifier". |
| if (technical) | (keep, see Notes) | no | Include helper words like "then" in if-then statements for clarity. |
| image | (keep, see Notes) | no | Avoid using alone; add context like "disk image" or "container image" for better localization. |
| impact | affect | no | Use only as a noun; use "affect" instead of "impacts" as a verb. |
| index | (keep, see Notes) | no | Use plural "indexes" unless domain-specific reasons require "indices". |
| ingest | import / load / copy | no | Use "import," "load," or "copy" for simple data movement; reserve "ingest" for significant processing. |
| ingress | (keep, see Notes) | no | Lowercase for networking term; capitalize when referring to the GKE term or API. |
| inline | (keep, see Notes) | no | One word as adjective; not "in line" or "in-line". |
| interface | (keep, see Notes) | no | OK to use as noun; don't use as verb (use "interact" instead). |
| internet of things | IoT | no | Acceptable abbreviation (note lowercase "o"). |
| IoT | (keep, see Notes) | no | Acceptable abbreviation for "Internet of Things" (note lowercase "o"). |
| IPsec | (keep, see Notes) | no | Not "IPSec" or "IPSEC"; short for "Internet Protocol Security". |
| jank, janky | (keep, see Notes) | no | Use only to describe graphics glitches from data loss or refresh rate issues; avoid otherwise. |
| k8s | Kubernetes | yes | Don't use; write "Kubernetes" instead. |
| kebab / kebab menu | (drop) | no | Don't use; use the appropriate aria-label instead. |
| kebab case | dash-case | yes | Don't use; use "dash-case". |
| key (adjective) | (drop) | no | Don't use as adjective meaning "crucial"; specify key type when using as noun. |
| key ring | (keep, see Notes) | no | Use instead of "keyring" when referring to Cloud KMS key groupings. |
| key-value pair | (keep, see Notes) | no | Not "key/value pair" or "key value pair". |
| legacy | (keep, see Notes) | no | Use a precise term if possible; include definition if used. |
| lifecycle | (keep, see Notes) | no | Not "life cycle" or "life-cycle". |
| lift and shift | rehost | no | See "rehost"; both terms are acceptable. |
| limits | (keep, see Notes) | no | Specify type of limit (usage, service); the term can refer to many different kinds. |
| little-endian | (keep, see Notes) | no | Hyphenate; lowercase except at sentence start. |
| livestream | (keep, see Notes) | no | Not "live stream". |
| load balancing / load-balancing | (keep, see Notes) | no | Noun: "load balancing"; adjective: "load-balancing". |
| lock screen | (keep, see Notes) | no | Two words in Android; not "lockscreen" or "lock-screen". |
| Markdown | (keep, see Notes) | no | Always capitalized, including nonstandard versions. |
| master (primary) | primary / main / parent / controller | no | Use with caution; never use with "slave"; replace with specific terms. |
| matrix | (keep, see Notes) | no | Use plural "matrixes" unless domain-specific reasons require "matrices". |
| may | can / might | no | Reserve for official policy or legal considerations; use "can" or "might" for possibility. |
| media type | (keep, see Notes) | no | Preferred term; use "content type" only when necessary for clarity. |
| microservices | (keep, see Notes) | no | Not "Microservices" or "micro-services". |
| might | (keep, see Notes) | no | Use to convey possibility or an uncertain outcome. |
| MIME type | media type | yes | Avoid; use "media type" instead. |
| mobile | (keep, see Notes) | no | Don't use as a standalone noun; specify "mobile phone" or "mobile device". |
| must | (keep, see Notes) | no | Use for required actions or states. |
| N/A | (keep, see Notes) | no | Not "NA"; spell out as "not available" or "not applicable" on first reference. |
| name server | (keep, see Notes) | no | Not "nameserver"; two words. |
| namespace | (keep, see Notes) | no | Not "name space"; one word. |
| native | built-in | no | Avoid when referring to people; use "built-in" for software features. |
| navigation bar | navigation menu | no | Don't use to refer to a navigation menu; distinct UI element term. |
| neither | (keep, see Notes) | no | Write "neither A nor B," not "neither A or B". |
| ninja | expert | no | Don't use for people; use "expert" instead. |
| NoOps | fully managed | no | Don't use; prefer "fully managed". |
| NoSQL | (keep, see Notes) | no | Not "No-SQL" or "No SQL". |
| nonce | (keep, see Notes) | no | Use with caution; define on first use in authentication/blockchain contexts. |
| nuke | remove / attack | no | Don't use; substitute "remove" or "attack" as appropriate. |
| OAuth 2.0 | (keep, see Notes) | no | Not "OAuth 2," "OAuth2," or "Oauth". |
| off-the-shelf | ready-made / prebuilt / standard | no | Use "ready-made," "prebuilt," "standard," or "default" instead. |
| on-premises | (keep, see Notes) | no | Not "on prem," "on premise," or "on-premise"; always hyphenate. |
| OS | (keep, see Notes) | no | OK to use as shortening of "operating system". |
| out of the box | (drop) | no | Avoid figurative use; OK for literal meaning only. |
| overview screen | recents screen | yes | Don't use in Android docs; use "recents screen" instead. |
| PaaS | (keep, see Notes) | no | Write out on first mention: "platform as a service (PaaS)". |
| parameter | (keep, see Notes) | no | Usually short for "query parameter"; clarify meaning in context. |
| performant | accurate | no | Avoid; use precise terms like "accurate" or specific performance metrics. |
| persist | make persistent | no | Don't use as a transitive verb; use "make persistent" instead. |
| personally identifiable information (PII) | (keep, see Notes) | no | Some agencies use "personally identifying information"; match document context. |
| plugin / plug-in / plug in | (keep, see Notes) | no | Noun: "plugin"; adjective: "plug-in"; verb: "plug in". |
| POJO | simple object | no | Use "simple object" for non-Java audiences; can reference POJO in Java contexts. |
| pop-up / popup | dialog / menu | no | Don't use; use "dialog" for additional information windows, "menu" for context menus. |
| populate | fill in | no | OK for filling tables/entities; use "fill in" for people. |
| portal | (drop) | no | Don't use for the Google Cloud console; use specific console terminology. |
| postmortem | retrospective | no | Avoid; use "retrospective" generally; use "blameless postmortem" in DevOps contexts. |
| prebuilt | (keep, see Notes) | no | Not "pre-built"; use the closed compound form. |
| pre-existing | (keep, see Notes) | no | Not "preexisting"; requires hyphen. |
| pre-shared key | (keep, see Notes) | no | Not "preshared key"; requires hyphen. |
| racist | (keep, see Notes) | no | Don't use casually; reserve for precise descriptions of actual discrimination. |
| rearchitect | (keep, see Notes) | no | Not "re-architect"; use the closed form. |
| red team | (keep, see Notes) | no | Acceptable in security testing contexts; use with clarity about purpose. |
| regex | (keep, see Notes) | no | Acceptable abbreviation; spell out "regular expression" on first mention if audience is unfamiliar. |
| rehost | (keep, see Notes) | no | Acceptable term for cloud migration strategy; also "lift and shift". |
| reinitialize | (keep, see Notes) | no | Not "re-initialize"; use the closed form. |
| rejoin | (keep, see Notes) | no | Not "re-join"; use the closed form for database/cluster contexts. |
| release | (keep, see Notes) | no | Use instead of "launch" for product versions; more precise and timeless. |
| remove | (keep, see Notes) | no | Preferred over "delete" for user-facing actions; more precise. |
| repo | repository | no | Avoid in formal documentation; spell out "repository". |
| re-create | (keep, see Notes) | no | Hyphenate when meaning "create again" to distinguish from "recreate" (enjoy oneself). |
| restart | (keep, see Notes) | no | Not "re-start"; use the closed form. |
| reuse | (keep, see Notes) | no | Not "re-use"; use the closed form. |
| rewrite | (keep, see Notes) | no | Not "re-write"; use the closed form. |
| role-based access control (RBAC) | (keep, see Notes) | no | Write out on first mention; abbreviate RBAC after. |
| rollback | (keep, see Notes) | no | One word; acceptable for version and configuration contexts. |
| rollout | (keep, see Notes) | no | One word; use for deployment and feature release contexts. |
| SaaS | (keep, see Notes) | no | Write out on first mention: "software as a service (SaaS)". |
| safelist | (keep, see Notes) | no | Acceptable alternative to "whitelist"; use for access control lists. |
| sandwich (metaphorical) | (drop) | no | Avoid metaphorical use; use precise, literal language. |
| sanitize | (keep, see Notes) | no | Acceptable in security/data contexts; avoid figurative use. |
| second-generation | (keep, see Notes) | no | Hyphenate; use for product versioning when necessary. |
| self-hosted | (keep, see Notes) | no | Hyphenate; use for on-premises deployments. |
| service level agreement (SLA) | (keep, see Notes) | no | Write out on first mention; abbreviate SLA after. |
| service level indicator (SLI) | (keep, see Notes) | no | Write out on first mention; abbreviate SLI after. |
| service level objective (SLO) | (keep, see Notes) | no | Write out on first mention; abbreviate SLO after. |
| setup / set up | (keep, see Notes) | no | One word as noun; "set up" as verb; use for initial configuration. |
| shift left | (keep, see Notes) | no | Acceptable in DevOps and security testing; define on first use. |
| should | (keep, see Notes) | no | Use for recommendations and best practices; softer than "must". |
| sign in / sign out | (keep, see Notes) | no | Preferred over "log in/log out"; use consistently. |
| single sign-on (SSO) | (keep, see Notes) | no | Write out on first mention; abbreviate SSO after. |
| smartphone | (keep, see Notes) | no | One word; use instead of "smart phone" or "smart-phone". |
| SQL | (keep, see Notes) | no | Standard abbreviation; no expansion needed on first mention. |
| SSH (Secure Shell) | (keep, see Notes) | no | Abbreviation acceptable; spell out on first mention if needed. |
| SSL/TLS | (keep, see Notes) | no | Acceptable abbreviation; specify which protocol when relevant. |
| stack trace | (keep, see Notes) | no | Two words; standard debugging term. |
| stateful | (keep, see Notes) | no | One word; acceptable in application and protocol contexts. |
| stateless | (keep, see Notes) | no | One word; acceptable in architecture descriptions. |
| such as | (keep, see Notes) | no | Preferred for introducing examples; include comma after. |
| sync / synchronize | (keep, see Notes) | no | "Sync" acceptable in informal contexts; spell out "synchronize" for clarity. |
| tag (HTML) | element | no | In HTML/XML, don't use "tag" for the entire element; use "element". |
| task | (keep, see Notes) | no | OK to use in Android contexts to describe units of work managed by the system. |
| telemetry | (keep, see Notes) | no | Use to describe data collected from systems; define on first use if audience is unfamiliar. |
| third party / third-party | (keep, see Notes) | no | Two words as noun; hyphenate as adjective ("third-party service"). |
| throttle | (keep, see Notes) | no | OK to use in performance contexts; define if needed. |
| time zone | (keep, see Notes) | no | Two words; not "timezone". |
| time series | (keep, see Notes) | no | Two words; not "timeseries". |
| toast (Android) | (keep, see Notes) | no | In Android documentation, refers to brief notification messages. |
| toggle | (keep, see Notes) | no | OK to use for on/off switches; use verb "toggle" or noun "toggle switch". |
| toolbar | (keep, see Notes) | no | One word; not "tool bar" or "tool-bar". |
| tooltip | (keep, see Notes) | no | One word; not "tool tip" or "tool-tip". |
| topic | guide / tutorial / reference | no | Don't use generically for documentation; use specific terms. |
| touch screen | (keep, see Notes) | no | Two words; not "touchscreen" unless part of a product name. |
| trustlist | (keep, see Notes) | no | Acceptable replacement for "whitelist"; see blacklist guidance. |
| tuple | (keep, see Notes) | no | Use in database and mathematics contexts; define if audience is unfamiliar. |
| two-factor authentication | (keep, see Notes) | no | Hyphenate; use instead of "2FA" without context. |
| UI | (keep, see Notes) | no | Acceptable abbreviation for "user interface"; spell out on first mention if audience is unfamiliar. |
| unarchive | extract | yes | Use "extract" instead. |
| up-to-date | (keep, see Notes) | no | Hyphenate when used as an adjective. |
| use case | (keep, see Notes) | no | Two words; not "usecase"; define if needed. |
| user | (keep, see Notes) | no | OK to use; prefer over "end user" unless distinction is needed. |
| user experience, UX | (keep, see Notes) | no | Define abbreviation on first use. |
| user ID | (keep, see Notes) | no | Capitalize "ID"; don't use "UID" or "user id". |
| username | (keep, see Notes) | no | One word; not "user name". |
| UTC | (keep, see Notes) | no | Acceptable for Coordinated Universal Time; spell out on first mention if needed. |
| versus / vs. | versus | no | Avoid abbreviation in formal text; spell out "versus". |
| VPN | (keep, see Notes) | no | Define as "virtual private network" on first mention. |
| VPN gateway | (keep, see Notes) | no | Two words; not "VPN-gateway". |
| we | (drop) | no | Avoid first-person plural in documentation; use second person instead. |
| webhook | (keep, see Notes) | no | One word; not "web hook" or "web-hook". |
| web page | (keep, see Notes) | no | Two words; not "webpage". |
| web service | (keep, see Notes) | no | Two words; not "webservice". |
| website | (keep, see Notes) | no | One word; not "web site". |
| well-architected | (keep, see Notes) | no | Hyphenate when describing designs or frameworks. |
| well-formed | (keep, see Notes) | no | Hyphenate when describing correct syntax or structure. |
| while / although | (keep, see Notes) | no | Use "while" for time sequences or contrasts; don't confuse with "although". |
| whitelist / white list / white-list | allowlist / safelist / trustlist | no | Don't use; see "blacklist" for replacements. |
| whitespace | (keep, see Notes) | no | One word; not "white space" or "white-space". |
| wizard | (keep, see Notes) | no | OK to use for guided setup interfaces. |
| workflow | (keep, see Notes) | no | One word; not "work flow". |
| workspace | (keep, see Notes) | no | One word; not "work space". |
| XML | (keep, see Notes) | no | Acceptable acronym; spell out "Extensible Markup Language" on first mention if needed. |
| YAML | (keep, see Notes) | no | Acceptable acronym; spell out on first mention if needed: "YAML Ain't Markup Language". |
| zero-trust | (keep, see Notes) | no | Hyphenate when describing security models or architectures. |
| ZIP / zip | (keep, see Notes) | no | Use "ZIP" for the file format; "zip" for the action. |
