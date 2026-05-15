/**
 * presenter.js, two-window presenter mode for <deck-stage> decks.
 *
 * Loaded by the main deck page (after deck-stage.js). Adds:
 *   • Press P to open a presenter window (notes + next-slide preview + timer).
 *   • Press B to black out the audience screen.
 *   • BroadcastChannel sync, keyboard or button nav in either window
 *     moves both. Disconnect-tolerant: closing the presenter window
 *     leaves the deck running.
 *
 * Sharing in Teams:
 *   1. Open the deck in a Chromium-based browser (Edge, Chrome, Arc).
 *   2. Press P. The first time, allow pop-ups for this page.
 *   3. In Teams, click Share → Window → pick the DECK window
 *      (not the presenter, that's the one with your notes on it).
 *
 * Wire format on BroadcastChannel `deck-presenter-<deckPath>`:
 *   { type: 'state', index, total, reason }     deck → presenter
 *   { type: 'nav-next' | 'nav-prev' }           either → deck
 *   { type: 'nav-goto', index }                 either → deck
 *   { type: 'blackout-toggle' }                 presenter → deck
 *   { type: 'hello', from: 'presenter' }        presenter → deck (asks for state)
 */
(() => {
  // --- Guards -----------------------------------------------------------
  // Don't run inside deck-stage's own thumbnail iframes (rail / presenter
  // preview tiles). They load with ?_snthumb=... and the presenter sets
  // window.name to mark its preview iframes.
  if (/[?&]_snthumb=/.test(location.search)) return;
  if (window.name && window.name.indexOf('deck-presenter-preview-') === 0) return;

  const deck = document.querySelector('deck-stage');
  if (!deck) return;

  const POPUP_NAME = 'deck-presenter';
  const POPUP_FEATURES = 'popup=yes,width=1400,height=860';
  const CHANNEL_NAME = 'deck-presenter::' + location.pathname;

  const bc = ('BroadcastChannel' in window) ? new BroadcastChannel(CHANNEL_NAME) : null;
  let presenterWin = null;
  let blackoutEl = null;

  // --- Outbound state ---------------------------------------------------
  function postState(reason) {
    if (!bc) return;
    try {
      bc.postMessage({
        type: 'state',
        index: deck.index,
        total: deck.length,
        reason: reason || 'broadcast',
      });
    } catch (e) {}
  }

  // --- Presenter window -------------------------------------------------
  function openPresenter() {
    if (presenterWin && !presenterWin.closed) {
      try { presenterWin.focus(); } catch (e) {}
      return;
    }
    const here = location.pathname.split('/').pop() || 'index.html';
    const url = new URL('presenter.html', location.href);
    url.searchParams.set('deck', here);
    url.searchParams.set('channel', CHANNEL_NAME);
    url.hash = '#' + (deck.index + 1);
    presenterWin = window.open(url.toString(), POPUP_NAME, POPUP_FEATURES);
    if (!presenterWin) {
      console.warn('[presenter] pop-up blocked');
      alert('Pop-up blocked. Allow pop-ups for this page, then press P again.');
      return;
    }
    // Bounce state once the popup has had a beat to mount its listener.
    setTimeout(() => postState('open'), 300);
  }

  // --- Blackout overlay (covers the deck window's audience view) --------
  function toggleBlackout() {
    if (blackoutEl) {
      blackoutEl.remove();
      blackoutEl = null;
      return;
    }
    blackoutEl = document.createElement('div');
    blackoutEl.setAttribute('data-deck-blackout', '');
    blackoutEl.style.cssText = [
      'position:fixed', 'inset:0', 'background:#000',
      'z-index:2147483600', 'display:flex',
      'align-items:flex-end', 'justify-content:center',
      'padding:24px', 'color:rgba(255,255,255,0.16)',
      'font:11px ui-monospace,Menlo,Consolas,monospace',
      'letter-spacing:0.08em', 'text-transform:uppercase',
    ].join(';');
    blackoutEl.textContent = 'Press B to resume';
    document.body.appendChild(blackoutEl);
  }

  // --- Keyboard on the deck ---------------------------------------------
  document.addEventListener('keydown', (e) => {
    const t = e.target;
    const tag = (t && t.tagName) || '';
    if (tag === 'INPUT' || tag === 'TEXTAREA' || (t && t.isContentEditable)) return;
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    if (e.key === 'p' || e.key === 'P') { e.preventDefault(); openPresenter(); }
    else if (e.key === 'b' || e.key === 'B') { e.preventDefault(); toggleBlackout(); }
  });

  // --- Deck → channel: broadcast every slide change ---------------------
  deck.addEventListener('slidechange', (e) => {
    if (!bc) return;
    try {
      bc.postMessage({
        type: 'state',
        index: e.detail.index,
        total: e.detail.total,
        reason: e.detail.reason,
      });
    } catch (err) {}
  });

  // --- Channel → deck: receive nav from presenter -----------------------
  if (bc) {
    bc.addEventListener('message', (e) => {
      const d = e.data || {};
      if (d.type === 'nav-next') deck.next();
      else if (d.type === 'nav-prev') deck.prev();
      else if (d.type === 'nav-goto' && typeof d.index === 'number') deck.goTo(d.index);
      else if (d.type === 'blackout-toggle') toggleBlackout();
      else if (d.type === 'hello' && d.from === 'presenter') postState('hello');
    });
  }

  // Console hint so users discover the feature.
  console.info(
    '%c● Presenter mode',
    'color:#86BC24;font-weight:600',
    ', press P to open the notes window, B to black out the audience screen.'
  );
})();
