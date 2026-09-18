// Smoothly scroll to a page section WITHOUT touching the URL — clicking
// landing nav buttons must never add "#section" to the address bar or
// push history entries (BrowserRouter stays clean).
export function scrollToId(id) {
  const el = document.getElementById(id);
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}