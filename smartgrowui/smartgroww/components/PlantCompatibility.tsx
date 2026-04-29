
import React, { useState } from 'react';
import { ChevronLeft, Info, Check, X, Leaf, Search, Dna, Beaker, Sparkles } from 'lucide-react';
import { PLANT_GUIDE_DATA, TRANSLATIONS } from '../constants';
import { Language } from '../types';

interface PlantCompatibilityProps {
  lang: Language;
  onBack: () => void;
}

const PlantCompatibility: React.FC<PlantCompatibilityProps> = ({ lang, onBack }) => {
  const [selected, setSelected] = useState(PLANT_GUIDE_DATA[0]);
  const [search, setSearch] = useState('');
  const t = TRANSLATIONS[lang];

  const filteredPlants = PLANT_GUIDE_DATA.filter(p => 
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6 animate-in slide-in-from-right duration-300">
      <div className="flex items-center gap-4 mb-4">
        <button onClick={onBack} className="p-3 bg-white rounded-2xl shadow-sm border border-slate-100 hover:bg-slate-50 transition-colors">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <div>
          <h2 className="text-2xl font-black text-slate-800 leading-tight">{t.knowledgeHeader}</h2>
          <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">{t.knowledgeSub}</p>
        </div>
      </div>

      {/* Search & Selection */}
      <div className="space-y-4">
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300 w-5 h-5" />
          <input 
            type="text"
            placeholder={t.searchPlaceholder}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-12 pr-4 py-4 bg-white border border-slate-100 rounded-2xl focus:ring-2 focus:ring-[var(--primary-500)] focus:outline-none transition-all shadow-sm font-medium"
          />
        </div>

        <div className="flex gap-2 overflow-x-auto pb-4 scrollbar-hide">
          {filteredPlants.length > 0 ? (
            filteredPlants.map(plant => (
              <button
                key={plant.id}
                onClick={() => setSelected(plant)}
                className={`px-6 py-3 rounded-2xl font-black text-xs uppercase tracking-widest transition-all whitespace-nowrap active:scale-95 ${
                  selected.id === plant.id 
                    ? 'bg-[var(--primary-600)] text-white shadow-lg shadow-[var(--primary-200)]' 
                    : 'bg-white text-slate-500 border border-slate-100 hover:border-[var(--primary-200)]'
                }`}
              >
                {plant.name}
              </button>
            ))
          ) : (
            <p className="text-xs text-slate-400 italic px-4">No plants found.</p>
          )}
        </div>
      </div>

      {/* Main Info Card */}
      <div className="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100 relative overflow-hidden">
        <div className="absolute top-0 right-0 p-8 opacity-5">
          <Dna className="w-32 h-32 text-[var(--primary-600)]" />
        </div>
        
        <div className="flex items-center gap-5 mb-10 relative z-10">
          <div className="w-20 h-20 bg-[var(--primary-100)] text-[var(--primary-600)] rounded-[2rem] flex items-center justify-center shadow-inner transition-colors duration-500">
            <Leaf className="w-10 h-10" />
          </div>
          <div>
            <h3 className="text-3xl font-black text-slate-800">{selected.name}</h3>
            <div className="flex flex-wrap gap-2 mt-2">
              <span className="px-3 py-1 bg-slate-900 text-white rounded-full text-[9px] font-black uppercase tracking-widest">
                {selected.category}
              </span>
              <span className="px-3 py-1 bg-[var(--primary-50)] text-[var(--primary-600)] rounded-full text-[9px] font-black uppercase tracking-widest border border-[var(--primary-100)] transition-colors duration-500">
                Mix-able
              </span>
            </div>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-10">
          <div className="space-y-8">
            {/* Hybridization Section */}
            <section className="bg-[var(--primary-50)]/50 p-6 rounded-3xl border border-[var(--primary-100)] transition-colors duration-500">
              <h4 className="flex items-center gap-3 text-[var(--primary-700)] font-black text-sm uppercase tracking-widest mb-4 transition-colors duration-500">
                <div className="p-2 bg-[var(--primary-600)] text-white rounded-lg transition-colors duration-500"><Dna className="w-4 h-4" /></div>
                {t.mixTips}
              </h4>
              <p className="text-slate-700 text-xs leading-relaxed font-bold">
                {selected.hybridInfo || "Standard growth rules. This plant does not mix easily with others."}
              </p>
            </section>

            <section>
              <h4 className="flex items-center gap-3 text-[var(--primary-600)] font-black text-sm uppercase tracking-widest mb-5 transition-colors duration-500">
                <div className="p-2 bg-[var(--primary-100)] rounded-lg transition-colors duration-500"><Check className="w-4 h-4" /></div>
                {t.companionPlants}
              </h4>
              <div className="flex flex-wrap gap-2">
                {selected.companions.map(comp => (
                  <span key={comp} className="px-5 py-2.5 bg-slate-50 text-slate-700 rounded-xl text-xs font-bold border border-slate-100 hover:bg-[var(--primary-50)] hover:border-[var(--primary-200)] transition-all">
                    {comp}
                  </span>
                ))}
              </div>
            </section>
          </div>

          <div className="space-y-6">
            <section className="bg-slate-50 p-8 rounded-[2rem] border border-slate-100 relative group transition-all hover:bg-white hover:shadow-xl hover:shadow-slate-200/50">
              <h4 className="flex items-center gap-3 text-slate-800 font-black text-sm uppercase tracking-widest mb-5">
                <div className="p-2 bg-blue-100 rounded-lg"><Sparkles className="w-4 h-4 text-blue-600" /></div>
                {t.tips}
              </h4>
              <p className="text-slate-600 text-sm leading-relaxed font-medium">
                {selected.tips}
              </p>
            </section>

            <section>
              <h4 className="flex items-center gap-3 text-red-500 font-black text-sm uppercase tracking-widest mb-5">
                <div className="p-2 bg-red-50 rounded-lg"><X className="w-4 h-4" /></div>
                {t.avoidPlants}
              </h4>
              <div className="flex flex-wrap gap-2">
                {selected.avoid.map(avoid => (
                  <span key={avoid} className="px-5 py-2.5 bg-red-50/50 text-red-700 rounded-xl text-xs font-bold border border-red-100">
                    {avoid}
                  </span>
                ))}
              </div>
            </section>
          </div>
        </div>
      </div>

      {/* Breeder's Guide Intro */}
      <div className="bg-[var(--primary-600)] p-8 rounded-[2.5rem] text-white shadow-lg shadow-[var(--primary-200)]/50 transition-colors duration-500">
        <div className="flex items-start gap-5">
          <div>
            <h4 className="font-black text-lg uppercase tracking-wider mb-2">{t.breedingGuideTitle}</h4>
            <p className="text-sm text-[var(--primary-50)] leading-relaxed font-medium">
              {t.breedingGuideDesc}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PlantCompatibility;
