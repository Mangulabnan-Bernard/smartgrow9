import { initializeApp } from 'firebase/app';
import { getMessaging, getToken, onMessage, isSupported } from 'firebase/messaging';
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } from 'firebase/auth';
import { getFirestore, collection, addDoc, getDocs, query, where, orderBy, limit } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Initialize Firebase Cloud Messaging
let messaging: ReturnType<typeof getMessaging> | null = null;

// Check if running in a browser environment
if (typeof window !== 'undefined') {
  // Check if service workers are supported
  if ('serviceWorker' in navigator) {
    isSupported().then((isSupported) => {
      if (isSupported) {
        messaging = getMessaging(app);
      }
    });
  }
}

export const requestNotificationPermission = async (): Promise<string | null> => {
  if (!messaging) {
    console.warn('Firebase Messaging is not supported in this environment');
    return null;
  }

  try {
    const permission = await Notification.requestPermission();
    if (permission === 'granted') {
      const token = await getToken(messaging, {
        vapidKey: import.meta.env.VITE_VAPID_KEY
      });
      
      console.log('FCM Token:', token);
      await saveTokenToBackend(token);
      return token;
    }
    return null;
  } catch (error) {
    console.error('Error getting notification permission:', error);
    return null;
  }
};

export const onMessageListener = () =>
  new Promise((resolve) => {
    if (!messaging) {
      console.warn('Firebase Messaging is not available');
      resolve(null);
      return;
    }

    onMessage(messaging, (payload) => {
      console.log('Message received:', payload);
      resolve(payload);
    });
  });

async function saveTokenToBackend(token: string) {
  try {
    // Get current user or use anonymous ID
    const userId = auth.currentUser?.uid || 'anonymous-' + Math.random().toString(36).substr(2, 9);
    
    // Save to Firestore
    await addDoc(collection(db, 'fcmTokens'), {
      userId,
      token,
      createdAt: new Date(),
      userAgent: navigator.userAgent
    });

    console.log('FCM token saved to backend');
  } catch (error) {
    console.error('Error saving FCM token:', error);
  }
}

// Auth functions
export const firebaseAuth = {
  signIn: async (email: string, password: string) => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return { success: true, user: result.user };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  },
  
  signUp: async (email: string, password: string) => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      return { success: true, user: result.user };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  },
  
  signOut: async () => {
    try {
      await signOut(auth);
      return { success: true };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  },
  
  getCurrentUser: () => auth.currentUser,
  
  onAuthStateChanged: (callback: (user: any) => void) => {
    return auth.onAuthStateChanged(callback);
  }
};

// Firestore functions
export const firestore = {
  addDocument: async (collectionName: string, data: any) => {
    try {
      const docRef = await addDoc(collection(db, collectionName), {
        ...data,
        createdAt: new Date()
      });
      return { success: true, id: docRef.id };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  },
  
  getDocuments: async (collectionName: string, limitCount = 10) => {
    try {
      const q = query(
        collection(db, collectionName),
        orderBy('createdAt', 'desc'),
        limit(limitCount)
      );
      const querySnapshot = await getDocs(q);
      const documents = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      return { success: true, documents };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }
};

export { app, auth, db, messaging };
