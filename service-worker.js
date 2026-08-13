/* Recovery worker: removes caches created by the withdrawn PWA version.
   It deliberately does not intercept requests or cache application files. */
self.addEventListener('install', event => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.map(key => caches.delete(key))))
      .then(() => self.registration.unregister())
      .then(() => self.clients.matchAll({type: 'window'}))
      .then(clients => clients.forEach(client => client.navigate(client.url)))
  );
});
