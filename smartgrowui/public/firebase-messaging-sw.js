importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyADHYR8KuKTGD2q8gKyxJoB2qWbh4ZOixQ",
  authDomain: "smart-grow-87165.firebaseapp.com",
  projectId: "smart-grow-87165",
  storageBucket: "smart-grow-87165.firebasestorage.app",
  messagingSenderId: "834079209309",
  appId: "1:834079209309:web:5cf17102b7e7f0ec0a5ab4"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message', payload);
  
  const notificationTitle = payload.notification?.title || 'SmartGrow Alert';
  const notificationOptions = {
    body: payload.notification?.body,
    icon: '/icon-192x192.png',
    badge: '/icon-192x192.png',
    data: payload.data || {},
    vibrate: [200, 100, 200],
    requireInteraction: true
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  // Open the app or a specific URL when notification is clicked
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      const urlToOpen = event.notification.data?.url || '/';
      
      for (const client of clientList) {
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});
