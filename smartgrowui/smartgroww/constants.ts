
import { Language } from './types';

export const THEME_CONFIGS: Record<string, Record<string, string>> = {
  green: {
    50: '#f0fdf4', 100: '#dcfce7', 200: '#bbf7d0', 300: '#86efac', 400: '#4ade80', 500: '#22c55e', 600: '#16a34a', 700: '#15803d', 800: '#166534', 900: '#14532d'
  },
  blue: {
    50: '#eff6ff', 100: '#dbeafe', 200: '#bfdbfe', 300: '#93c5fd', 400: '#60a5fa', 500: '#3b82f6', 600: '#2563eb', 700: '#1d4ed8', 800: '#1e40af', 900: '#1e3a8a'
  },
  purple: {
    50: '#faf5ff', 100: '#f3e8ff', 200: '#e9d5ff', 300: '#d8b4fe', 400: '#c084fc', 500: '#a855f7', 600: '#9333ea', 700: '#7e22ce', 800: '#6b21a8', 900: '#581c87'
  },
  rose: {
    50: '#fff1f2', 100: '#ffe4e6', 200: '#fecdd3', 300: '#fda4af', 400: '#fb7185', 500: '#f43f5e', 600: '#e11d48', 700: '#be123c', 800: '#9f1239', 900: '#881337'
  },
  orange: {
    50: '#fff7ed', 100: '#ffedd5', 200: '#fed7aa', 300: '#fdb374', 400: '#fb923c', 500: '#f97316', 600: '#ea580c', 700: '#c2410c', 800: '#9a3412', 900: '#7c2d12'
  },
  teal: {
    50: '#f0fdfa', 100: '#ccfbf1', 200: '#99f6e4', 300: '#5eead4', 400: '#2dd4bf', 500: '#14b8a6', 600: '#0d9488', 700: '#0f766e', 800: '#115e59', 900: '#134e4a'
  }
};

export const TRANSLATIONS: Record<Language, any> = {
  en: {
    dashboard: 'Home',
    welcome: 'Hello again',
    healthScore: 'Plant Health',
    activeMonitoring: 'Track',
    scanNow: 'Check Plant',
    startAnalysis: 'Look at Plant',
    plantGuide: 'Plant Guide',
    analytics: 'Stats',
    todayAgenda: "To-do Today",
    environment: 'Room Info',
    temp: 'Heat',
    hum: 'Air Water',
    soil: 'Soil Water',
    light: 'Sunlight',
    history: 'History',
    profile: 'Settings',
    logout: 'Exit',
    level: 'Level',
    xp: 'Points',
    diagnosis: 'The Problem',
    treatment: 'How to Fix',
    prevention: 'How to Protect',
    organic: 'Natural',
    chemical: 'Medicine',
    save: 'Save This',
    startMonitoring: 'Start 7-Day Plan',
    languageToggle: 'Tagalog',
    scanRequired: 'Need a scan for Day',
    completed: 'Done',
    monitoringTitle: 'Getting Better',
    companionPlants: 'Good Neighbors',
    avoidPlants: 'Bad Neighbors',
    tips: 'Pro Tips',
    severity: 'How Bad',
    healthy: 'Healthy',
    mild: 'A little sick',
    moderate: 'Sick',
    severe: 'Very sick',
    about: 'About Us',
    aboutContent: 'SmartGrow AI helps you take care of your plants. Take a photo, and our AI tells you if the plant is sick and how to make it healthy again.',
    xpGuide: 'Point Guide',
    mixTips: 'Mixing Tips',
    breedingGuideTitle: "Breeder's Guide",
    breedingGuideDesc: 'This guide helps you see which plants can grow together and which ones might mix to make new ones. It also shows family members.',
    searchPlaceholder: 'Search for a plant...',
    knowledgeHeader: 'Plant Knowledge',
    knowledgeSub: 'Breeding & Neighbors',
    archived: 'Archive',
    manageArchive: 'Manage Archive',
    restore: 'Put Back',
    deletePermanently: 'Delete Forever',
    emptyArchive: 'Archive is empty',
    status: 'Status',
    statHealth: 'Health',
    statTracking: 'Tracking',
    statChecks: 'Checks',
    changeTheme: 'Theme Color',
    settings: 'Settings'
  },
  tl: {
    dashboard: 'Home',
    welcome: 'Maligayang pagbabalik',
    healthScore: 'Kalusugan ng Halaman',
    activeMonitoring: 'Track',
    scanNow: 'Suriin ang Halaman',
    startAnalysis: 'Simulan ang Pagsusuri',
    plantGuide: 'Gabay sa Halaman',
    analytics: 'Analitika',
    todayAgenda: 'Adyenda Ngayon',
    environment: 'Kapaligiran',
    temp: 'Temp',
    hum: 'Hum',
    soil: 'Lupa',
    light: 'Liwanag',
    history: 'History',
    profile: 'Settings',
    logout: 'Mag-logout',
    level: 'Antas',
    xp: 'XP',
    diagnosis: 'Diagnosis',
    treatment: 'Gamutan',
    prevention: 'Pag-iwas',
    organic: 'Organiko',
    chemical: 'Kemikal',
    save: 'I-save ang Resulta',
    startMonitoring: 'Simulan ang 7-Araw na Plano',
    languageToggle: 'English',
    scanRequired: 'Kailangan ang scan para sa Araw',
    completed: 'Tapos na',
    monitoringTitle: 'Paggaling',
    companionPlants: 'Mabuting Kapitbahay',
    avoidPlants: 'Masamang Kapitbahay',
    tips: 'Mga Tip sa Pagpapalaki',
    severity: 'Kalubhaan',
    healthy: 'Malusog',
    mild: 'Katamtaman',
    moderate: 'Malala',
    severe: 'Napakalala',
    about: 'Tungkol sa SmartGrow',
    aboutContent: 'Ang SmartGrow AI ay ang iyong propesyonal na kasama sa paghahalaman. Gamit ang advanced na Google Gemini AI, sinusuri namin ang kalusugan ng halaman mula sa isang larawan, na nagbibigay ng mga organikong at kemikal na plano sa paggamot para sa iyong hardin.',
    xpGuide: 'Gabay sa Paglago',
    mixTips: 'Mga Tip sa Pag-mix',
    breedingGuideTitle: 'Gabay ng Breeder',
    breedingGuideDesc: 'Ang gabay na ito ay tumutulong sa iyo na makita kung aling mga halaman ang maaaring magkasamang lumaki at alin ang maaaring mag-mix para sa bagong bersyon.',
    searchPlaceholder: 'Maghanap ng halaman...',
    knowledgeHeader: 'Kaalaman sa Halaman',
    knowledgeSub: 'Pagpapadami at Kapitbahay',
    archived: 'Archive',
    manageArchive: 'I-manage ang Archive',
    restore: 'Ibalik',
    deletePermanently: 'Burahin nang Tuluyan',
    emptyArchive: 'Walang laman ang archive',
    status: 'Katayuan',
    statHealth: 'Kalusugan',
    statTracking: 'Pagsubaybay',
    statChecks: 'Pagsusuri',
    changeTheme: 'Kulay ng Tema',
    settings: 'Settings'
  }
};

export const XP_RULES = [
  { action: 'First Scan', points: '+50 XP', description: 'Check your first plant.' },
  { action: 'Daily Check', points: '+100 XP', description: 'Check a plant that is getting better.' },
  { action: 'Full Recovery', points: '+500 XP', description: 'Make a sick plant healthy again.' },
  { action: 'Reading Guide', points: '+20 XP', description: 'Learn about plant neighbors.' }
];

export const PLANT_GUIDE_DATA = [
  { 
    id: 'tomato', 
    name: 'Tomato', 
    category: 'Nightshade',
    companions: ['Basil', 'Marigold', 'Carrots', 'Onions'], 
    avoid: ['Cabbage', 'Corn', 'Potatoes'], 
    tips: 'Needs lots of sun and water. Cut extra stems to help air flow.',
    hybridInfo: 'Can mix with other tomatoes. Keep them 10 feet apart if you want to keep seeds pure. You can join them to eggplant roots.'
  },
  { 
    id: 'pepper', 
    name: 'Pepper', 
    category: 'Nightshade',
    companions: ['Onions', 'Basil', 'Carrots', 'Coriander'], 
    avoid: ['Beans', 'Kale', 'Fennel'], 
    tips: 'Keep soil wet but not too much water. Peppers like heat.',
    hybridInfo: 'Hot and sweet peppers can mix. If they mix, your sweet peppers might taste spicy next year.'
  },
  { 
    id: 'cucumber', 
    name: 'Cucumber', 
    category: 'Gourd',
    companions: ['Beans', 'Corn', 'Peas', 'Radishes'], 
    avoid: ['Potatoes', 'Sage', 'Strong Herbs'], 
    tips: 'Needs something to climb on. Needs lots of water.',
    hybridInfo: 'Can mix with melons or other cucumbers if bees are nearby. Needs bees to make fruit.'
  },
  { 
    id: 'eggplant', 
    name: 'Eggplant', 
    category: 'Nightshade',
    companions: ['Beans', 'Peppers', 'Spinach', 'Thyme'], 
    avoid: ['None specifically'], 
    tips: 'Likes rich soil and lots of sun. Watch for tiny bugs.',
    hybridInfo: 'Polinates itself but bees help. Can mix with wild nightshade plants.'
  },
  { 
    id: 'strawberry', 
    name: 'Strawberry', 
    category: 'Rose Family',
    companions: ['Borage', 'Beans', 'Lettuce', 'Spinach'], 
    avoid: ['Cabbage', 'Broccoli', 'Cauliflower'], 
    tips: 'Needs soil that lets water out. Put straw on the ground to keep fruit clean.',
    hybridInfo: 'Grows from seeds or baby plants. Different kinds of strawberries usually do not mix easily.'
  },
  { 
    id: 'basil', 
    name: 'Basil', 
    category: 'Mint Family',
    companions: ['Tomato', 'Peppers', 'Asparagus', 'Oregano'], 
    avoid: ['Rue', 'Sage'], 
    tips: 'Cut off flowers so the leaves keep growing. Likes warm weather.',
    hybridInfo: 'Different basils mix very easily. High chance of making a new "mystery" basil if they flower together.'
  },
  { 
    id: 'monstera', 
    name: 'Monstera', 
    category: 'Arum Family',
    companions: ['Pothos', 'Philodendron'], 
    avoid: ['None'], 
    tips: 'A climbing plant. Clean the leaves so they can breathe better.',
    hybridInfo: 'Mixing needs help by hand. Rare white-leaf versions only grow from stem cuttings.'
  },
  { 
    id: 'rose', 
    name: 'Rose', 
    category: 'Rose Family',
    companions: ['Garlic', 'Chives', 'Lavender', 'Marigold'], 
    avoid: ['None'], 
    tips: 'Water at the bottom, not on leaves. Cut back in early spring.',
    hybridInfo: 'Most garden roses are already mixed. We usually use "root-joining" to grow new ones that look the same.'
  }
];

export const FARMER_TIPS: Record<Language, string[]> = {
  en: [
    "Use neem oil to stop tiny bugs.",
    "Water in the morning so the plant stays dry at night.",
    "Turn food waste into soil food.",
    "Change where you plant every year.",
    "Dissolved aspirin can help a plant stay strong."
  ],
  tl: [
    "Gumamit ng neem oil para pigilan ang mga maliliit na insekto.",
    "Magdilig sa umaga para manatiling tuyo ang halaman sa gabi.",
    "Gawing pataba ang mga tira-tirang pagkain.",
    "Ibahin ang pwesto ng tanim bawat taon.",
    "Ang natunaw na aspirin ay nakakatulong sa halaman na manatiling matatag."
  ]
};
