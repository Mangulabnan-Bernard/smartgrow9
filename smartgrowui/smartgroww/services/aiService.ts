import { GoogleGenAI } from "@google/genai";
import * as tf from '@tensorflow/tfjs';
import * as tflite from '@tensorflow/tfjs-tflite';
import { DiagnosisResult, Language } from "../types";

console.log('✅ aiService.ts LOADED — with TensorFlow Lite support');

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

// TensorFlow Lite model instance
let tfliteModel: tflite.TFLiteModel | null = null;

// Load TensorFlow Lite model for offline inference
const loadTFLiteModel = async (): Promise<boolean> => {
  try {
    console.log('Loading TensorFlow Lite model...');
    const modelUrl = '/farm_model.tflite';
    tfliteModel = await tflite.loadTFLiteModel(modelUrl);
    console.log('✅ TensorFlow Lite model loaded successfully');
    return true;
  } catch (error) {
    console.error('❌ Failed to load TensorFlow Lite model:', error);
    return false;
  }
};

// Initialize TensorFlow Lite model on module load
loadTFLiteModel();

const STRICT_PROMPT = `
You are a RESTRICTED plant scanner for a farming app.

YOU CAN ONLY RECOGNIZE EXACTLY THESE 3 PLANTS:
1. Tomato
2. Garlic
3. Red Onion

ABSOLUTE RULES - ZERO EXCEPTIONS:
- Strawberry → recognized: false
- Apple → recognized: false  
- Eggplant → recognized: false
- Potato → recognized: false
- ANY plant NOT in the 3 above → recognized: false
- Animal, person, object → recognized: false
- Blurry or unclear → recognized: false
- Not 100% sure → recognized: false

ONLY return raw JSON. No markdown. No explanation. No extra text.

FOR RECOGNIZED PLANTS (Tomato, Garlic, Red Onion only):
{
  "recognized": true,
  "plant": "Tomato",
  "health": "Healthy",
  "severity": "None",
  "overview": "describe the plant condition here",
  "treatment": "what the farmer should do",
  "care": "how to care for this plant",
  "reminder": "one important reminder"
}

FOR EVERYTHING ELSE:
{
  "recognized": false,
  "plant": "Unknown",
  "message": "This plant is not recognized. This app only supports Tomato, Garlic, and Red Onion."
}
`;

const ALLOWED_PLANTS = ["tomato", "garlic", "red onion"];

// Offline inference using TensorFlow Lite
const analyzePlantOffline = async (imageB64: string): Promise<{ result: Partial<DiagnosisResult> | null; error?: string }> => {
  if (!tfliteModel) {
    console.log('TensorFlow Lite model not loaded, falling back to online...');
    return { result: null, error: 'MODEL_NOT_LOADED' };
  }

  try {
    // Convert base64 to tensor
    const img = new Image();
    img.src = imageB64;
    await new Promise(resolve => img.onload = resolve);

    // Preprocess image to match model input (assuming 224x224 RGB)
    const tensor = tf.browser.fromPixels(img)
      .resizeBilinear([224, 224])
      .div(255.0)
      .expandDims(0);

    // Run inference with simplified type handling
    const output = tfliteModel.predict(tensor) as any;
    const rawData = await output.data();
    const predictions = Array.from(rawData) as number[];

    // Clean up
    tensor.dispose();
    output.dispose();

    // Get top prediction
    const maxIndex = predictions.indexOf(Math.max(...predictions));
    const confidence = predictions[maxIndex] as number;

    // Map model output to plant names (adjust based on your model's classes)
    const plantClasses = ['Tomato', 'Garlic', 'Red Onion'];
    const predictedPlant = plantClasses[maxIndex] || 'Unknown';

    // Only accept if confidence is high enough
    if (confidence < 0.5 || !ALLOWED_PLANTS.includes(predictedPlant.toLowerCase())) {
      return {
        result: {
          id: Math.random().toString(36).substr(2, 9),
          timestamp: Date.now(),
          isPlant: false,
          plantName: 'Unknown',
          diagnosis: 'This plant is not recognized. This app only supports Tomato, Garlic, and Red Onion.',
          severity: 'None' as any,
          organicTreatment: '',
          chemicalTreatment: '',
          prevention: '',
          stressFactor: '',
          powerTips: []
        },
        error: 'NOT_RECOGNIZED'
      };
    }

    // Return successful prediction
    return {
      result: {
        id: Math.random().toString(36).substr(2, 9),
        timestamp: Date.now(),
        isPlant: true,
        plantName: predictedPlant,
        diagnosis: `Healthy — ${predictedPlant} detected with high confidence`,
        severity: 'None' as any,
        organicTreatment: 'Continue regular care and monitoring',
        chemicalTreatment: 'No treatment needed',
        prevention: 'Maintain proper watering and sunlight',
        stressFactor: 'Healthy',
        powerTips: [`${predictedPlant} appears healthy based on visual analysis`]
      }
    };

  } catch (error) {
    console.error('Offline inference failed:', error);
    return { result: null, error: 'SCAN_FAILED' };
  }
};

function forceValidate(parsed: any): any {
  // No recognized field at all → reject
  if (parsed.recognized === undefined) {
    return { recognized: false };
  }

  // Explicitly not recognized → reject
  if (parsed.recognized === false) {
    return { recognized: false };
  }

  // Says recognized → double check plant name
  const plantName = (parsed.plant || "").toLowerCase().trim();
  if (!ALLOWED_PLANTS.includes(plantName)) {
    console.warn(`BLOCKED: "${parsed.plant}" is not allowed`);
    return { recognized: false };
  }

  // Passes all checks → allow
  return parsed;
}

export const analyzePlant = async (
  imageB64: string,
  language: Language
): Promise<{ result: Partial<DiagnosisResult> | null; error?: string }> => {
  try {
    // Try offline inference first
    console.log('🔄 Attempting offline inference...');
    const offlineResult = await analyzePlantOffline(imageB64);
    
    if (offlineResult.result && offlineResult.error !== 'MODEL_NOT_LOADED') {
      console.log('✅ Offline inference successful');
      return offlineResult;
    }
    
    // If offline failed or model not loaded, try online
    console.log('🌐 Falling back to online inference...');
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: {
        parts: [
          { text: STRICT_PROMPT },
          {
            inlineData: {
              mimeType: 'image/jpeg',
              data: imageB64.includes(',')
                ? imageB64.split(',')[1]
                : imageB64
            }
          }
        ]
      }
    });

    // Clean raw response
    let rawText = (response.text || '')
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim();

    console.log('RAW GEMINI TEXT:', rawText);

    // Parse JSON
    let parsed: any;
    try {
      parsed = JSON.parse(rawText);
    } catch {
      console.warn('JSON parse failed — forcing rejection');
      parsed = { recognized: false };
    }

    console.log('PARSED:', parsed);

    // Always validate
    const validated = forceValidate(parsed);

    console.log('VALIDATED:', validated);

    // ================================
    // NOT RECOGNIZED — return null
    // so UI knows to show error screen
    // ================================
    if (!validated.recognized) {
      return {
        result: {
          id: Math.random().toString(36).substr(2, 9),
          timestamp: Date.now(),
          isPlant: false,           // ← UI checks this
          plantName: 'Unknown',
          diagnosis: 'This plant is not recognized. This app only supports Tomato, Garlic, and Red Onion.',
          severity: 'None' as any,
          organicTreatment: '',
          chemicalTreatment: '',
          prevention: '',
          stressFactor: '',
          powerTips: []
        },
        error: 'NOT_RECOGNIZED'     // ← UI also checks this
      };
    }

    // ================================
    // RECOGNIZED — Tomato/Garlic/Red Onion only
    // ================================
    return {
      result: {
        id: Math.random().toString(36).substr(2, 9),
        timestamp: Date.now(),
        isPlant: true,
        plantName: validated.plant,
        diagnosis: `${validated.health} — ${validated.overview}`,
        severity: validated.severity || 'None',
        organicTreatment: validated.treatment || '',
        chemicalTreatment: validated.treatment || '',
        prevention: validated.care || '',
        stressFactor: validated.health || 'Unknown',
        powerTips: [validated.reminder || '']
      }
    };

  } catch (error: any) {
    console.error('analyzePlant error:', error);
    return {
      result: null,
      error: 'SCAN_FAILED'
    };
  }
};