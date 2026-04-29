import React from 'react';
import { AlertTriangle, X } from 'lucide-react';

interface ConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'delete' | 'warning' | 'info';
}

const ConfirmModal: React.FC<ConfirmModalProps> = ({ 
  isOpen, 
  onClose, 
  onConfirm, 
  title, 
  message, 
  confirmText = 'Delete',
  cancelText = 'Cancel',
  type = 'delete'
}) => {
  const typeStyles = {
    delete: 'bg-red-500 text-white hover:bg-red-600',
    warning: 'bg-yellow-500 text-white hover:bg-yellow-600',
    info: 'bg-blue-500 text-white hover:bg-blue-600'
  };

  const iconStyles = {
    delete: 'text-red-100',
    warning: 'text-yellow-100',
    info: 'text-blue-100'
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-md" onClick={onClose}></div>
      
      <div className="bg-white w-full max-w-md rounded-[2rem] shadow-2xl relative overflow-hidden">
        <div className="p-6 border-b border-slate-100">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center ${iconStyles[type]}`}>
                <AlertTriangle className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-slate-800">{title}</h3>
            </div>
            <button 
              onClick={onClose}
              className="p-2 text-slate-400 hover:text-slate-600 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <p className="text-slate-600 text-sm leading-relaxed mt-2">
            {message}
          </p>
        </div>
        
        <div className="p-6 flex gap-3 bg-slate-50">
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 bg-white text-slate-700 border border-slate-200 rounded-xl font-medium hover:bg-slate-50 transition-colors"
          >
            {cancelText}
          </button>
          <button
            onClick={onConfirm}
            className={`flex-1 px-4 py-2 text-white rounded-xl font-medium transition-all ${typeStyles[type]}`}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal;
