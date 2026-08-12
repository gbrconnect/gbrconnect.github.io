/* GBR Connect — service worker
   Estratégia: sempre tenta a rede primeiro (para pegar versões novas na hora)
   e cai para o cache quando a internet falha. */
const CACHE = 'gbr-connect-v1';
const ESSENCIAIS = ['./index.html', './manifest.webmanifest', './icone-192.png', './icone-512.png'];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ESSENCIAIS).catch(() => { })));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // nunca guarda chamadas ao banco: precisam ser sempre atuais
  if (url.hostname.endsWith('supabase.co')) return;

  e.respondWith(
    fetch(req)
      .then(resp => {
        if (resp && resp.ok && url.origin === location.origin) {
          const copia = resp.clone();
          caches.open(CACHE).then(c => c.put(req, copia));
        }
        return resp;
      })
      .catch(() => caches.match(req).then(r => r || caches.match('./index.html')))
  );
});
