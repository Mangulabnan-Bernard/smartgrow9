
import React, { useState } from 'react';
import { Mail, Lock, User as UserIcon, ArrowRight, Leaf, ShieldCheck, Sparkles, Contact, CheckCircle } from 'lucide-react';
import { Language } from '../types';
import { storageService } from '../services/storageService';
import { firebaseService } from '../services/firebaseService';

interface AuthModalProps {
  onSuccess: () => void;
  lang: Language;
}

const AuthModal: React.FC<AuthModalProps> = ({ onSuccess, lang }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (isLogin) {
        // Sign in with Firebase
        const profile = await firebaseService.signIn(email, password);
        
        // Load or initialize user stats
        const existingStats = localStorage.getItem(`smartgrow_stats_${profile.uid}`);
        if (existingStats) {
          localStorage.setItem('smartgrow_user_stats', existingStats);
        } else {
          // Initialize fresh stats for new user
          const initialStats = {
            username: profile.email.split('@')[0],
            fullName: profile.displayName || profile.email.split('@')[0],
            xp: 0,
            level: 1,
            scansCount: 0,
            sessionsCount: 0,
            profileIcon: 'Persona1',
            lastAction: 'Welcome back!'
          };
          storageService.saveUserStats(initialStats);
          localStorage.setItem(`smartgrow_stats_${profile.uid}`, JSON.stringify(initialStats));
        }
        
        // Store current user session
        localStorage.setItem('smartgrow_current_user', JSON.stringify(profile));
        onSuccess();
      } else {
        // Sign up with Firebase
        if (fullName.length < 2) {
          setError('Please enter your full name.');
          setLoading(false);
          return;
        }
        if (password.length < 6) {
          setError('Password must be at least 6 characters.');
          setLoading(false);
          return;
        }
        if (password !== confirmPassword) {
          setError('Passwords do not match.');
          setLoading(false);
          return;
        }
        
        const profile = await firebaseService.signUp(email, password, fullName);
        
        // Initialize fresh stats for new user
        const initialStats = {
          username: profile.email.split('@')[0],
          fullName: profile.displayName || fullName,
          xp: 0,
          level: 1,
          scansCount: 0,
          sessionsCount: 0,
          profileIcon: 'Persona1',
          lastAction: 'First time joining SmartGrow!'
        };
        storageService.saveUserStats(initialStats);
        localStorage.setItem(`smartgrow_stats_${profile.uid}`, JSON.stringify(initialStats));
        
        // Store current user session
        localStorage.setItem('smartgrow_current_user', JSON.stringify(profile));
        onSuccess();
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred during authentication.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[1000] flex flex-col md:flex-row bg-slate-50 overflow-hidden text-slate-900">
      {/* Visual Side */}
      <div className="hidden md:flex flex-1 relative bg-green-900 items-center justify-center p-20 overflow-hidden">
        {/* Floating Background Leaves */}
        <div className="absolute inset-0 overflow-hidden opacity-20">
          <Leaf className="absolute top-10 left-10 w-24 h-24 text-green-400 animate-float stagger-1" />
          <Leaf className="absolute bottom-20 left-1/4 w-16 h-16 text-emerald-400 animate-float stagger-3" />
          <Leaf className="absolute top-1/4 right-20 w-32 h-32 text-green-300 animate-float stagger-2" />
          <Leaf className="absolute bottom-1/3 right-1/4 w-12 h-12 text-lime-400 animate-float stagger-4" />
          <Leaf className="absolute top-1/2 left-10 w-20 h-20 text-green-500 animate-float stagger-5" />
        </div>

        <div className="absolute inset-0 opacity-20">
          <div className="absolute top-0 left-0 w-full h-full bg-[url('https://www.transparenttextures.com/patterns/leaf.png')] animate-slow-spin"></div>
          <div className="absolute -top-24 -left-24 w-96 h-96 bg-green-400 rounded-full blur-[150px] animate-glow"></div>
          <div className="absolute -bottom-24 -right-24 w-96 h-96 bg-emerald-400 rounded-full blur-[150px] animate-glow"></div>
        </div>
        
        <div className="relative z-10 space-y-8 max-w-lg text-center md:text-left">
          <div className="w-24 h-24 bg-white/10 backdrop-blur-2xl rounded-[3rem] flex items-center justify-center shadow-2xl border border-white/20 mx-auto md:mx-0 animate-float">
            <Leaf className="w-12 h-12 text-green-400" />
          </div>
          <h1 className="text-7xl font-black text-white leading-tight tracking-tighter animate-in fade-in slide-in-from-left duration-700">
            SmartGrow <span className="text-green-400">AI</span>
          </h1>
          <p className="text-xl text-green-100/70 font-medium leading-relaxed animate-in fade-in slide-in-from-left duration-700 stagger-1">
            Empowering your green thumb with the world's most advanced plant health monitoring platform.
          </p>
          
          <div className="grid grid-cols-2 gap-6 pt-10 animate-in fade-in slide-in-from-bottom-5 duration-700 stagger-2">
            <div className="flex flex-col items-center md:items-start gap-3 p-6 bg-white/5 backdrop-blur-lg rounded-[2rem] border border-white/10">
              <ShieldCheck className="w-8 h-8 text-green-400" />
              <span className="text-white font-bold text-sm">Safe & Private</span>
            </div>
            <div className="flex flex-col items-center md:items-start gap-3 p-6 bg-white/5 backdrop-blur-lg rounded-[2rem] border border-white/10">
              <Sparkles className="w-8 h-8 text-emerald-400" />
              <span className="text-white font-bold text-sm">Instant Care</span>
            </div>
          </div>
        </div>
      </div>

      {/* Form Side */}
      <div className="flex-1 flex items-center justify-center p-6 md:p-12 bg-white relative overflow-y-auto scrollbar-hide">
        {/* Animated Background Blobs for Mobile */}
        <div className="md:hidden absolute inset-0 overflow-hidden -z-10">
            <div className="absolute -top-40 -left-40 w-80 h-80 bg-green-50 rounded-full blur-[100px] animate-glow"></div>
            <div className="absolute -bottom-40 -right-40 w-80 h-80 bg-emerald-50 rounded-full blur-[100px] animate-glow"></div>
        </div>

        <div className="w-full max-w-sm py-10">
          <div className="text-center space-y-6 mb-12">
            <div className="inline-flex w-16 h-16 bg-green-600 rounded-2xl items-center justify-center shadow-xl animate-float">
               <Leaf className="w-8 h-8 text-white" />
            </div>
            <div className="space-y-2">
              <h2 className="text-4xl font-black text-slate-800 tracking-tight animate-in fade-in zoom-in duration-500">
                {isLogin ? 'Welcome Back' : 'Join SmartGrow'}
              </h2>
              <p className="text-slate-400 font-medium animate-in fade-in slide-in-from-top-2 duration-500 stagger-1">
                {isLogin ? 'Sign in to access your digital garden.' : 'Start your journey to becoming a plant expert.'}
              </p>
            </div>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit}>
            {!isLogin && (
              <div className="space-y-1.5 animate-in fade-in slide-in-from-left duration-300 stagger-1">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Full Name</label>
                <div className="relative group">
                  <Contact className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 w-5 h-5 group-focus-within:text-green-500 transition-colors" />
                  <input 
                    type="text" 
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="name" 
                    required={!isLogin}
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-green-500 focus:outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"
                  />
                </div>
              </div>
            )}

            <div className="space-y-1.5 animate-in fade-in slide-in-from-left duration-300 stagger-2">
              <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Email</label>
              <div className="relative group">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 w-5 h-5 group-focus-within:text-green-500 transition-colors" />
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="enter your email" 
                  required
                  className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-green-500 focus:outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"
                />
              </div>
            </div>

            <div className="space-y-1.5 animate-in fade-in slide-in-from-left duration-300 stagger-3">
              <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Password</label>
              <div className="relative group">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 w-5 h-5 group-focus-within:text-green-500 transition-colors" />
                <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••" 
                  required
                  className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-green-500 focus:outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"
                />
              </div>
            </div>

            {!isLogin && (
              <div className="space-y-1.5 animate-in fade-in slide-in-from-left duration-300 stagger-4">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Confirm Password</label>
                <div className="relative group">
                  <ShieldCheck className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 w-5 h-5 group-focus-within:text-green-500 transition-colors" />
                  <input 
                    type="password" 
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="••••••••" 
                    required={!isLogin}
                    className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:ring-2 focus:ring-green-500 focus:outline-none transition-all font-bold text-slate-900 placeholder:text-slate-300"
                  />
                </div>
              </div>
            )}

            {error && (
              <div className="p-4 bg-red-50 text-red-600 rounded-2xl text-xs font-bold border border-red-100 animate-in fade-in slide-in-from-top-2">
                {error}
              </div>
            )}

            <button 
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-green-600 text-white font-black text-base rounded-2xl shadow-lg shadow-green-100 hover:bg-green-700 active:scale-95 transition-all flex items-center justify-center gap-2 mt-8 disabled:opacity-50 disabled:cursor-not-allowed animate-in fade-in slide-in-from-bottom-5 duration-500 stagger-5"
            >
              {loading ? (
                <div className="w-5 h-5 border-3 border-white/30 border-t-white rounded-full animate-spin"></div>
              ) : (
                <>
                  {isLogin ? 'Sign In' : 'Create Account'}
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          <div className="text-center mt-8 animate-in fade-in duration-1000 stagger-5">
            <button 
              onClick={() => { 
                  setIsLogin(!isLogin); 
                  setError(null); 
                  setPassword(''); 
                  setConfirmPassword('');
                  setEmail('');
              }}
              className="text-sm font-bold text-slate-400 hover:text-green-600 transition-colors py-2"
            >
              {isLogin ? (
                  <>Don't have an account? <span className="text-green-600">Sign up</span></>
              ) : (
                  <>Already have an account? <span className="text-green-600">Sign in</span></>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AuthModal;
