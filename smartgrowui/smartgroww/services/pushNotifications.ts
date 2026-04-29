// Simple push notification utilities
export const requestNotificationPermission = async (): Promise<string | null> => {
  if (!('Notification' in window)) {
    console.log('This browser does not support notifications');
    return null;
  }

  try {
    const permission = await Notification.requestPermission();
    if (permission === 'granted') {
      console.log('Notification permission granted');
      return 'permission-granted';
    }
    return null;
  } catch (error) {
    console.error('Error getting notification permission:', error);
    return null;
  }
};

export const showNotification = (title: string, options?: any) => {
  if ('Notification' in window) {
    new Notification(title, {
      icon: '/icon-192x192.png',
      badge: '/icon-192x192.png',
      ...options
    });
  }
};
