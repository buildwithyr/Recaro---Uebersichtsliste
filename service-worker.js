/* Service Worker fuer Web-Push (Notizen-Benachrichtigungen). Cached bewusst
   keine Anwendungsdateien - die App wird bei jedem Start frisch geladen; hier
   geht es nur um den Push-Empfang, der ohne aktiven Worker nicht moeglich ist. */
self.addEventListener('install', event => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('push', event => {
  let data = {};
  try{ data = event.data ? event.data.json() : {}; }catch(e){}
  const title = data.title || 'Neue Notiz';
  const options = {
    body: data.body || '',
    icon: 'icon.png',
    badge: 'icon.png',
    data: {nr: data.nr || null}
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  const nr = event.notification.data && event.notification.data.nr;
  const url = nr ? ('./?nr=' + encodeURIComponent(nr)) : './';
  event.waitUntil(
    self.clients.matchAll({type: 'window', includeUncontrolled: true}).then(clientList => {
      for(const client of clientList){
        if('focus' in client){
          if('navigate' in client){ client.navigate(url); }
          return client.focus();
        }
      }
      if(self.clients.openWindow) return self.clients.openWindow(url);
    })
  );
});
