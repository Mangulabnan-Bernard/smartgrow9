import { initializeApp } from 'firebase/app';
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  User,
  setPersistence,
  browserLocalPersistence,
  authStateReady
} from 'firebase/auth';
import { 
  getFirestore,
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
  arrayUnion,
  arrayRemove,
  query,
  where,
  orderBy,
  limit,
  getDocs
} from 'firebase/firestore';
import { firebaseConfig } from '../src/firebase';

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Set auth persistence to survive browser restarts
setPersistence(auth, browserLocalPersistence);

export interface UserProfile {
  uid: string;
  email: string;
  displayName?: string;
  createdAt: number;
  lastLoginAt: number;
}

export interface AuthError {
  code: string;
  message: string;
}

class FirebaseService {
  private currentUser: User | null = null;
  private authInitialized: boolean = false;

  constructor() {
    // Listen to auth state changes
    onAuthStateChanged(auth, (user) => {
      this.currentUser = user;
      this.authInitialized = true;
      if (user) {
        // Update last login time
        this.updateUserProfile(user.uid, { lastLoginAt: Date.now() });
      }
    });
  }

  // Sign up with email and password
  async signUp(email: string, password: string, displayName?: string): Promise<UserProfile> {
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Create user profile
      const profile: UserProfile = {
        uid: user.uid,
        email: user.email!,
        displayName: displayName || user.email!.split('@')[0],
        createdAt: Date.now(),
        lastLoginAt: Date.now()
      };
      
      // Store profile in localStorage (you could also use Firestore)
      localStorage.setItem(`smartgrow_profile_${user.uid}`, JSON.stringify(profile));
      
      return profile;
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  // Sign in with email and password
  async signIn(email: string, password: string): Promise<UserProfile> {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Get or create user profile
      let profile = this.getUserProfile(user.uid);
      if (!profile) {
        profile = {
          uid: user.uid,
          email: user.email!,
          displayName: user.email!.split('@')[0],
          createdAt: Date.now(),
          lastLoginAt: Date.now()
        };
        localStorage.setItem(`smartgrow_profile_${user.uid}`, JSON.stringify(profile));
      } else {
        // Update last login
        profile.lastLoginAt = Date.now();
        this.updateUserProfile(user.uid, profile);
      }
      
      return profile;
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  // Sign out
  async signOut(): Promise<void> {
    try {
      await signOut(auth);
    } catch (error: any) {
      throw this.formatAuthError(error);
    }
  }

  // Get current user
  getCurrentUser(): User | null {
    return this.currentUser;
  }

  // Get user profile from localStorage
  getUserProfile(uid: string): UserProfile | null {
    const profileData = localStorage.getItem(`smartgrow_profile_${uid}`);
    return profileData ? JSON.parse(profileData) : null;
  }

  // Update user profile
  private updateUserProfile(uid: string, updates: Partial<UserProfile>): void {
    const profile = this.getUserProfile(uid);
    if (profile) {
      const updatedProfile = { ...profile, ...updates };
      localStorage.setItem(`smartgrow_profile_${uid}`, JSON.stringify(updatedProfile));
    }
  }

  // Format Firebase auth errors
  private formatAuthError(error: any): AuthError {
    const errorMap: Record<string, string> = {
      'auth/email-already-in-use': 'An account with this email already exists.',
      'auth/invalid-email': 'Invalid email address.',
      'auth/invalid-credential': 'Invalid email or password.',
      'auth/operation-not-allowed': 'Email/password accounts are not enabled.',
      'auth/weak-password': 'Password should be at least 6 characters.',
      'auth/user-not-found': 'No account found with this email.',
      'auth/wrong-password': 'Incorrect password.',
      'auth/too-many-requests': 'Too many failed attempts. Please try again later.',
      'auth/network-request-failed': 'Network error. Please check your connection.'
    };

    return {
      code: error.code,
      message: errorMap[error.code] || error.message || 'An unknown error occurred.'
    };
  }

  // Check if user is authenticated
  isAuthenticated(): boolean {
    return this.currentUser !== null;
  }

  // Check if auth is initialized
  isAuthInitialized(): boolean {
    return this.authInitialized;
  }

  // Wait for auth to be initialized
  waitForAuthInit(): Promise<void> {
    return new Promise((resolve) => {
      if (this.authInitialized) {
        resolve();
      } else {
        const checkInterval = setInterval(() => {
          if (this.authInitialized) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
      }
    });
  }

  // Cloud storage methods
  async saveUserData(uid: string, dataType: 'scans' | 'monitoring' | 'alerts' | 'stats', data: any): Promise<void> {
    try {
      const docRef = doc(db, 'users', uid, 'data', dataType);
      await setDoc(docRef, { data, updatedAt: Date.now() }, { merge: true });
    } catch (error) {
      console.error('Error saving user data:', error);
      throw error;
    }
  }

  async getUserData(uid: string, dataType: 'scans' | 'monitoring' | 'alerts' | 'stats'): Promise<any> {
    try {
      const docRef = doc(db, 'users', uid, 'data', dataType);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        return docSnap.data().data;
      }
      return null;
    } catch (error) {
      console.error('Error getting user data:', error);
      return null;
    }
  }

  async syncDataFromCloud(uid: string): Promise<{
    scans?: any[];
    monitoring?: any[];
    alerts?: any[];
    stats?: any;
  }> {
    try {
      const [scans, monitoring, alerts, stats] = await Promise.all([
        this.getUserData(uid, 'scans'),
        this.getUserData(uid, 'monitoring'),
        this.getUserData(uid, 'alerts'),
        this.getUserData(uid, 'stats')
      ]);

      return {
        scans: scans || [],
        monitoring: monitoring || [],
        alerts: alerts || [],
        stats: stats || null
      };
    } catch (error) {
      console.error('Error syncing data from cloud:', error);
      return {};
    }
  }
}

export const firebaseService = new FirebaseService();
export const waitForAuthInit = () => firebaseService.waitForAuthInit();
export default firebaseService;
